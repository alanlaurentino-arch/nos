const cds = require('@sap/cds');

module.exports = class Stock_NOSService extends cds.ApplicationService {
    async init() {
        const { StockMovement } = this.entities;

        this.before('CREATE', StockMovement, (req) => {
            const { type, requester_ID, quantity } = req.data;
            if (!quantity || parseFloat(quantity) <= 0) req.error(400, 'Quantity must be greater than zero.');
            if (type === 'EXIT' && !requester_ID) req.error(400, 'Requester is mandatory for EXIT movements.');
        });

        this.on('processInventoryEvent', async (req) => {
            const { header, positions } = req.data;

            // Retorna imediatamente — processamento ocorre em background
            cds.spawn(async () => {
                const db = await cds.connect.to('db');
                const { InventoryEvent, StockMovement, Product, Location, Channel } = db.entities('Stock_NOS');

                // 1. Grava o header do evento para rastreabilidade
                const eventId = cds.utils.uuid();
                await db.run(
                    INSERT.into(InventoryEvent).entries({
                        ID           : eventId,
                        eventId      : header.eventId,
                        sourceSystem : header.sourceSystem,
                        syncType     : header.syncType,
                        eventTs      : header.timestamp,
                        totalRecords : header.totalRecords
                    })
                );

                // 2. Processa cada posição de estoque
                const movements = [];
                for (const pos of positions) {
                    const [product]  = await db.run(SELECT.from(Product).where({ productSAPCode: pos.sku }));
                    const [location] = await db.run(SELECT.from(Location).where({ siteId: pos.siteId }));
                    const [channel]  = await db.run(SELECT.from(Channel).where({ code: pos.channel }));

                    if (!product || !location || !channel) continue;

                    movements.push({
                        ID               : cds.utils.uuid(),
                        product_ID       : product.ID,
                        quantity         : pos.availableQuantity,
                        unitOfMeasure    : pos.unitOfMeasure,
                        stockStatus      : pos.inventoryType === 'TRANSIT' ? 'IN_TRANSIT' : 'IN_STOCK',
                        stockType        : pos.inventoryType,
                        location_ID      : location.ID,
                        channel_ID       : channel.ID,
                        type             : 'ENTRY',
                        transitId        : pos.transitId        || null,
                        estimatedArrival : pos.estimatedArrival || null,
                        lastMovementDate : pos.lastMovementDate,
                        inventoryEvent_ID: eventId
                    });
                }

                if (movements.length > 0)
                    await db.run(INSERT.into(StockMovement).entries(movements));

                // 3. Emite evento de conclusão — outros serviços podem consumir
                await this.emit('InventoryEventProcessed', {
                    eventId      : header.eventId,
                    totalCreated : movements.length
                });
            });

            return `Event ${header.eventId} accepted — processing ${positions.length} positions in background`;
        });

        return super.init();
    }
};
