namespace Natura_NOS;

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
