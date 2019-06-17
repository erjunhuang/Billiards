using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace Billiards
{
    public class TableData
    {
        public static double ScaleX = 0;
        public static double ScaleY = 0;
        public static Texture2D BallData_BallMaskTextureClass;
        public static Texture2D BallData_ballNumberClass;
        public static Texture2D HighlightClass;
        public static Texture2D ShadowBitmapClass;
        public static GameObject BallLayer;

        public static float Ball_Layer = -0.5f;
        public static float Cue_Layer = -1.0f;
        public static float Shadow_Layer = -0.2f;
        public static float Hight_Light_Layer = -0.9f;
        public static float Aim_Layer = -1f;

        private List<LogicalBall> _allBallArr = null;
        private List<LogicalBall> _ballArrExceptWhite = null; //除了白球外的所有球
        private LogicalBall _guideBall = null;      // 白球
        private List<Number2D> _vertexs = null;                 // 桌邊頂點
        private List<Number2D> _pocketPoints = null;           //保存六个洞口的Point

        public List<LogicalBall> AllBallArr
        {
            get
            {
                return _allBallArr;
            }
        }

        public LogicalBall GuideBall
        {
            get
            {
                return _guideBall;
            }
        }
        public List<Number2D> Vertexs
        {
            get
            {
                return _vertexs;
            }
        }
        public List<Number2D> PocketPoints
        {
            get
            {
                return _pocketPoints;
            }
        }
        public List<LogicalBall> BallArrExceptWhite
        {
            get
            {
                return _ballArrExceptWhite;
            }
        }

        static public Number2D ScreenToLogic(float x, float y)
        {
            return new Number2D((double)(x / ScaleX), (double)(y / ScaleY));
        }

        static public Number2D LogicToScreen(double x, double y)
        {
            return new Number2D(x * ScaleX, y * ScaleY);
        }

        public TableData()
        {
            InitVertexs();
        }

        public void InitBalls()
        {
            _allBallArr = new List<LogicalBall>();
            _ballArrExceptWhite = new List<LogicalBall>();
            LogicalBall ball;

            for (int i = 0; i < BallEngineConfig.BALL_COUNT; ++i)
            {
                ball = new LogicalBall(BallEngineConfig.BALL_RADIUS);
                ball.number = (uint)i;
                // TODO:
                ball.type = i > 14 ? 14 : i;

                VisualBall visualBall = new VisualBall(ball);
                ball.visualBall = visualBall;
                ball.UpdateVisualBall();

                _allBallArr.Add(ball);
                if (i != 0)
                {
                    _ballArrExceptWhite.Add(ball);
                }
            }
            _guideBall = _allBallArr[0];
        }

        private void InitVertexs()
        {
            _vertexs = new List<Number2D>();
            _pocketPoints = new List<Number2D>();
            double[,] verts = BallEngineConfig.TABLE_POINTS;
            int len = verts.GetLength(0);
            int i = 0;
            Number2D v;
            while (i < len)
            {
                v = new Number2D(verts[i, 0], verts[i, 1]);
                _vertexs.Add(v);
                i++;
            }
            double[,] pockets = BallEngineConfig.POCKET_POS;
            i = 0;
            while (i < pockets.GetLength(0))
            {
                _pocketPoints.Add(new Number2D(pockets[i, 0], pockets[i, 1]));
                i++;
            }
        }
    }
}
