using Stock_NOSService as service from '../../srv/service';

// ─── ProductStockSummary — element-level labels ────────────────────────────────
// Covers all annotatable fields so filter bar and forms
// always show human-readable text regardless of where a field appears.
// ─────────────────────────────────────────────────────────────────────────────
annotate service.ProductStockSummary with {
    totalBalance @Common.Label: '{i18n>totalBalance}';
    inTransit    @Common.Label: '{i18n>inTransit}';
    blocked      @Common.Label: '{i18n>blocked}';
};

// ─── Product Stock Summary ────────────────────────────────────────────────────
// List Report: one row per product with rolled-up balance, in-transit & blocked.
// Object Page: product info + stock numbers.
// ─────────────────────────────────────────────────────────────────────────────

annotate service.ProductStockSummary with @(
    UI.HeaderInfo              : {
        TypeName      : '{i18n>productStockTypeName}',
        TypeNamePlural: '{i18n>productStockTypeNamePlural}',
        Title         : {Value: product.productName},
        Description   : {Value: product.productSAPCode}
    },

    // Default sort: highest total balance first
    UI.PresentationVariant     : {
        SortOrder     : [{
            Property  : totalBalance,
            Descending: true
        }],
        Visualizations: ['@UI.LineItem']
    },

    // Filter bar fields
    UI.SelectionFields         : [
        product.productSAPCode,
        product.productName,
        product.productType,
        totalBalance,
        inTransit,
        blocked
    ],

    // List Report columns
    UI.LineItem                : [
        {
            $Type: 'UI.DataField',
            Label: '{i18n>product}',
            Value: product.productName
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>productSAPCode}',
            Value: product.productSAPCode
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>productType}',
            Value: product.productType
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>totalBalance}',
            Value: totalBalance
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>inTransit}',
            Value: inTransit
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>blocked}',
            Value: blocked
        }
    ],

    // Object Page sections
    UI.Facets                  : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'ProductInfo',
            Label : '{i18n>productInformation}',
            Target: '@UI.FieldGroup#ProductInfo'
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'StockSummary',
            Label : '{i18n>stockSummary}',
            Target: '@UI.FieldGroup#StockSummary'
        }
    ],

    UI.FieldGroup#ProductInfo  : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: '{i18n>productName}',
                Value: product.productName
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>productSAPCode}',
                Value: product.productSAPCode
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>productType}',
                Value: product.productType
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>productDescription}',
                Value: product.productDescription
            }
        ]
    },

    UI.FieldGroup#StockSummary : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: '{i18n>totalBalance}',
                Value: totalBalance
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>inTransit}',
                Value: inTransit
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>blocked}',
                Value: blocked
            }
        ]
    }
);
