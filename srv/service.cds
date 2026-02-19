using {Natura_NOS as my} from '../db/schema1.cds';

@path: '/service/Natura_NOSService'
service Natura_NOSService {
    @cds.redirection.target
    @odata.draft.enabled
    entity Product       as projection on my.Product;

    @odata.draft.enabled
    entity Location      as projection on my.Location;

    @odata.draft.enabled
    entity Channel       as projection on my.Channel;

    @odata.draft.enabled
    entity Requester     as projection on my.Requester;

    @odata.draft.enabled
    entity Order         as projection on my.Order;

    @odata.draft.enabled
    entity StockMovement as projection on my.StockMovement;

    @readonly
    entity StockBalance  as projection on my.StockBalance;
}

annotate Natura_NOSService with @requires: ['authenticated-user'];
