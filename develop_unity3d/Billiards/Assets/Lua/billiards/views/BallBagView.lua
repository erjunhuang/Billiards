local BallBagView = class('BallBagView')

function BallBagView:ctor(ctx, view)
    self.__view = view
    self.__ctx = ctx
    self.__tableMananger = ctx.tableManager

    self.__inPocketLogicalBalls = {}
end

function BallBagView:addBall(logicalBall)
    table.insert(self.__inPocketLogicalBalls, logicalBall)
end

function BallBagView:getInPocketLogicalBallsCount()
    return #self.__inPocketLogicalBalls
end

function BallBagView:getInPocketLogicalBalls()
    return self.__inPocketLogicalBalls
end

function BallBagView:reset()
    self.__inPocketLogicalBalls = {}
end

return BallBagView
