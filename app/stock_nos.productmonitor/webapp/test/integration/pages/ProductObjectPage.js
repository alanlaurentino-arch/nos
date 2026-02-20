sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'stocknos.productmonitor',
            componentId: 'ProductObjectPage',
            contextPath: '/Product'
        },
        CustomPageDefinitions
    );
});