const cds = require('@sap/cds');
const log = cds.log('stock-nos');

module.exports = class Stock_NOSService extends cds.ApplicationService {
    async init() {
        const { StockMovement } = this.entities;

        this.before('CREATE', StockMovement, (req) => {
            const { type, requester_ID, quantity } = req.data;
            if (!quantity || parseFloat(quantity) <= 0) req.error(400, 'Quantity must be greater than zero.');
            if (type === 'EXIT' && !requester_ID) req.error(400, 'Requester is mandatory for EXIT movements.');
        });

        this.on('loadMasterData', async (req) => {
            const { products = [], locations = [], channels = [] } = req.data;
            const db = await cds.connect.to('db');
            const { Product, Location, Channel } = cds.entities('Stock_NOS');

            const stamp = (items) => items.map(i => ({ ID: cds.utils.uuid(), ...i }));

            if (channels.length) await db.run(INSERT.into(Channel).entries(stamp(channels)));
            if (locations.length) await db.run(INSERT.into(Location).entries(stamp(locations)));
            if (products.length) await db.run(INSERT.into(Product).entries(stamp(products)));

            const summary = `Inserted: ${channels.length} channels | ${locations.length} locations | ${products.length} products`;
            log.info(`[loadMasterData] ${summary}`);
            return summary;
        });

        this.on('processInventoryEvent', async (req) => {
            const { header, positions } = req.data;
            log.info(`[${header.eventId}] Received | source: ${header.sourceSystem} | sync: ${header.syncType} | positions: ${positions.length}`);

            cds.spawn(async () => {
                const t0 = Date.now();
                try {
                    const db = await cds.connect.to('db');
                    const { InventoryEvent, StockMovement, Product, Location, Channel } = cds.entities('Stock_NOS');

                    const eventId = cds.utils.uuid();
                    await db.run(
                        INSERT.into(InventoryEvent).entries({
                            ID: eventId,
                            eventId: header.eventId,
                            sourceSystem: header.sourceSystem,
                            syncType: header.syncType,
                            eventTs: header.timestamp,
                            totalRecords: header.totalRecords
                        })
                    );
                    log.info(`[${header.eventId}] InventoryEvent created | id: ${eventId}`);

                    const skus = [...new Set(positions.map(p => p.sku))];
                    const siteIds = [...new Set(positions.map(p => p.siteId))];
                    const codes = [...new Set(positions.map(p => p.channel))];

                    const [products, locations, channels] = await Promise.all([
                        db.run(SELECT.from(Product).where({ productSAPCode: { in: skus } })),
                        db.run(SELECT.from(Location).where({ siteId: { in: siteIds } })),
                        db.run(SELECT.from(Channel).where({ code: { in: codes } })),
                    ]);
                    const productBySku = new Map(products.map(p => [p.productSAPCode, p]));
                    const locationBySite = new Map(locations.map(l => [l.siteId, l]));
                    const channelByCode = new Map(channels.map(c => [c.code, c]));

                    const movements = [];
                    for (const pos of positions) {
                        const product = productBySku.get(pos.sku);
                        const location = locationBySite.get(pos.siteId);
                        const channel = channelByCode.get(pos.channel);

                        if (!product || !location || !channel) {
                            log.warn(`[${header.eventId}] Skipped position | sku: ${pos.sku} | siteId: ${pos.siteId} | channel: ${pos.channel} | reason: master data not found`);
                            continue;
                        }

                        movements.push({
                            ID: cds.utils.uuid(),
                            product_ID: product.ID,
                            quantity: pos.availableQuantity,
                            unitOfMeasure: pos.unitOfMeasure,
                            stockStatus: pos.inventoryType === 'TRANSIT' ? 'IN_TRANSIT' : 'IN_STOCK',
                            stockType: pos.inventoryType,
                            location_ID: location.ID,
                            channel_ID: channel.ID,
                            type: 'ENTRY',
                            transitId: pos.transitId || null,
                            estimatedArrival: pos.estimatedArrival || null,
                            lastMovementDate: pos.lastMovementDate,
                            inventoryEvent_ID: eventId
                        });
                    }

                    if (movements.length > 0) {
                        await db.run(INSERT.into(StockMovement).entries(movements));
                        log.info(`[${header.eventId}] StockMovements inserted | total: ${movements.length}`);
                    }

                    await this.emit('InventoryEventProcessed', {
                        eventId: header.eventId,
                        totalCreated: movements.length
                    });
                    log.info(`[${header.eventId}] Processing complete | created: ${movements.length} of ${positions.length} | Exec time: ${Date.now() - t0}ms`);

                } catch (err) {
                    log.error(`[${header.eventId}] Processing failed | ${err.message}`, err);
                    await this.emit('InventoryEventFailed', {
                        eventId: header.eventId,
                        reason: err.message
                    });
                }
            });

            return `Event ${header.eventId} accepted — processing ${positions.length} positions in background`;
        });

        return super.init();
    }
};
