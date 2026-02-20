sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"stocknos/productmonitor/test/integration/pages/ProductList",
	"stocknos/productmonitor/test/integration/pages/ProductObjectPage"
], function (JourneyRunner, ProductList, ProductObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('stocknos/productmonitor') + '/test/flpSandbox.html#stocknosproductmonitor-tile',
        pages: {
			onTheProductList: ProductList,
			onTheProductObjectPage: ProductObjectPage
        },
        async: true
    });

    return runner;
});

