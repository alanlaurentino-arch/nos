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

@path: '/service/Stock_NOSService'
service Stock_NOSService {
    @cds.redirection.target
    @odata.draft.enabled
    entity Product       as projection on my.Product;

    @odata.draft.enabled
    entity Location      as projection on my.Location;

    @odata.draft.enabled
    entity Channel        as projection on my.Channel;

    @odata.draft.enabled
    entity InventoryEvent as projection on my.InventoryEvent;

    @odata.draft.enabled
    entity Requester     as projection on my.Requester;

    @odata.draft.enabled
    entity Order         as projection on my.Order;

    @odata.draft.enabled
    entity StockMovement as projection on my.StockMovement;

    @readonly
    entity StockBalance  as projection on my.StockBalance;

    // Recebe o payload, confirma recebimento imediatamente e processa em background
    action processInventoryEvent(
        header    : InventoryEventHeader,
        positions : array of InventoryPosition
    ) returns String;

    // Evento emitido após processamento — pode ser consumido por outros serviços
    event InventoryEventProcessed {
        eventId      : String(50);
        totalCreated : Integer;
    }
}

annotate Stock_NOSService with @requires: ['authenticated-user'];
