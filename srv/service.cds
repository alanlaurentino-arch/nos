using { Natura_NOS as my } from '../db/schema1.cds';

@path : '/service/Natura_NOSService'
service Natura_NOSService
{
    @cds.redirection.target
    @odata.draft.enabled
    entity Product as
        projection on my.Product;
}

annotate Natura_NOSService with @requires :
[
    'authenticated-user'
];
