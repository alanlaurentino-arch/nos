using {Stock_NOS as my} from '../db/schema1.cds';

// Tipos que espelham o payload de entrada do motor de estoque
type InventoryEventHeader {
    eventId      : String(50);
    timestamp    : Timestamp;
    sourceSystem : String(50);
    syncType     : String(10);
    totalRecords : Integer;
}

type InventoryPosition {
    sku               : String(100);
    siteId            : String(20);
    channel           : String(20);
    inventoryType     : String(20);
    availableQuantity : Decimal(15, 2);
    unitOfMeasure     : String(10);
    lastMovementDate  : Timestamp;
    transitId         : String(50);
    estimatedArrival  : Timestamp;
}

type ProductInput {
    productName        : String(100);
    productType        : String(100);
    productSAPCode     : String(100);
    productDescription : String(100);
}

type LocationInput {
    siteId       : String(20);
    name         : String(100);
    locationType : my.LocationType;
    description  : String(200);
}

type ChannelInput {
    code : String(20);
    name : String(100);
}

@path: '/service/Stock_NOSService'
service Stock_NOSService {
    @cds.redirection.target
    @odata.draft.enabled
    entity Product               as projection on my.Product;

    @odata.draft.enabled
    entity Location              as projection on my.Location;

    @odata.draft.enabled
    entity Channel               as projection on my.Channel;

    @odata.draft.enabled
    entity InventoryEvent        as projection on my.InventoryEvent;

    @odata.draft.enabled
    entity Requester             as projection on my.Requester;

    @cds.redirection.target
    @odata.draft.enabled
    entity Order                 as projection on my.Order;

 //   @odata.draft.enabled
    @readonly
    entity StockMovement         as projection on my.StockMovement;

    @readonly
    entity StockBalance          as projection on my.StockBalance;

    @readonly
    entity StockBalanceByChannel as projection on my.StockBalanceByChannel;

    @readonly
    entity StockBalanceByType    as projection on my.StockBalanceByType;

    @readonly
    entity StockInTransit        as projection on my.StockInTransit;

    @readonly
    entity ProductStockSummary   as projection on my.ProductStockSummary;

    @readonly
    entity InventoryEventSummary as projection on my.InventoryEventSummary;

    // Bulk seed de master data — aceita arrays e insere em batch
    action loadMasterData(products: array of ProductInput,
                          locations: array of LocationInput,
                          channels: array of ChannelInput)              returns String;

    // Recebe o payload, confirma recebimento imediatamente e processa em background
    action processInventoryEvent(header: InventoryEventHeader,
                                 positions: array of InventoryPosition) returns String;

    // Emitido quando o processamento em background conclui com sucesso
    event InventoryEventProcessed {
        eventId      : String(50);
        totalCreated : Integer;
    }

    // Emitido quando o processamento em background falha
    event InventoryEventFailed {
        eventId : String(50);
        reason  : String(500);
    }
}

annotate Stock_NOSService with @requires: ['authenticated-user'];
