--- 桌球相关配置
-- TODO: 改为非静态的
local BilliardsConfig = {}

--- 角度转弧度
BilliardsConfig.DEGREE_TO_RADIAN = 0.0174532925199433
--- 弧度转角度
BilliardsConfig.RADION_TO_DEGREE = 57.2957795130823

--- 包括母球在内的球的个数
BilliardsConfig.BALL_COUNT = 16
--- 球的逻辑半径
BilliardsConfig.BALL_RADIUS = 11
--- 摆球时两个球之间的逻辑间隔
BilliardsConfig.GAP_BETWEEN_BALL = 0.5

--- 球桌的内边缘矩形 {x, y, width, height}
BilliardsConfig.TABLE_RECT = {-792.7 / 2, -394.85 / 2, 792.7, 394.85,}

BilliardsConfig.TABLE_BREAK_RECT = {-792.7 / 2, -394.85 / 2, 162, 394.85,}

--- 球桌上6个球洞/袋的判断点
BilliardsConfig.POCKET_POS = {
    { -404, -205 }, { 404, -205 }, { -404, 205 },
    { 404, 205 }, { 0, 215 }, { 0, -215 },
}

--- 图层/z轴
BilliardsConfig.BALL_LAYER = -0.5
BilliardsConfig.CUE_LAYER = -1.0
BilliardsConfig.SHADOW_LAYER = -0.2
BilliardsConfig.HIGHLIGHT_LAYER = -0.9
BilliardsConfig.AIM_LAYER = -1

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

return BilliardsConfig