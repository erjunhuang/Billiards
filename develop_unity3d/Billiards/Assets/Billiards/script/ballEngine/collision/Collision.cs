using System;
namespace Billiards
{


    public class Collision
    {
        private const double DOPE = 0.804;
        private const double SLID_FORCE_SIDE = 0.7;
        private const double SLID_FORCE = 0.4;//滑动力量
        private const double ROLL_FORCE = 0.02;//滚动力量
        public const double turnI = 2.5;
        
        /// <summary>
        /// 球最小线速度标量
        /// 碰撞时间的最小单位
        /// </summary>
        public const double MIN = 1E-11;
        public const double ROLL_PARENT = 0.285714;
        private const double MASS = 980;
        private const double BL_COLLISION = 0.54;
        private const double SLID_RESISTANCE = MASS * SLID_FORCE;
        private const double ROLL_RESISTANCE = MASS * ROLL_FORCE;

        public static double BallBallCollisionTime(LogicalBall ball1, LogicalBall ball2, double time)
        {
            double t;
            double radiusDist = (ball1.radius + ball2.radius);
            double distPosX = (ball1.position.x - ball2.position.x);
            double distPosY = (ball1.position.y - ball2.position.y);
            double distVelX = (ball1.velocity.x - ball2.velocity.x);
            double distVelY = (ball1.velocity.y - ball2.velocity.y);

            double a = (distVelX * distVelX) + (distVelY * distVelY);       // 速度标量	
            if (a < MIN)
            {
                //速度小到可以忽略了 
                return Double.PositiveInfinity;
            }
            double b = (distPosX * distVelX) + (distPosY * distVelY);
            if (b >= 0)
            {
                return Double.PositiveInfinity;
            }

            double c = (distPosX * distPosX) + (distPosY * distPosY) - (radiusDist * radiusDist);
            double d = (b * b) - (a * c);
            if (d < 0)
            {
                return Double.PositiveInfinity;
            }
            t = (-(b) - Math.Sqrt(d)) / a;
            if ((t <= 0) && (t > -MIN))
            {
                return MIN;
            }
            if ((t - MIN) > time)
            {
                return Double.PositiveInfinity;
            }
            return t;
        }

        /// <summary>
        /// 球与球发生碰撞后两球线速度的变化
        /// </summary>
        /// <param name="ball1"></param>
        /// <param name="ball2"></param>
        public static void BallBallCollision(LogicalBall ball1, LogicalBall ball2)
        {
            double lenX = ball2.position.x - ball1.position.x;
            double lenY = ball2.position.y - ball1.position.y;
            double angle = Math.Atan2(lenY, lenX);
            double cos = Math.Cos(angle);
            double sin = Math.Sin(angle);
            Number2D vel0 = RotateCalculate(ball1.velocity.x, ball1.velocity.y, sin, cos, true);
            Number2D vel1 = RotateCalculate(ball2.velocity.x, ball2.velocity.y, sin, cos, true);
            double vxTotal = (vel0.x - vel1.x);
            vel0.x = vel1.x;
            vel1.x = (vxTotal + vel0.x);
            Number2D vel0F = RotateCalculate(vel0.x, vel0.y, sin, cos, false);
            Number2D vel1F = RotateCalculate(vel1.x, vel1.y, sin, cos, false);
            ball1.velocity.x = vel0F.x;
            ball1.velocity.y = vel0F.y;
            ball2.velocity.x = vel1F.x;
            ball2.velocity.y = vel1F.y;
        }

        public static void UpdateVelocity(LogicalBall ball, double time)
        {
            if (ball.state != LogicalBall.nSTATE_IN_PLAY || !ball.IsMovingOrSpinning)
            {
                return;
            }

            double vpX = -ball.velocity.x - ball.w.y * ball.radius;
            double vpY = -ball.velocity.y + ball.w.x * ball.radius;
            double vpLen = Math.Sqrt(vpX * vpX + vpY * vpY);
            double t = ROLL_PARENT * vpLen / SLID_RESISTANCE;

            if (t > MIN)
            {
                double sildTime = Math.Min(t, time);
                double velPre = sildTime * SLID_RESISTANCE / vpLen;
                vpX = vpX * velPre;
                vpY = vpY * velPre;
                ball.velocity.x = ball.velocity.x + vpX;
                ball.velocity.y = ball.velocity.y + vpY;
                ball.w.x = ball.w.x - turnI * vpY / ball.radius;
                ball.w.y = ball.w.y + turnI * vpX / ball.radius;
            }

            if (t < time)
            {
                double rollTime = time - t;
                double velPre = ROLL_RESISTANCE * rollTime / ball.velocity.Modulo;
                ball.velocity.Scale(Math.Max(0, 1 - velPre));
                ball.w.x = ball.velocity.y / ball.radius;
                ball.w.y = -ball.velocity.x / ball.radius;
            }

            double addZ = SLID_FORCE / turnI * MASS * time;

            if (ball.w.z > 0)
            {
                ball.w.z = Math.Max(0, ball.w.z - addZ);
            }
            else
            {
                ball.w.z = Math.Min(0, ball.w.z + addZ);
            }
        }


