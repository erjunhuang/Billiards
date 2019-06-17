
--------------------------------
-- @module CCArmatureDisplay
-- @extend Node,IArmatureDisplay
-- @parent_module db

--------------------------------
-- 
-- @function [parent=#CCArmatureDisplay] getAnimation 
-- @param self
-- @return Animation#Animation ret (return value: db.Animation)
        
--------------------------------
-- 
-- @function [parent=#CCArmatureDisplay] setTimeScale 
-- @param self
-- @param #float scale
-- @return CCArmatureDisplay#CCArmatureDisplay self (return value: db.CCArmatureDisplay)
        
--------------------------------
-- 
-- @function [parent=#CCArmatureDisplay] advanceTimeBySelf 
-- @param self
-- @param #bool on
-- @return CCArmatureDisplay#CCArmatureDisplay self (return value: db.CCArmatureDisplay)
        
--------------------------------
-- 
-- @function [parent=#CCArmatureDisplay] removeEvent 
-- @param self
-- @param #string type
-- @return CCArmatureDisplay#CCArmatureDisplay self (return value: db.CCArmatureDisplay)
        
--------------------------------
--  @private 
-- @function [parent=#CCArmatureDisplay] dispose 
-- @param self
-- @return CCArmatureDisplay#CCArmatureDisplay self (return value: db.CCArmatureDisplay)
        
--------------------------------
-- 
-- @function [parent=#CCArmatureDisplay] getArmature 
-- @param self
-- @return Armature#Armature ret (return value: db.Armature)
        
--------------------------------
-- 
-- @function [parent=#CCArmatureDisplay] setFrameEventListener 
-- @param self
-- @param #function listener
-- @return CCArmatureDisplay#CCArmatureDisplay self (return value: db.CCArmatureDisplay)
        
--------------------------------
-- 
-- @function [parent=#CCArmatureDisplay] addEvent 
-- @param self
-- @param #string type
-- @param #function callback
-- @return CCArmatureDisplay#CCArmatureDisplay self (return value: db.CCArmatureDisplay)
        
--------------------------------
-- 
-- @function [parent=#CCArmatureDisplay] hasEvent 
-- @param self
-- @param #string type
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#CCArmatureDisplay] setAnimationEventListener 
-- @param self
-- @param #function listener
-- @return CCArmatureDisplay#CCArmatureDisplay self (return value: db.CCArmatureDisplay)
        
--------------------------------
--  @private 
-- @function [parent=#CCArmatureDisplay] create 
-- @param self
-- @return CCArmatureDisplay#CCArmatureDisplay ret (return value: db.CCArmatureDisplay)
        
--------------------------------
--  @private 
-- @function [parent=#CCArmatureDisplay] update 
-- @param self
-- @param #float passedTime
-- @return CCArmatureDisplay#CCArmatureDisplay self (return value: db.CCArmatureDisplay)
        
return nil
