
local Juhua = class("Juhua", function()
        return display.newNode()
    end)
local SCREENW ,SCREENH = display.width ,display.height

function Juhua:ctor(params)
  SCREENW ,SCREENH = display.width ,display.height
  
  params = params or {}
  local msg = params.msg or "加载中..."
  local msgColor = params.msgColor or nb.c3b(255,255,255)
  local msgSize = params.msgSize or 25
  local alpha = params.alpha or 0
  local loadType = params.loadType or 1
  local canTouch = params.canTouch == nil and true or params.canTouch
  local loadFile = params.loadFile or "gamehall/res/common/common_juhua.png"
  local bgFile = params.bgFile or ""
  local callback = params.callback
  params.msg = msg
  params.msgColor = msgColor
  params.msgSize = msgSize
  params.alpha = alpha
  params.loadType = loadType
  params.canTouch = canTouch
  params.loadFile = loadFile
  params.bgFile = bgFile
  params.callback = callback
  params.offsetX = params.offsetX or 0
  params.offsetY = params.offsetY or 0
  self:createLoading(params)
  self:enableNodeEvents()
  self:performWithDelay(function ()
    if callback then
        callback()
    end
  end, 6)
end

function Juhua:createLoading(params)
  self.__layer = display.newLayer(nb.c4b(0,0,0,params.alpha))
  self.__layer:addTo(self)
  self.__layer:pos(-display.width/2,-display.height/2)
  self.__layer:setContentSize(SCREENW,SCREENH)
  if params.canTouch ==true then
    nb.bind(self.__layer,"touch"):setTouchEnabled(true)
  end

  local loadbg = ccui.ImageView:create()
  loadbg:loadTexture(params.bgFile,0)
  loadbg:addTo(self.__layer)
  loadbg:pos(SCREENW/2,SCREENH/2)

  local bgSz = loadbg:getContentSize()
  loadbg:setScaleX(display.width/bgSz.width)
  loadbg:setScaleY(display.height/bgSz.height)


   self.__tipMessage = display.newTTFLabel({
      text=params.msg, font="gamehall/res/fonts/FZHei-B01S.TTF",
      color = params.msgColor, 
      size = params.msgSize,
       align = nb.TEXT_ALIGNMENT_CENTER})
    :pos(SCREENW/2 + params.offsetX,SCREENH/2 + params.offsetY-70)
    :addTo(self.__layer)
  self:playAnimationOne(params)

end

function Juhua:playAnimationOne(params)
  self._loadingBar = display.newSprite(params.loadFile)
  :addTo(self.__layer) :pos(SCREENW/2 + params.offsetX,SCREENH/2 + params.offsetY)
  self._loadingBar:runAction(nb.RepeatForever:create(nb.RotateBy:create(1, 360)))
end

function Juhua:onEnter()
 
end

function Juhua:onExit()

end

return Juhua

