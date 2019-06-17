local LuaMath = import("..math.LuaMath")

--- 桌球相关配置
-- TODO: 改为非静态的
local BilliardsConfig = {}

--- 角度转弧度
BilliardsConfig.DEGREE_TO_RADIAN = LuaMath.DEGREE_TO_RADIAN
--- 弧度转角度
BilliardsConfig.RADION_TO_DEGREE = LuaMath.RADION_TO_DEGREE

--- 包括母球在内的球的个数
BilliardsConfig.BALL_COUNT = 16
--- 球的逻辑半径
BilliardsConfig.BALL_RADIUS = 11
--- 摆球时两个球之间的逻辑间隔
BilliardsConfig.GAP_BETWEEN_BALL = 0.5
--- 物理碰撞检测的筛选间隔
BilliardsConfig.COLLISION_DETECTION_GAP = 2

--- 球靠近球洞判定距离
BilliardsConfig.NEAR_POCKET_DETECTION_GAP = 20
BilliardsConfig.NEAR_POCKET_DETECTION_GAP_SQUARED = BilliardsConfig.NEAR_POCKET_DETECTION_GAP * BilliardsConfig.NEAR_POCKET_DETECTION_GAP

--- 球掉进球动判定距离
BilliardsConfig.DROP_IN_POCKET_DETECTION_GAP = 10
BilliardsConfig.DROP_IN_POCKET_DETECTION_GAP_SQUARED = BilliardsConfig.DROP_IN_POCKET_DETECTION_GAP * BilliardsConfig.DROP_IN_POCKET_DETECTION_GAP

--- 球桌的内边缘矩形 {x, y, width, height}
BilliardsConfig.TABLE_RECT = {-792.7 / 2, -394.85 / 2, 792.7, 394.85}

--- 球桌白球发球区域矩形
BilliardsConfig.TABLE_BREAK_RECT = {-792.7 / 2, -394.85 / 2, 162, 394.85}

--- 球桌上6个球洞/袋的判断点
BilliardsConfig.POCKET_POS = {
    { -404, -205 }, { 404, -205 }, { -404, 205 },
    { 404, 205 }, { 0, 215 }, { 0, -215 },
}

--- 图层/z轴
-- 球
BilliardsConfig.BALL_LAYER = -0.5
-- 球杆
BilliardsConfig.CUE_LAYER = -1.0
-- 阴影
BilliardsConfig.SHADOW_LAYER = -0.2
-- 高光
BilliardsConfig.HIGHLIGHT_LAYER = -0.9
-- 瞄准线
BilliardsConfig.AIM_LAYER = -1
-- 球袋
BilliardsConfig.BALL_BAG_LAYER = 2
-- 在球袋中的球
BilliardsConfig.BALL_IN_BAG_LAYER = 1
-- 球桌
BilliardsConfig.TABLE_LAYER = 0

--- 像素/单位
BilliardsConfig.PIXELS_PER_UNIT = 100


BilliardsConfig.POCKET_LEFT = nil
BilliardsConfig.POCKET_RIGHT = nil
BilliardsConfig.POCKET_BOTTOM = nil
BilliardsConfig.POCKET_TOP = nil

do
    for i, pos in ipairs(BilliardsConfig.POCKET_POS) do
        local x, y = pos[1], pos[2]

        if BilliardsConfig.POCKET_LEFT then

            if x < BilliardsConfig.POCKET_LEFT then
                BilliardsConfig.POCKET_LEFT = x
            end

            if x > BilliardsConfig.POCKET_RIGHT then
                BilliardsConfig.POCKET_RIGHT = x
            end

            if y < BilliardsConfig.POCKET_BOTTOM then
                BilliardsConfig.POCKET_BOTTOM = y
            end

            if y > BilliardsConfig.POCKET_TOP then
                BilliardsConfig.POCKET_TOP = y
            end

        else
            BilliardsConfig.POCKET_LEFT = x
            BilliardsConfig.POCKET_RIGHT = x
            BilliardsConfig.POCKET_BOTTOM = y
            BilliardsConfig.POCKET_TOP = y
        end
    end
end

--- 用于计算逻辑运算与绘制的坐标变换
BilliardsConfig.WIDTH = BilliardsConfig.POCKET_RIGHT - BilliardsConfig.POCKET_LEFT
BilliardsConfig.HEIGHT = BilliardsConfig.POCKET_TOP - BilliardsConfig.POCKET_BOTTOM

--- 球桌的顶点列表，其球洞判断点包含在这个定点连成的多边形中
BilliardsConfig.TABLE_POINTS = {
    { -371, -198 }, { -412, -226 }, { -426, -212 }, { -397, -172 },
    { -397, 172}, { -426, 212}, { -413, 226}, {-371, 198},
    { -27, 197 }, { -14, 211 }, {-11, 231 }, {11, 231 },{14,211 },{27,197 },
    { 371, 198 }, {413, 226 }, {426, 212 }, {397, 172 },
    { 397, -172}, {426, -212}, {412, -226}, {371, -198},
    { 27,-197 },{14,-211 },{11,-231 },{-11,-231 },{-14,-211 },{-27,-197 },
}

--- 物理引擎时间步的间隔
BilliardsConfig.TIME = 0.03 / 2

--- 球杆击打母球的初速度系数
BilliardsConfig.START_VELOCITY = 15

--- 母球之外的球的初始位置参考点
BilliardsConfig.NON_CUE_BALL_REFERENCE_POS = {218, 0}

--- 母球之外的球的初始位置点
BilliardsConfig.NON_CUE_BALL_POSITIONS = {}

do
    local startPos = BilliardsConfig.NON_CUE_BALL_REFERENCE_POS
    local xPos = startPos[1]
    local y = startPos[2]
    local gapSpace = BilliardsConfig.BALL_RADIUS + BilliardsConfig.GAP_BETWEEN_BALL
    local xPosStep = math.sqrt(3) * gapSpace
    local row = 0;
    local curR = 0;
    for i = 1, BilliardsConfig.BALL_COUNT - 1, 1 do
        local pos = { xPos, y + row * gapSpace - curR * 2 * gapSpace }
        BilliardsConfig.NON_CUE_BALL_POSITIONS[i] = pos

        curR = curR + 1
        if curR > row then
            curR = 0
            xPos = xPos + xPosStep
            row = row + 1
        end
    end
end

--- 母球初始位置
BilliardsConfig.CUE_BALL_POS = {-234, -50}

BilliardsConfig.IN_POCKET_POS_START = {-382, -152}
BilliardsConfig.IN_POCKET_POS_MID = {-450, -152}
BilliardsConfig.IN_POCKET_POS_END = {-450, 154}

--- 在球袋里滚动的总距离
BilliardsConfig.IN_POCKET_ROLLING_TOTAL_LENGTH =
    math.abs(BilliardsConfig.IN_POCKET_POS_START[1] - BilliardsConfig.IN_POCKET_POS_MID[1]) +
    math.abs(BilliardsConfig.IN_POCKET_POS_END[2] - BilliardsConfig.IN_POCKET_POS_MID[2])

-- --- DEBUG
-- BilliardsConfig.NON_CUE_BALL_POSITIONS[1] = BilliardsConfig.IN_POCKET_POS_START
-- BilliardsConfig.NON_CUE_BALL_POSITIONS[2] = BilliardsConfig.IN_POCKET_POS_MID
-- BilliardsConfig.NON_CUE_BALL_POSITIONS[3] = BilliardsConfig.IN_POCKET_POS_END

return BilliardsConfig