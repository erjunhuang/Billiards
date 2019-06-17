using System;
using System.Collections.Generic;
using UnityEngine;
namespace Billiards
{
    public class CollisionEngine
    {
        private int _ballCount;
        private Rectangle _rect = BallEngineConfig.TABLE_RECT;
        public int firstCollistionBall = 0;

        /// <summary>
        /// 所有游戏逻辑球列表（包括母球和已经进袋的球）
        /// </summary>
        /// <typeparam name="LogicalBall"></typeparam>
        private List<LogicalBall> _allBalls = new List<LogicalBall>();
        /// <summary>
        /// 球洞/入洞判断点
        /// </summary>
        /// <typeparam name="Number2D"></typeparam>
        private List<Number2D> _pocketArr = new List<Number2D>();
        /// <summary>
        /// 球桌顶点，连起来是一个密闭的多边形
        /// </summary>
        /// <typeparam name="Number2D"></typeparam>
        private List<Number2D> _vertex = new List<Number2D>();

        private List<CollisionData> allCollisionList = new List<CollisionData>();
        private List<CollisionData> curTimeCollisionList = new List<CollisionData>();

        /// <summary>
        /// 引擎初始化，传入计算所需要的数据
        /// </summary>
        /// <param name="allBalls"></param>
        /// <param name="pocketArr"></param>
        /// <param name="vertex"></param>
        public void Init(List<LogicalBall> allBalls, List<Number2D> pocketArr, List<Number2D> vertex)
        {
            _allBalls = allBalls;
            _pocketArr = pocketArr;
            _vertex = vertex;
        }

        /// <summary>
        /// 更新所有游戏中的球的角速度和线速度
        /// </summary>
        /// <param name="time"></param>
        /// <returns></returns>
        public bool UpdateAllVelocity(double time)
        {
            bool isMove = false;
            for (int index = 0, len = _allBalls.Count; index < len; ++index)
            {
                LogicalBall ball = _allBalls[index];
                if (ball.state == LogicalBall.nSTATE_IN_PLAY)
                {
                    // 角速度不为0
                    if (ball.w.x != 0 || ball.w.y != 0 || ball.w.z != 0)
                    {
                        ball.Rotate(time);
                        isMove = true;
                    }
                    Collision.UpdateVelocity(ball, time);
                }
            }
            return isMove;
        }

        public bool RunBallCollision(double time)
        {
            double t = time;
            bool isMove = false;
            _ballCount = _allBalls.Count;
            while (t > Collision.MIN)
            {
                double collisionT = t;
                List<CollisionData> collisionTimeList = FindTableFistCollisionBall(t);
                int length = collisionTimeList.Count;

                if (length > 0)
                {
                    CollisionData point = collisionTimeList[0];
                    collisionT = point.time;
                }
                for (int index = 0; index < _ballCount; ++index)
                {
                    LogicalBall ball = (_allBalls[index] as LogicalBall);
                    if (ball.state == LogicalBall.nSTATE_IN_PLAY && ball.IsMovingOrSpinning == true)
                    {
                        ball.Move(collisionT);
                        if (isMove == false && ball.IsMoving == true)
                        {
                            isMove = true;
                        }
                    }
                }
                if (length > 0)
                {
                    for (int i = 0; i < length; ++i)
                    {
                        CollisionData point = collisionTimeList[i];
                        TurnCollision(point);
                    }
                }
                t = t - collisionT;
            }
            isMove = UpdateAllVelocity(time) || isMove;
            return isMove;
        }

