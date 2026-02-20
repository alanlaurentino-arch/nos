using Stock_NOSService as service from '../../srv/service';
annotate service.Product with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'productName',
                Value : productName,
            },
            {
                $Type : 'UI.DataField',
                Label : 'productType',
                Value : productType,
            },
            {
                $Type : 'UI.DataField',
                Label : 'productSAPCode',
                Value : productSAPCode,
            },
            {
                $Type : 'UI.DataField',
                Label : 'productDescription',
                Value : productDescription,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'productName',
            Value : productName,
        },
        {
            $Type : 'UI.DataField',
            Label : 'productType',
            Value : productType,
        },
        {
            $Type : 'UI.DataField',
            Label : 'productSAPCode',
            Value : productSAPCode,
        },
        {
            $Type : 'UI.DataField',
            Label : 'productDescription',
            Value : productDescription,
        },
    ],
);

