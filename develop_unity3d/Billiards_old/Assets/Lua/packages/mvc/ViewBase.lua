
local ViewBase = class("ViewBase", nb.Node)

function ViewBase:ctor(app, name)
    self:enableNodeEvents()
    self:setCascadeOpacityEnabled(true)
    self:setCascadeColorEnabled(true)
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResoueceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResoueceBinding(binding)
    end

    local lres = rawget(self.class,"LRESOURCE_FILENAME")
    if lres then
        self:createLResoueceNode(lres)
    end

    if self.onCreate then self:onCreate() end
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end


function ViewBase:createLResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end

    local function callBackProvider(luaFileName,node,callbackName)
        return function(...)
            if self[callbackName] ~= nil then
                self[callbackName](self, node,...)
            else
                printLog('warring',"please define click event %s on view %s",callbackName,name)
            end
        end
    end


    self.__node = import(resourceFilename).create(callBackProvider)
    self.resourceNode_ = self.__node.root
    -- self.resourceNode_:size(display.width,display.height)
    self.resourceNode_:addTo(self)
    self.resourceNode_:setCascadeOpacityEnabled(true)
    self.resourceNode_:setCascadeColorEnabled(true)
    -- ccui.Helper:doLayout(self.resourceNode_)

end

function ViewBase:doLayout(size)
    size = size or nb.size(display.width,display.height)
    self.resourceNode_:size(size.width,size.height)
    ccui.Helper:doLayout(self.resourceNode_)
end

function ViewBase:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = nb.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function ViewBase:createResoueceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.resourceNode_:getChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            end
        end
    end
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

return ViewBase
