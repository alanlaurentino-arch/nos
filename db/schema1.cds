namespace Natura_NOS;

using { managed } from '@sap/cds/common';

entity Product
{
    key ID : UUID;
    productName : String(100);
    productType : String(100);
    productSAPCode : String(100);
    productDescription : String(100);
}

entity HUB
{
    key ID : UUID;
}


entity Location
{
    key ID : UUID;
    name : String(100);
    description : String(255);
}

entity Requester
{
    key ID : UUID;
    name : String(100);
    department : String(100);
}

entity StockTransaction : managed
{
    key ID : UUID;
    
    // Informações Básicas
    product : Association to Product;
    quantity : Integer;
    transactionType : String(10); // 'Entrada' ou 'Saida'
    stockStatus : String(50); // 'produzido', 'em transito'
    location : Association to Location;
    statusInfo : String(255);
    
    // Informações Específicas de Saída (Ficam vazias quando for Entrada)
    requester : Association to Requester;
    requesterLocation : Association to Location;
}