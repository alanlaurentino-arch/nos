using Stock_NOSService as service from '../../srv/service';

// Element-level labels — shared by both the list columns and the filter bar.
// The {i18n>key} binding is resolved at runtime by each app's i18n bundle.
// Keys must be defined in both apps' i18n files.
annotate service.Product with {
    productName        @Common.Label: '{i18n>productName}';
    productType        @Common.Label: '{i18n>productType}';
    productSAPCode     @Common.Label: '{i18n>productSAPCode}';
    productDescription @Common.Label: '{i18n>productDescription}';
};

annotate service.Product with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : '{i18n>productName}',
                Value : productName,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>productType}',
                Value : productType,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>productSAPCode}',
                Value : productSAPCode,
            },
            {
                $Type : 'UI.DataField',
                Label : '{i18n>productDescription}',
                Value : productDescription,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : '{i18n>generalInformation}',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.SelectionFields : [
        productSAPCode,
        productName,
        productType
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : '{i18n>productName}',
            Value : productName,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>productType}',
            Value : productType,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>productSAPCode}',
            Value : productSAPCode,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>productDescription}',
            Value : productDescription,
        },
    ],
);
