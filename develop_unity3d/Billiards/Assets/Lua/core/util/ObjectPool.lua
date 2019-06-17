
local ObjectPool = class("ObjectPool")

function ObjectPool:ctor(objectFactory, needRetain, initObjectNum, maxObjectNum, createOnNeed)
    assert(type(objectFactory) == "function", "objectFactory should be a function")
    self.objectFactory_ = objectFactory
    self.needRetain_ = needRetain
    self.initObjectNum_ = initObjectNum
    self.maxObjectNum_  = maxObjectNum
    self.objectPool_    = {}

    if not createOnNeed then
        for i = 1, self.initObjectNum_ do
            self.objectPool_[i] = self.objectFactory_()
            if self.needRetain_ then
                self.objectPool_[i]:retain()
            end
        end
    end
end

-- 从对象池获取一个对象，将内存管理交给使用者
function ObjectPool:retrive()
    local returnObj
    if #self.objectPool_ > 0 then
        returnObj = table.remove(self.objectPool_)
    else
        returnObj = self.objectFactory_()
        if self.needRetain_ then
            returnObj:retain()
        end
    end
    return returnObj
end

-- 回收一个对象
function ObjectPool:recycle(obj)
    table.insert(self.objectPool_, obj)
    if self.maxObjectNum_ then
        while #self.objectPool_ > self.maxObjectNum_ do
            if self.needRetain_ then
                table.remove(self.objectPool_):release()
            else
                table.remove(self.objectPool_)
            end
        end
    end
    return self
end

-- 清理
function ObjectPool:dispose()
    if self.objectPool_ then
        for _, obj in pairs(self.objectPool_) do
            obj:release()
        end
    end
    self.objectPool_ = nil
end

return ObjectPool