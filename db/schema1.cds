namespace Stock_NOS;

using {
    cuid,
    managed
} from '@sap/cds/common';

// Cadastro de produtos (nome, tipo, código SAP)
entity Product : cuid, managed {
    productName        : String(100);
    productType        : String(100);
    productSAPCode     : String(100); // corresponde ao campo sku do payload
    productDescription : String(100);
}

// CD, HUB ou Fábrica — identificado pelo siteId do payload (ex: CD01, HUB-SP)
type LocationType    : String(10) enum {
    CD = 'CD';
    HUB = 'HUB';
    FACTORY = 'FACTORY';
}

entity Location : cuid, managed {
    siteId       : String(20); // identificador externo: CD01, HUB-SP, etc.
    name         : String(100);
    locationType : LocationType;
    description  : String(200);
}

// Quem solicita a saída do produto e de qual local
entity Requester : cuid, managed {
    name     : String(100);
    location : Association to Location;
}

// Canal de venda — code usado para match com payload (ECOMMERCE, VAREJO)
entity Channel : cuid, managed {
    code : String(20); // ex: ECOMMERCE, VAREJO, CONSULTORAS
    name : String(100);
}

// Tipo de movimentação: entrada ou saída de estoque
type MovementType    : String(10) enum {
    ENTRY = 'ENTRY';
    EXIT = 'EXIT';
}

// Ciclo de vida do pedido
type OrderStatusType : String(20) enum {
    CREATED = 'CREATED';
    SENT_TO_PICKING = 'SENT_TO_PICKING';
    PICKED = 'PICKED';
    INVOICED = 'INVOICED';
}

// Status do produto no estoque (terminologia SAP SD)
type StockStatus     : String(20) enum {
    GOODS_RECEIPT = 'GOODS_RECEIPT'; // entrada de mercadoria
    IN_TRANSIT = 'IN_TRANSIT'; // em trânsito entre locais
    IN_STOCK = 'IN_STOCK'; // disponível no CD
    GOODS_ISSUE = 'GOODS_ISSUE'; // saída de mercadoria
}

// Tipo de estoque — alinhado com inventoryType do payload
type StockType       : String(20) enum {
    ON_HAND = 'ON_HAND'; // estoque físico disponível
    EXTENDED = 'EXTENDED'; // estoque estendido (ex: HUB)
    TRANSIT = 'TRANSIT'; // em trânsito entre sites
    BLOCKED = 'BLOCKED'; // bloqueado (avaria, devolução)
}

// Header do evento recebido — rastreabilidade da origem do dado
entity InventoryEvent : cuid, managed {
    eventId      : String(50); // ex: evt-nos-849201-9948
    sourceSystem : String(50); // ex: SAP_BTP_NOS_ENGINE
    syncType     : String(10); // DELTA ou FULL
    eventTs      : Timestamp; // timestamp original do evento
    totalRecords : Integer;
}

// Pedido: do order entry até a remessa
entity Order : cuid, managed {
    product       : Association to Product;
    quantity      : Decimal(15, 2);
    requester     : Association to Requester;
    channel       : Association to Channel;
    currentStatus : OrderStatusType;
    // Histórico completo de status — o mais recente via createdAt = situação atual
    statusHistory : Composition of many OrderStatus
                        on statusHistory.order = $self;
}

// Cada linha representa uma mudança de status do pedido
entity OrderStatus : cuid, managed {
    order  : Association to Order;
    status : OrderStatusType;
}

// Cada linha é um evento de estoque; saldo = soma de ENTRY menos soma de EXIT
entity StockMovement : cuid, managed {
    product          : Association to Product;
    quantity         : Decimal(15, 2); // ex: 150.00
    unitOfMeasure    : String(10); // ex: UN, KG, L
    stockStatus      : StockStatus;
    stockType        : StockType;
    location         : Association to Location;
    channel          : Association to Channel;
    statusNote       : String(200);
    type             : MovementType;
    transitId        : String(50); // ex: TR-881293 (somente TRANSIT)
    estimatedArrival : Timestamp; // previsão de chegada (somente TRANSIT)
    lastMovementDate : Timestamp; // data da última movimentação no sistema origem
    inventoryEvent   : Association to InventoryEvent; // evento que originou o registro
    requester        : Association to Requester; // quem solicitou o movimento
    order            : Association to Order; // pedido que originou a saída (somente EXIT)
}

// Saldo atual por produto e local
view StockBalance as
    select from StockMovement {
        key product,
        key location,
            sum(case
                    when type = 'ENTRY'
                         then quantity
                    else -quantity
                end) as balance : Decimal(15, 2)
    }
    group by
        product,
        location;

// Saldo líquido por produto, localização e canal de venda (ex: ECOMMERCE vs VAREJO)
view StockBalanceByChannel as
    select from StockMovement {
        key product,
        key location,
        key channel,
            sum(case
                    when type = 'ENTRY'
                         then quantity
                    else -quantity
                end) as balance : Decimal(15, 2)
    }
    group by
        product,
        location,
        channel;

// Saldo por produto, localização e tipo de estoque (ON_HAND, EXTENDED, TRANSIT, BLOCKED)
view StockBalanceByType as
    select from StockMovement {
        key product,
        key location,
        key stockType,
            sum(case
                    when type = 'ENTRY'
                         then quantity
                    else -quantity
                end) as balance : Decimal(15, 2)
    }
    group by
        product,
        location,
        stockType;

// Movimentos em trânsito entre locais, com ID de remessa e previsão de chegada
view StockInTransit as
    select from StockMovement {
        ID,
        product,
        location,
        channel,
        quantity,
        unitOfMeasure,
        transitId,
        estimatedArrival,
        lastMovementDate,
        inventoryEvent
    }
    where
        stockType = 'TRANSIT';

// Totais consolidados por produto: saldo disponível, em trânsito e bloqueado
view ProductStockSummary as
    select from StockMovement {
        key product,
            sum(case
                    when type = 'ENTRY'
                         then quantity
                    else -quantity
                end) as totalBalance : Decimal(15, 2),
            sum(case
                    when stockType = 'TRANSIT'
                         and type = 'ENTRY'
                         then quantity
                    else 0
                end) as inTransit    : Decimal(15, 2),
            sum(case
                    when stockType = 'BLOCKED'
                         and type = 'ENTRY'
                         then quantity
                    else 0
                end) as blocked      : Decimal(15, 2)
    }
    group by
        product;

// Movimentos criados por evento vs total declarado no header — detecta posições ignoradas
view InventoryEventSummary as
    select from StockMovement {
        key inventoryEvent,
            count( * ) as movementsCreated : Integer
    }
    group by
        inventoryEvent;
