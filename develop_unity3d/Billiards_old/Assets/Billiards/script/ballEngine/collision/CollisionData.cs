namespace Billiards
{
    public class CollisionData
    {
        /// <summary>
        /// 起碰球索引
        /// </summary>
        public int ballA;
        /// <summary>
        /// 被碰球索引，如果值为-1代表边
        /// </summary>
        public int ballB;
        /// <summary>
        /// 发生碰撞所需的时间
        /// </summary>
        public double time;
        /// <summary>
        /// 球点碰撞、球线碰撞才有效的值
        /// </summary>
        public double x;
        /// <summary>
        /// 球点碰撞、球线碰撞才有效的值
        /// </summary>
        public double y;

        public CollisionData(int a = 0, int b = 0, double t = 0, double x = 0, double y = 0)
        {
            this.ballA = a;
            this.ballB = b;
            this.time = t;
            this.x = x;
            this.y = y;
        }
    }
}
