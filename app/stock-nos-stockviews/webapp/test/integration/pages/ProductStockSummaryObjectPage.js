sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'stocknosstockviews',
            componentId: 'ProductStockSummaryObjectPage',
            contextPath: '/ProductStockSummary'
        },
        CustomPageDefinitions
    );
});