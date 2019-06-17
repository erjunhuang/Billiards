

local EventObject = class("EventObject")

function EventObject:ctor()
    -- cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    nb.bind(self,"event")
end

return EventObject