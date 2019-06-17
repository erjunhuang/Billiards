local TableData = CS.Billiards.TableData

local LogicalBall = CS.Billiards.LogicalBall
local VisualBall = CS.Billiards.VisualBall
local BallData = CS.Billiards.BallData
local Number2D = CS.Billiards.Number2D
local Matrix3D = CS.Billiards.Matrix3D
local Number3D = CS.Billiards.Number3D
local Rectangle = CS.Billiards.Rectangle
local CollisionEngine = CS.Billiards.CollisionEngine
local Collision = CS.Billiards.Collision

local n_cueBallX
local n_cueBallY 
local n_targetBallX             
local n_targetBallY    

local velocityPosA = Number2D()
local velocityPosB = Number2D()
local posB = Number2D()
local endP = Number2D()
local startP = Number2D(); 

local CueViewController = class("CueViewController")

local BALL_POINTS = 20;

function CueViewController:ctor(tableManager, linePre, collisionEngine, cueView)
    self.__tableManager = tableManager
    
	self._lineRendererPre = linePre;

	local cueViewTransform = cueView:GetComponent("Transform")
    local line = GameObject.Instantiate(linePre, cueViewTransform.parent);
    self._line = line:GetComponent("LineRenderer");
    self._line.useWorldSpace = false;
    line:GetComponent("Transform").localPosition = Vector3(0, 0, TableData.Aim_Layer);

    line = GameObject.Instantiate(linePre, cueViewTransform.parent);
    self._ball = line:GetComponent("LineRenderer");
    self._ball.useWorldSpace = false;
    line:GetComponent("Transform").localPosition = Vector3(0, 0, TableData.Aim_Layer);

    line = GameObject.Instantiate(linePre, cueViewTransform.parent);
    self._reboundLine = line:GetComponent("LineRenderer");
    self._reboundLine.useWorldSpace = false;
    line:GetComponent("Transform").localPosition = Vector3(0, 0, TableData.Aim_Layer);

    self._collisionEngine = collisionEngine;
    self._cueView = cueView;
    self._cueViewTransform = cueViewTransform


    self._line.positionCount = 2
    self._line.startColor = Color.white;
    self._line.endColor = Color.white;
    self._line.startWidth = 0.02
    self._line.endWidth = 0.02

    self._ball.positionCount = BALL_POINTS
    self._ball.startColor = Color.white
    self._ball.endColor = Color.white
    self._ball.startWidth = 0.02
    self._ball.endWidth = 0.02

    self._reboundLine.positionCount = 3;
    self._reboundLine.startColor = Color.white;
    self._reboundLine.endColor = Color.white;
    self._reboundLine.startWidth = 0.03
    self._reboundLine.endWidth = 0.03


    self._targetBall =  LogicalBall(self:getBilliardsConfig().BALL_RADIUS);
    self._cueBall =  LogicalBall(self:getBilliardsConfig().BALL_RADIUS);
    self._guideBall =  LogicalBall(self:getBilliardsConfig().BALL_RADIUS);
    self._aimBall = nil         -- 是否存在目标球

    self._logicVelocity = Number2D(0, 0)
end

function CueViewController:getBilliardsConfig()
    return self.__tableManager:getBilliardsConfig()
end

function CueViewController:getLogicVelocity()
    return self._logicVelocity
end

function CueViewController:DrawLine( vstart,  vend)
	--Vector3 vstart, Vector3 vend

    self._line.positionCount = 2;
    self._ball.positionCount = BALL_POINTS;
    local startScreenCoord = TableData.LogicToScreen(vstart.x, vstart.y);-- Number2D
    local endScreenCoord = TableData.LogicToScreen(vend.x, vend.y); -- Number2D
    self._line:SetPosition(0, Vector3(startScreenCoord.x, startScreenCoord.y, TableData.Aim_Layer));
    self._line:SetPosition(1, Vector3(endScreenCoord.x, endScreenCoord.y, TableData.Aim_Layer));
    local vec0 = Vector3.zero; --Vector3
    local n = BALL_POINTS - 1; -- int
    for i = 0,(n-1) do

        local x = Mathf.Cos((360 * (i + 1) / n) * Mathf.Deg2Rad) * self:getBilliardsConfig().BALL_RADIUS + vend.x; -- float
        local y = Mathf.Sin((360 * (i + 1) / n) * Mathf.Deg2Rad) * self:getBilliardsConfig().BALL_RADIUS + vend.y;-- float
        local screenCoord = TableData.LogicToScreen(x, y); -- Number2D
        local vector = Vector3(screenCoord.x, screenCoord.y, TableData.Aim_Layer);--Vector3
        if (i == 0) then

            vec0 = vector;
        end
        self._ball:SetPosition(i, vector);
    end
    self._ball:SetPosition(BALL_POINTS - 1, vec0);

end

function CueViewController:DrawReboundLine( velocityPosA,  velocityPosB,  dend,  draw)
	--Number2D velocityPosA, Number2D velocityPosB, Vector3 end, bool draw
    if (draw) then
        -- 画出来的两条线段看起来有点像切断了一样
        self._reboundLine.positionCount = 3;
        --母球回弹方向球心位置
        local screedCoord = TableData.LogicToScreen(velocityPosA.x, velocityPosA.y); -- Number2D
        self._reboundLine:SetPosition(0, Vector3(screedCoord.x, screedCoord.y, TableData.Aim_Layer));
        --母球碰撞点球心位置
        screedCoord = TableData.LogicToScreen(dend.x, dend.y);
        self._reboundLine:SetPosition(1, Vector3(screedCoord.x, screedCoord.y, TableData.Aim_Layer));
        --被碰球回弹方向球心位置
        screedCoord = TableData.LogicToScreen(velocityPosB.x, velocityPosB.y);
        self._reboundLine:SetPosition(2, Vector3(screedCoord.x, screedCoord.y, TableData.Aim_Layer));

    else

        self._reboundLine.positionCount = 0;
    end