        public CollisionData FindFirstCollisionBall(LogicalBall ball, double time)
        {
            CollisionData collisionPoint = null;
            double shortTime = time;//两球碰撞的最短时间
                                    // 小值为start，大值为end
            double xStart = 0;
            double xEnd = 0;
            double yStart = 0;
            double yEnd = 0;

            if (ball.state == LogicalBall.nSTATE_IN_PLAY)
            {
                // 只遍历此球id之后的，因为之前id的球会包含一次对此球的碰撞检测
                for (int index = (int)ball.number + 1, len = _allBalls.Count; index < len; ++index)
                {
                    LogicalBall ball2 = _allBalls[index];
                    if (ball2.state == LogicalBall.nSTATE_IN_PLAY)
                    {
                        double t = Collision.BallBallCollisionTime(ball, ball2, shortTime);
                        if (t < shortTime)
                        {
                            collisionPoint = new CollisionData((int)ball.number, (int)ball2.number, t, 0, 0);
                            shortTime = t;
                        }
                    }
                }
            }
            if (ball.velocity.x > 0)
            {
                xStart = ball.position.x;
                xEnd = ball.position.x + ball.velocity.x * time;
            }
            else
            {
                xStart = ball.position.x + ball.velocity.x * time;
                xEnd = ball.position.x;
            }
            if (ball.velocity.y > 0)
            {
                yStart = ball.position.y;
                yEnd = ball.position.y + ball.velocity.y;
            }
            else
            {
                yStart = ball.position.y + ball.velocity.y;
                yEnd = ball.position.y;
            }

            double radius = ball.radius + 2;
            if (xStart < (_rect.left + radius) || xEnd > (_rect.right - radius) || yStart < (_rect.top + radius) || yEnd > (_rect.bottom - radius))
            {
                for (int index = 0, len = _pocketArr.Count; index < len; ++index)
                {
                    Number2D poketPoint = _pocketArr[index];
                    double xdist = poketPoint.x - ball.position.x;
                    double ydist = poketPoint.y - ball.position.y;
                    double pocketDist = Math.Sqrt(xdist * xdist + ydist * ydist);

                    // 入袋检测
                    if (pocketDist < 15)
                    {
                        // 给球一个向球袋移动的速度修正（目的是让球被“吸”进去，更容易进洞）
                        ball.velocity.Add(xdist * 40 * time, ydist * 40 * time);
                        if (pocketDist < 10)
                        {
                            ball.state = LogicalBall.nSTATE_IN_POCKET;          // 进洞了 
                            ball.pocketNum = index;
                            ball.StopMoving();
                            break;
                        }
                    }
                }

                for (int index = 0, len = _vertex.Count; index < len; ++index)
                {
                    Number2D startPoint = _vertex[index];
                    Number2D endPoint = _vertex[(index + 1) % len];
                    double t = Collision.BallLineCollisionTime(ball, startPoint, endPoint, shortTime);
                    if (t < shortTime)
                    {
                        collisionPoint = new CollisionData((int)ball.number, -1, t, endPoint.x - startPoint.x, endPoint.y - startPoint.y);
                        shortTime = t;
                    }
                    Number2D vertex = _vertex[index];
                    t = Collision.BallPointCollisionTime(ball, vertex, shortTime);
                    if (t < shortTime)
                    {

                        double xVel = (ball.position.x - vertex.x);
                        double yVel = (vertex.y - ball.position.y);

                        collisionPoint = new CollisionData((int)ball.number, -1, t, yVel, xVel);
                        shortTime = t;
                    }
                }
            }
            return collisionPoint;
        }

        public void TurnCollision(CollisionData point)
        {
            LogicalBall ballA = _allBalls[point.ballA];

            if (point.ballB == -1)
            {
                Collision.BallLineCollision(ballA, Collision.GetAngle(point.x, point.y));
            }
            else
            {
                LogicalBall ballB = _allBalls[point.ballB];
                Collision.BallBallCollision(ballA, ballB);
                if (firstCollistionBall == 0)
                {
                    firstCollistionBall = point.ballB;
                }
            }
        }

        /// <summary>
        /// 找出在给定时间内最早发生的碰撞列表
        /// </summary>
        /// <param name="time"></param>
        /// <returns></returns>
        public List<CollisionData> FindTableFistCollisionBall(double time)
        {
            allCollisionList.Clear();
            curTimeCollisionList.Clear();
            double minTime = Double.MaxValue;
            for (int index = 0; index < _ballCount; ++index)
            {
                LogicalBall ball = _allBalls[index];
                if (ball.state == LogicalBall.nSTATE_IN_PLAY)
                {
                    CollisionData p = FindFirstCollisionBall(ball, time);
                    if (p != null)
                    {
                        if (p.time < minTime)
                        {
                            minTime = p.time;
                        }
                        allCollisionList.Add(p);
                    }
                }
            }
            if (allCollisionList.Count > 0)
            {
                for (int index = 0; index < allCollisionList.Count; ++index)
                {
                    if (allCollisionList[index].time == minTime)
                    {
                        curTimeCollisionList.Add(allCollisionList[index]);
                    }
                }
            }
            return curTimeCollisionList;
        }
    }
}