        /// <summary>
        /// 二维向量(逆时针)旋转
        /// 假设旋转角度为B
        /// 正向（逆时针）旋转： 
        /// x1 = x0 * cosB + y0 * sinB
        /// y1 = -x0 * sinB + y0 * cosB
        /// 反向（顺时针）旋转：
        /// x1 = x0 * cosB - y0 * sinB
        /// y1 = x0 * sinB + y0 * cosB
        /// TODO: 性能优化
        /// </summary>
        /// <param name="xpos"></param>
        /// <param name="ypos"></param>
        /// <param name="sin">旋转角度的sin值</param>
        /// <param name="cos">旋转角度的cos值</param>
        /// <param name="reverse">是否反向旋转</param>
        /// <returns></returns>
        private static Number2D RotateCalculate(double xpos, double ypos, double sin, double cos, bool reverse)
        {
            Number2D resultPoint = new Number2D();
            if (reverse)
            {
                // 顺时针
                resultPoint.x = xpos * cos + ypos * sin;
                resultPoint.y = -xpos * sin + ypos * cos;
            }
            else
            {
                // 逆时针
                resultPoint.x = xpos * cos - ypos * sin;
                resultPoint.y = xpos * sin + ypos * cos;
            }
            return resultPoint;
        }

        /// <summary>
        /// 球与顶点发生碰撞的碰撞时间
        /// </summary>
        /// <param name="ball"></param>
        /// <param name="p"></param>
        /// <param name="time"></param>
        /// <returns></returns>
        public static double BallPointCollisionTime(LogicalBall ball, Number2D p, double time)
        {
            double velocityLen = ball.velocity.x * ball.velocity.x + ball.velocity.y * ball.velocity.y;
            double lenX = p.x - ball.position.x;
            double lenY = p.y - ball.position.y;
            double b = -ball.velocity.x * lenX - ball.velocity.y * lenY;
            double len = lenX * lenX + lenY * lenY;
            double a = velocityLen;
            double bDouble = b * b;
            double rDouble = ball.radius * ball.radius;
            if ((-bDouble / a + len) >= rDouble)
            {
                return Double.PositiveInfinity;
            }
            double t = (-b - Math.Sqrt(bDouble - a * (len - rDouble))) / velocityLen;
            if (t <= MIN || (t - MIN) > time)
            {
                return Double.PositiveInfinity;
            }
            return t;
        }

        /// <summary>
        /// 貌似等价于Math.Atan2
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <returns></returns>
        public static double GetAngle(double x, double y)
        {
            if (x == 0)
            {
                return y >= 0 ? Math.PI / 2 : -Math.PI / 2;
            }
            double angle = Math.Atan(y / x);
            angle = x < 0 ? (angle + Math.PI) : angle;
            return angle;
        }

        /// <summary>
        /// 球与边发生碰撞
        /// </summary>
        /// <param name="ball"></param>
        /// <param name="angle"></param>
        public static void BallLineCollision(LogicalBall ball, double angle)
        {
            double cosA = Math.Cos(-angle);
            double sinA = Math.Sin(-angle);
            double velocityX = ball.velocity.x * cosA - ball.velocity.y * sinA;
            double velocityY = ball.velocity.x * sinA + ball.velocity.y * cosA;

            double angleX = ball.w.x * cosA - ball.w.y * sinA;
            double angleY = ball.w.x * sinA + ball.w.y * cosA;
            angleX = angleX - (velocityY * BL_COLLISION / ball.radius);

            double angleZ = velocityX - (ball.w.z * ball.radius);
            double absZ = Math.Abs(angleZ);
            double minZ = Math.Min((absZ / turnI), SLID_FORCE_SIDE * SLID_FORCE_SIDE * Math.Abs(velocityY));
            double addZ = absZ == 0 ? 0 : (-angleZ * minZ) / absZ;
            velocityX = velocityX + addZ;
            ball.w.z = ball.w.z - (turnI * addZ) / ball.radius;
            velocityY = -velocityY * DOPE;

            ball.velocity.x = cosA * velocityX + sinA * velocityY;
            ball.velocity.y = -sinA * velocityX + cosA * velocityY;

            ball.w.x = cosA * angleX + sinA * angleY;
            ball.w.y = -sinA * angleX + cosA * angleY;
        }

        /// <summary>
        /// 计算球与线段的碰撞时间
        /// </summary>
        /// <param name="ball"></param>
        /// <param name="pStart">线段的起点</param>
        /// <param name="pEnd">线段的终点</param>
        /// <param name="time"></param>
        /// <returns></returns>
        public static double BallLineCollisionTime(LogicalBall ball, Number2D pStart, Number2D pEnd, double time)
        {
            double lenX = pEnd.x - pStart.x;
            double lenY = pEnd.y - pStart.y;
            double angle = Math.Atan2(lenY, lenX);
            double cos = Math.Cos(angle);
            double sin = Math.Sin(angle);

            Number2D velBall = RotateCalculate(ball.velocity.x, ball.velocity.y, sin, cos, true);

            if (velBall.y <= 0)
            {
                return Double.PositiveInfinity;
            }

            Number2D startP = RotateCalculate(pStart.x, pStart.y, sin, cos, true);

            Number2D ballPos = RotateCalculate(ball.position.x, ball.position.y, sin, cos, true);

            if (ballPos.y + ball.radius > startP.y)
            {
                return Double.PositiveInfinity;
            }

            double dis = ballPos.y - startP.y + ball.radius;
            double t = -dis / velBall.y;
            if (t > time)
            {
                return Double.PositiveInfinity;
            }

            double upPX = ballPos.x + t * velBall.x;
            Number2D endP = RotateCalculate(pEnd.x, pEnd.y, sin, cos, true);
            if (upPX < startP.x || upPX > endP.x)
            {
                return Double.PositiveInfinity;
            }
            return t;
        }
    }
}
