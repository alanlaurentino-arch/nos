sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"stocknosstockmovement/test/integration/pages/StockMovementList",
	"stocknosstockmovement/test/integration/pages/StockMovementObjectPage"
], function (JourneyRunner, StockMovementList, StockMovementObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('stocknosstockmovement') + '/test/flp.html#app-preview',
        pages: {
			onTheStockMovementList: StockMovementList,
			onTheStockMovementObjectPage: StockMovementObjectPage
        },
        async: true
    });

    return runner;
});

