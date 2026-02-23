sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"stocknosstockviews/test/integration/pages/ProductStockSummaryList",
	"stocknosstockviews/test/integration/pages/ProductStockSummaryObjectPage"
], function (JourneyRunner, ProductStockSummaryList, ProductStockSummaryObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('stocknosstockviews') + '/test/flpSandbox.html#stocknosstockviews-tile',
        pages: {
			onTheProductStockSummaryList: ProductStockSummaryList,
			onTheProductStockSummaryObjectPage: ProductStockSummaryObjectPage
        },
        async: true
    });

    return runner;
});

