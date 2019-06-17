using System.Collections;

namespace Billiards
{

    public class BallEngineConfig
    {
        // public static readonly Number2D BALL_LAYER_POS = new Number2D(840 / 2, 442 / 2);
        public static int BALL_COUNT = 16;
        public const int BALL_RADIUS = 11;

        public static readonly Rectangle TABLE_RECT = new Rectangle(-792.7 / 2, -394.85 / 2, 792.7, 394.85);

        public static readonly Rectangle TABLE_BREAK_RECT = new Rectangle(-792.7 / 2, -394.85 / 2, 162, 394.85);
        /// <summary>
        /// 球桌上6个球洞/袋的判断点
        /// </summary>
        /// <value></value>
        public static readonly double[,] POCKET_POS = { { -404, -205 }, { 404, -205 }, { -404, 205 },
                                                    { 404, 205 }, { 0, 215 }, { 0, -215 } };

        public static readonly double WIDTH = POCKET_POS[1, 0] - POCKET_POS[0, 0];
        public static readonly double HEIGHT = POCKET_POS[2, 1] - POCKET_POS[0, 1];

        /// <summary>
        /// 球桌的顶点列表，其球洞判断点包含在这个定点连成的多边形中
        /// </summary>
        /// <value></value>
        public static readonly double[,] TABLE_POINTS = { { -371, -198 }, { -412, -226 }, { -426, -212 }, { -397, -172 },
                                                    { -397, 172}, { -426, 212}, { -413, 226}, {-371, 198},
                                                    { -27, 197 }, { -14, 211 }, {-11, 231 }, {11, 231 },{14,211 },{27,197 },
                                                    { 371, 198 }, {413, 226 }, {426, 212 }, {397, 172 },
                                                    { 397, -172}, {426, -212}, {412, -226}, {371, -198},
                                                    { 27,-197 },{14,-211 },{11,-231 },{-11,-231 },{-14,-211 },{-27,-197 } };
        // public static readonly Number2D[] POCKET_DROP_POS = { new Number2D(-310 + 60, -158 + 60), new Number2D(310 - 60, -158 + 60),
        //                                                         new Number2D(-310 + 60, 159 - 60),new Number2D(310 - 60, 159 - 60),
        //                                                         new Number2D(0, 169 - 60), new Number2D(0, -169 + 60) };

        /// <summary>
        /// 物理引擎时间步的间隔
        /// </summary>
        public const double TIME = 0.03 / 2;
        public const double START_VELOCITY = 15;
        // public const double SNOOKER_START_CIRCLE_RADIUS = 84;
        // public const int SNOOKER_START_RECT_POINT = -233;

        //斯诺克颜色 白色，黄色，绿色，棕色，蓝色，粉色，黑色，红色
        // public static readonly uint[] SNOOKER_BALL_COLOR = {0xffffff,0xD9B306,0x2A7010,0x7F3B28,0x180FAA,0xCC66FF,2299145,0xff0000};
        //摆球位置 黄色，绿色，棕色，蓝色，粉色，黑色，红色
        public static readonly int[][] SNOOKER_BALL_START_POS = { new int[] { -233, 84 }, new int[] { -233, -84 }, new int[] { -233, 0 }, new int[] { 0, 0 }, new int[] { 198, 0 }, new int[] { 325, 0 }, new int[] { 218, 0 } };
        public static readonly Number2D WHITE_POS = new Number2D(-234, -50);
        // public static readonly Rectangle TABLE_START_RECT = new Rectangle(-792.7/2,-394.85/2,163.35 + BallEngineConfig.BALL_RADIUS,394.85);// 開球白球可移動範圍

        // public const int PLAY = 1;							// 正在游戏
        // public const int END = 2;							// 游戏结束
        // public const int OPP_PLAY = 5;						// 对手在打
        // public const int PUT_CUE_BALL = 6;					// 放置母球
        // public const int BALL_ROLLING = 7;					// 桌球滚动状态


        // public const int SNOOKER_TYPE_WHITE = 0;
        // public const int SNOOKER_TYPE_YELLOW = 1;
        // public const int SNOOKER_TYPE_GREEN = 2;
        // public const int SNOOKER_TYPE_BROWN = 3;
        // public const int SNOOKER_TYPE_BLUE = 4;
        // public const int SNOOKER_TYPE_PINK = 5;
        // public const int SNOOKER_TYPE_BLACK = 6;
        // public const int SNOOKER_TYPE_RED = 7;

    }
}
