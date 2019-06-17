namespace Billiards
{
    public class LogicalBall
    {
        /// <summary>
        /// 所有LogicalBall 共用的运算缓存
        /// </summary>
        private static Matrix3D _tmpMatrix3D = new Matrix3D();
        /// <summary>
        /// 所有LogicalBall 共用的运算缓存
        /// </summary>
        private static Number3D _tmpNumber3D = new Number3D();

        public int type = 0;            // 类型，斯诺克用来区分颜色
        public uint number;             // 编号
        public int pocketNum;           // 所在洞编号
        public int state;               // 状态
        public double radius;           // 半经

        public Number2D position;       // 位置
        public Number2D velocity;       // 速度
        public Number3D w;              // 暂时不知道，貌似与旋转有关
        public Matrix3D rotation;       // 旋转+
        public VisualBall visualBall;
        public bool needRender = false;


        // -----------------状态--------------------
        public const int nSTATE_IN_NONE = 1;                // 初始状态
        public const int nSTATE_IN_PLAY = 1;                // 在桌面
        public const int nSTATE_IN_POCKET = 2;              // 即将在洞里
        public const int nSTATE_POCKETED = 3;                // 在洞里
                                                             // public bool unusualInPocket = false;
                                                             //public var view:VisualBall;			// 就是他的真身VisualBall


        /**
         * 球的旋转和移动逻辑
         */
        public LogicalBall(double rad)
        {
            this.radius = rad;
            this.position = new Number2D();
            this.rotation = new Matrix3D();
            this.w = new Number3D();
            this.velocity = new Number2D();
            this.state = nSTATE_IN_PLAY;
        }

        public void Init()
        {
            position.Reset();
            rotation.Reset();
            w.Reset();
            velocity.Reset();
            state = nSTATE_IN_PLAY;
        }

        /// <summary>
        /// 更新显示
        /// </summary>
        public void UpdateVisualBall()
        {
            visualBall.RenderBall(this);
        }

        public void Move(double time = 1)
        {
            this.position.x = this.position.x + this.velocity.x * time;
            this.position.y = this.position.y + this.velocity.y * time;
        }

        public void Rotate(double time = 1)
        {
            LogicalBall._tmpNumber3D.Reset();
            LogicalBall._tmpNumber3D.x = this.w.x;
            LogicalBall._tmpNumber3D.y = this.w.y;
            LogicalBall._tmpNumber3D.z = this.w.z;
            double len = _tmpNumber3D.Modulo * time;
            LogicalBall._tmpNumber3D.Normalise();
            LogicalBall._tmpMatrix3D.Reset();
            LogicalBall._tmpMatrix3D.RotationMatrix(LogicalBall._tmpNumber3D, len);
            this.rotation.Multiply(LogicalBall._tmpMatrix3D);
        }

        /// <summary>
        /// 判断当前球是否在运动（包括位置移动和旋转）
        /// </summary>
        public bool IsMovingOrSpinning
        {
            get
            {
                return velocity.x != 0 || velocity.y != 0 || w.x != 0 || w.y != 0 || w.z != 0;
            }
        }

        /// <summary>
        /// 判断当前球是否在移动（仅包括位置移动）
        /// </summary>
        public bool IsMoving
        {
            get
            {
                return velocity.x != 0 || velocity.y != 0;
            }
        }

        /// <summary>
        /// 判断当前球是否在旋转
        /// </summary>
        public bool IsSpinning
        {
            get
            {
                return w.x != 0 || w.y != 0 || w.z != 0;
            }
        }

        /// <summary>
        /// 判断当前球是否已经进袋了
        /// </summary>
        public bool IsInPocket
        {
            get
            {
                return this.state == nSTATE_POCKETED;
            }
        }

        /// <summary>
        /// 停止当前球的所有运动
        /// </summary>
        public void StopMoving()
        {
            this.velocity.Reset();
            this.w.Reset();
        }
    }

}
