local Store = {}

local function checkCCStore()
    if not nb.Store then
        printError("framework.nb.sdk.Store - nb.Store not exists.")
        return false
    end
    return true
end

function Store.init(listener)
    if not checkCCStore() then return false end

    if nb.storeProvider then
        printError("Store.init() - store already init")
        return false
    end

    if type(listener) ~= "function" then
        printError("Store.init() - invalid listener")
        return false
    end

    nb.storeProvider = nb.Store:sharedStore() -- avoid gc
    return nb.storeProvider:postInitWithTransactionListener(listener)
end

function Store.getReceiptVerifyMode()
    if not checkCCStore() then return false end
    return nb.storeProvider:getReceiptVerifyMode()
end

function Store.setReceiptVerifyMode(mode, isSandbox)
    if not checkCCStore() then return false end

    if type(mode) ~= "number"
        or (mode ~= nb.CCStoreReceiptVerifyModeNone
            and mode ~= nb.CCStoreReceiptVerifyModeDevice
            and mode ~= nb.CCStoreReceiptVerifyModeServer) then
        printError("Store.setReceiptVerifyMode() - invalid mode")
        return false
    end

    if type(isSandbox) ~= "boolean" then isSandbox = true end
    nb.storeProvider:setReceiptVerifyMode(mode, isSandbox)
end

function Store.getReceiptVerifyServerUrl()
    if not checkCCStore() then return false end
    return nb.storeProvider:getReceiptVerifyServerUrl()
end

function Store.setReceiptVerifyServerUrl(url)
    if not checkCCStore() then return false end

    if type(url) ~= "string" then
        printError("Store.setReceiptVerifyServerUrl() - invalid url")
        return false
    end
    nb.storeProvider:setReceiptVerifyServerUrl(url)
end

function Store.canMakePurchases()
    if not checkCCStore() then return false end
    return nb.storeProvider:canMakePurchases()
end

function Store.loadProducts(productsId, listener)
    if not checkCCStore() then return false end

    if type(listener) ~= "function" then
        printError("Store.loadProducts() - invalid listener")
        return false
    end

    if type(productsId) ~= "table" then
        printError("Store.loadProducts() - invalid productsId")
        return false
    end

    for i = 1, #productsId do
        if type(productsId[i]) ~= "string" then
            printError("Store.loadProducts() - invalid id[#%d] in productsId", i)
            return false
        end
    end

    nb.storeProvider:loadProducts(productsId, listener)
    return true
end

function Store.cancelLoadProducts()
    if not checkCCStore() then return false end
    nb.storeProvider:cancelLoadProducts()
end

function Store.isProductLoaded(productId)
    if not checkCCStore() then return false end
    return nb.storeProvider:isProductLoaded(productId)
end

function Store.purchase(productId, userInfo)
    if not checkCCStore() then return false end

    if not nb.storeProvider then
        printError("Store.purchase() - store not init")
        return false
    end

    if type(productId) ~= "string" then
        printError("Store.purchase() - invalid productId")
        return false
    end

    return nb.storeProvider:purchase(productId, userInfo or "")
end

function Store.restore()
    if not checkCCStore() then return false end
    nb.storeProvider:restore()
end

function Store.finishTransaction(transaction)
    if not checkCCStore() then return false end

    if not nb.storeProvider then
        printError("Store.finishTransaction() - store not init")
        return false
    end

    if type(transaction) ~= "table" or type(transaction.transactionIdentifier) ~= "string" then
        printError("Store.finishTransaction() - invalid transaction")
        return false
    end

    return nb.storeProvider:finishTransaction(transaction.transactionIdentifier)
end

nb.iOSPay = Store

return Store
