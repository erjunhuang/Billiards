
local Store = import(".Store")
local StoreIOS = class("StoreIOS")
local logger = core.Logger.new("StoreIOS")

StoreIOS.LOAD_PRODUCTS_FINISHED    = "LOAD_PRODUCTS_FINISHED"
StoreIOS.TRANSACTION_PURCHASED     = "TRANSACTION_PURCHASED"
StoreIOS.TRANSACTION_RESTORED      = "TRANSACTION_RESTORED"
StoreIOS.TRANSACTION_FAILED        = "TRANSACTION_FAILED"
StoreIOS.TRANSACTION_UNKNOWN_ERROR = "TRANSACTION_UNKNOWN_ERROR"

local isSimulated = (device.platform == "windows")

function StoreIOS:ctor()
    nb.bind(self,"event")
    if not isSimulated then
        self.provider = Store
        if self.provider then
            self.provider.init(handler(self, self.transactionCallback))
            self.provider.setReceiptVerifyMode(nb.CCStoreReceiptVerifyModeNone, IS_SANDBOX)
        end
    end
    self.products = {}
end

function StoreIOS:canMakePurchases()
    if isSimulated then
        return true
    else
        return self.provider.canMakePurchases()
    end
end

function StoreIOS:loadProducts(productsId)
    if isSimulated then
        self:dispatchEvent({
            name = StoreIOS.LOAD_PRODUCTS_FINISHED,
            products = {{}},
            invalidProducts = {}
        })
    else
        self.provider.loadProducts(productsId, function(event)
            self.products = {}
            event.products = event.products or {}
            for _, product in ipairs(event.products) do
                self.products[product.productIdentifier] = clone(product)
            end

            self:dispatchEvent({
                name = StoreIOS.LOAD_PRODUCTS_FINISHED,
                products = event.products,
                invalidProducts = event.invalidProducts
            })
        end)
    end
end

function StoreIOS:getProductDetails(productId)
    local product = self.products[productId]
    if product then
        return clone(product)
    else
        return nil
    end
end

function StoreIOS:cancelLoadProducts()
    if not isSimulated then
        self.provider.cancelLoadProducts()
    end
end

function StoreIOS:isProductLoaded(productId)
    if isSimulated then
        return true
    else
        return self.provider.isProductLoaded(productId)
    end
end

function StoreIOS:purchaseProduct(productId,userInfo)
    logger:debug("purchase product ", productId)
    if isSimulated then
        self:transactionCallback({
            transaction = {
                state = "purchased",
                productIdentifier = productId,
                quantity = 1,
                transactionIdentifier = "fakeIdentifier",
                receipt = "",
                userInfo = userInfo,
            }
         })
    else
        self.provider.purchase(productId,userInfo)
    end
end

function StoreIOS:transactionCallback(event)
    local transaction = event.transaction
    if transaction.state == "purchased" then
        logger:debug("Transaction succuessful!")
        logger:debug("productIdentifier", transaction.productIdentifier)
        logger:debug("quantity", transaction.quantity)
        logger:debug("transactionIdentifier", transaction.transactionIdentifier)
        logger:debug("date", os.date("%Y-%m-%d %H:%M:%S", transaction.date))
        logger:debug("receipt", transaction.receipt)
        logger:debug("userInfo",transaction.userInfo)
        self:dispatchEvent({
            name = StoreIOS.TRANSACTION_PURCHASED,
            transaction = transaction,
        })
    elseif  transaction.state == "restored" then
        logger:debug("Transaction restored (from previous session)")
        logger:debug("productIdentifier", transaction.productIdentifier)
        logger:debug("receipt", transaction.receipt)
        logger:debug("transactionIdentifier", transaction.identifier)
        logger:debug("date", transaction.date)
        logger:debug("originalReceipt", transaction.originalReceipt)
        logger:debug("originalTransactionIdentifier", transaction.originalIdentifier)
        logger:debug("originalDate", transaction.originalDate)
        logger:debug("userInfo",transaction.userInfo)
        self:dispatchEvent({
            name = StoreIOS.TRANSACTION_RESTORED,
            transaction = transaction,
        })
    elseif transaction.state == "failed" then
        logger:debug("Transaction failed")
        logger:debug("errorCode", transaction.errorCode)
        logger:debug("errorString", transaction.errorString)
        self:dispatchEvent({
            name = StoreIOS.TRANSACTION_FAILED,
            transaction = transaction,
        })
    else
        logger:debug("unknown event")
        self:dispatchEvent({
            name = StoreIOS.TRANSACTION_UNKNOWN_ERROR,
            transaction = transaction,
        })
    end

    -- Once we are done with a transaction, call this to tell the store
    -- we are done with the transaction.
    -- If you are providing downloadable content, wait to call this until
    -- after the download completes.
    --self.provider.finishTransaction(transaction)
end

function StoreIOS:finishTransaction(transaction)
    if not isSimulated then
        self.provider.finishTransaction(transaction)
    end
end

function StoreIOS:restore()
    if not isSimulated then
        self.provider.restore()
    end
end

return StoreIOS