end

function CueViewController:ShowAll()
    self._line.enabled = true;
    self._ball.enabled = true;
    self._reboundLine.enabled = true;
    self._cueView:GetComponent("Renderer").enabled = true;
end

function CueViewController:HideAll()

    -- print()
    self._line.enabled = false;
    self._ball.enabled = false;
    self._reboundLine.enabled = false;
    self._cueView:GetComponent("Renderer").enabled = false;
end

function CueViewController:ShowLine()
    self._line.enabled = true;
    self._ball.enabled = true;
    self._reboundLine.enabled = true;
end

function CueViewController:HideLine()
    self._line.enabled = false;
    self._ball.enabled = false;
    self._reboundLine.enabled = false;
end



function CueViewController:doBeatPowerAction(value, guide)
    -- print("CueViewController:doBeatPowerAction => ", value)
    local ballScreenCoord = TableData.LogicToScreen(guide.position.x, guide.position.y)-- Number2D
    local position = Vector3(ballScreenCoord.x, ballScreenCoord.y, TableData.Cue_Layer)
    self._cueViewTransform.localPosition = position
    -- TODO: 伸缩比例需要重新计算
    self._cueViewTransform.position = self._cueViewTransform.up * value * -1 + self._cueViewTransform.position
end

function CueViewController:UpdateAim( mouseX,  mouseY,  guide, onTableBalls)
	--float mouseX, float mouseY, LogicalBall guide, List<LogicalBall> onTableBalls
	-- print("UpdateAim")
    local guideX = guide.position.x; -- double
    local guideY = guide.position.y;-- double
    local mouseLogicCoord = TableData.ScreenToLogic(mouseX, mouseY);-- Number2D
    local ballScreenCoord = TableData.LogicToScreen(guide.position.x, guide.position.y);-- Number2D
    local angle = Collision.GetAngle((mouseLogicCoord.x - guideX), -(mouseLogicCoord.y - guideY));-- double
    self._logicVelocity.x = mouseLogicCoord.x - guideX
    self._logicVelocity.y = mouseLogicCoord.y - guideY

    self._cueViewTransform.localPosition = Vector3(ballScreenCoord.x, ballScreenCoord.y, TableData.Cue_Layer);
    self._cueViewTransform.rotation = Quaternion.Euler(Vector3(0, 0, ((angle * 180 / math.pi - 90))));
    self._guideBall.position.x = guide.position.x;
    self._guideBall.position.y = guide.position.y;

    self._targetBall:Init();
    self._cueBall:Init();


    local len; -- int
    self._aimBall = nil;
    startP.x = self._guideBall.position.x;
    startP.y = self._guideBall.position.y;
    self._guideBall.velocity.x = (mouseLogicCoord.x - self._guideBall.position.x);
    self._guideBall.velocity.y = (mouseLogicCoord.y - self._guideBall.position.y);

    self._guideBall.velocity:Normalise();
    targetBallNum = -1;

    local point = self._collisionEngine:FindFirstCollisionBall(self._guideBall, Double.PositiveInfinity)
    -- print(Double.PositiveInfinity,"Double.PositiveInfinity")

    if (point ~= nil) then
        endP.x = (self._guideBall.position.x + (self._guideBall.velocity.x * point.time));

        endP.y = (self._guideBall.position.y + (self._guideBall.velocity.y * point.time));

        if (point.ballB ~= -1) then
            -- print("point",point.ballB)

            local ballA = onTableBalls[point.ballA]; --LogicalBall
            local bB = onTableBalls[point.ballB];

            posB.x = bB.position.x;
            posB.y = bB.position.y;

            self._targetBall.position.x = bB.position.x;
            self._targetBall.position.y = bB.position.y;

            self._cueBall.velocity.x = self._guideBall.velocity.x;
            self._cueBall.velocity.y = self._guideBall.velocity.y;

            self._cueBall.position.x = endP.x;
            self._cueBall.position.y = endP.y;
            Collision.BallBallCollision(self._cueBall, self._targetBall);
            n_cueBallX = self._cueBall.velocity.x;
            n_cueBallY = self._cueBall.velocity.y;
            n_targetBallX = self._targetBall.velocity.x;
            n_targetBallY = self._targetBall.velocity.y;

            local velX = (ballA.velocity.x - bB.velocity.x); -- double
            local velY = (ballA.velocity.y - bB.velocity.y); -- double
            len = math.modf(10 + ((20 * math.max((250 - math.sqrt(((velX * velX) + (velY * velY)))), 0)) / 250));
            self._targetBall.velocity:MultiplyEq(len);
            self._cueBall.velocity:MultiplyEq(len);
            velocityPosA.x = (endP.x + self._cueBall.velocity.x);
            velocityPosA.y = (endP.y + self._cueBall.velocity.y);
            velocityPosB.x = (posB.x + self._targetBall.velocity.x);
            velocityPosB.y = (posB.y + self._targetBall.velocity.y);
            self._aimBall = bB;
            targetBallNum = math.modf(bB.number); -- int
        end
    end
    -- do return end
    local start = Vector3(startP.x, startP.y, TableData.Aim_Layer);--Vector3
    local enda = Vector3(endP.x, endP.y, TableData.Aim_Layer);--Vector3
    self:DrawLine(start, enda);
    local draw = self._aimBall ~= nil and true or false;--bool
    self:DrawReboundLine(velocityPosA, velocityPosB, enda, draw);
end

return CueViewController