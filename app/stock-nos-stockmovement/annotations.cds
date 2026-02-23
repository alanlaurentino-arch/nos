using Stock_NOSService as service from '../../srv/service';


// ─── StockMovement — element-level labels ────────────────────────────────
// Covers all annotatable fields so filter bar and forms
// always show human-readable text regardless of where a field appears.
// ─────────────────────────────────────────────────────────────────────────────
annotate service.StockMovement with {

    stockStatus     @Common.Label: '{i18n>stockStatus}';
    stockType     @Common.Label: '{i18n>stockType}';
};

annotate service.Location with {
  name @Common.Label : '{i18n>locationName}';
};
annotate service.Channel with {
  name @Common.Label : '{i18n>channelName}';
};



annotate service.StockMovement with @(

   UI.HeaderInfo              : {
        TypeName      : '{i18n>productStockMovimentTypeName}',
        TypeNamePlural: '{i18n>productStockMovimentTypeNamePlural}',
        Title         : {Value: product.productName},
        Description   : {Value: product.productSAPCode}
    },

    // Default sort: highest total balance first
    UI.PresentationVariant     : {
        SortOrder     : [{
            Property  : product.productName,
            Descending: false
        }],
        Visualizations: ['@UI.LineItem']
    },

    // Filter bar fields
    UI.SelectionFields         : [
        product.productSAPCode,
        product.productName,
        product.productType,
        location.name,
        channel.name,
        stockStatus,
        stockType,
    ],

    UI.LineItem : [
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
            $Type : 'UI.DataField',
            Label : '{i18n>quantity}',
            Value : quantity,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>unitOfMeasure}',
            Value : unitOfMeasure,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>stockStatus}',
            Value : stockStatus,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>stockType}',
            Value : stockType,
        },
       {
            $Type : 'UI.DataField',
            Label : '{i18n>Location}',
            Value : location.name,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>Channel}',
            Value : channel.name,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>statusNote}',
            Value : statusNote,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>Type}',
            Value : type,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>TransitId}',
            Value : transitId,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>LastMovementDate}',
            Value : lastMovementDate,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>Requester}',
            Value : requester.name,
        },
        {
            $Type : 'UI.DataField',
            Label : '{i18n>Order}',
            Value : order.ID,
        },
    ],

    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'ProductInfo',
            Label : '{i18n>productInformation}',
            Target : '@UI.FieldGroup#ProductInfo',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'StockSummary',
            Label : '{i18n>stockSummary}',
            Target: '@UI.FieldGroup#StockMovement'
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
            },
            {
                $Type : 'UI.DataField',
                Label : 'Location',
                Value : location.name,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Channel',
                Value : channel.name,
            },
        ]
    },
    UI.FieldGroup #StockMovement : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'quantity',
                Value : quantity,
            },
            {
                $Type : 'UI.DataField',
                Label : 'unitOfMeasure',
                Value : unitOfMeasure,
            },
            {
                $Type : 'UI.DataField',
                Label : 'stockStatus',
                Value : stockStatus,
            },
            {
                $Type : 'UI.DataField',
                Label : 'stockType',
                Value : stockType,
            },
            {
                $Type : 'UI.DataField',
                Label : 'statusNote',
                Value : statusNote,
            },
            {
                $Type : 'UI.DataField',
                Label : 'type',
                Value : type,
            },
            {
                $Type : 'UI.DataField',
                Label : 'transitId',
                Value : transitId,
            },
            {
                $Type : 'UI.DataField',
                Label : 'estimatedArrival',
                Value : estimatedArrival,
            },
            {
                $Type : 'UI.DataField',
                Label : 'lastMovementDate',
                Value : lastMovementDate,
            },

        
        ],
    },

);

annotate service.StockMovement with {
    product @Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'Product',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : product_ID,
                ValueListProperty : 'ID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'productName',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'productType',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'productSAPCode',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'productDescription',
            },
        ],
    }
};

annotate service.StockMovement with {
    location @Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'Location',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : location_ID,
                ValueListProperty : 'ID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'siteId',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'name',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'locationType',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'description',
            },
        ],
    }
};

annotate service.StockMovement with {
    channel @Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'Channel',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : channel_ID,
                ValueListProperty : 'ID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'code',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'name',
            },
        ],
    }
};

annotate service.StockMovement with {
    inventoryEvent @Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'InventoryEvent',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : inventoryEvent_ID,
                ValueListProperty : 'ID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'eventId',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'sourceSystem',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'syncType',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'eventTs',
            },
        ],
    }
};

annotate service.StockMovement with {
    requester @Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'Requester',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : requester_ID,
                ValueListProperty : 'ID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'name',
            },
        ],
    }
};

annotate service.StockMovement with {
    order @Common.ValueList : {
        $Type : 'Common.ValueListType',
        CollectionPath : 'Order',
        Parameters : [
            {
                $Type : 'Common.ValueListParameterInOut',
                LocalDataProperty : order_ID,
                ValueListProperty : 'ID',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'quantity',
            },
            {
                $Type : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'currentStatus',
            },
        ],
    }
};

