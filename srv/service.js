const cds = require('@sap/cds');

module.exports = class Natura_NOSService extends cds.ApplicationService {
    async init() {
        const { StockMovement } = this.entities;

        this.before('CREATE', StockMovement, (req) => {
            const { type, requester_ID, quantity } = req.data;
            if (!quantity || quantity <= 0) req.error(400, 'Quantity must be greater than zero.');
            if (type === 'EXIT' && !requester_ID) req.error(400, 'Requester is mandatory for EXIT movements.');
        });

        return super.init();
    }
};
