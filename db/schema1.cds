namespace Natura_NOS;

using {
    cuid,
    managed
} from '@sap/cds/common';

// Cadastro de produtos (nome, tipo, código SAP)
entity Product : cuid, managed {
    productName        : String(100);
    productType        : String(100);
    productSAPCode     : String(100);
    productDescription : String(100);
}

// Locais físicos: fábricas, CDs, lojas
entity Location : cuid, managed {
    name        : String(100);
    description : String(200);
}

// Quem solicita a saída do produto e de qual local
entity Requester : cuid, managed {
    name     : String(100);
    location : Association to Location;
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

// Status do produto no estoque
type StockStatus     : String(20) enum {
    GOODS_RECEIPT = 'GOODS_RECEIPT'; // entrada de mercadoria
    IN_TRANSIT = 'IN_TRANSIT'; // em trânsito entre locais
    IN_STOCK = 'IN_STOCK'; // disponível no CD
    GOODS_ISSUE = 'GOODS_ISSUE'; // saída de mercadoria
}

// Tipo de estoque
type StockType       : String(20) enum {
    UNRESTRICTED = 'UNRESTRICTED'; // livre para uso
    BLOCKED = 'BLOCKED'; // bloqueado (avaria, devolução)
}

// Canal de venda: ex. e-commerce, varejo, etc
entity Channel : cuid, managed {
    name : String(100);
}

// Pedido: do order entry até a remessa
entity Order : cuid, managed {
    product       : Association to Product;
    quantity      : Integer;
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
    product     : Association to Product;
    quantity    : Integer;
    stockStatus : StockStatus;
    stockType   : StockType;
    location    : Association to Location;
    channel     : Association to Channel;
    statusNote  : String(200);
    type        : MovementType;
    requester   : Association to Requester;
    order       : Association to Order; // pedido que originou a saída (somente EXIT)
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
                end) as balance : Integer
    }
    group by
        product,
        location;
