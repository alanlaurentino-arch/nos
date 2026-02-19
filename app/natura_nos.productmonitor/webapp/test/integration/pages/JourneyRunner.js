sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"naturanos/productmonitor/test/integration/pages/ProductList",
	"naturanos/productmonitor/test/integration/pages/ProductObjectPage"
], function (JourneyRunner, ProductList, ProductObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('naturanos/productmonitor') + '/test/flpSandbox.html#naturanosproductmonitor-tile',
        pages: {
			onTheProductList: ProductList,
			onTheProductObjectPage: ProductObjectPage
        },
        async: true
    });

    return runner;
});

