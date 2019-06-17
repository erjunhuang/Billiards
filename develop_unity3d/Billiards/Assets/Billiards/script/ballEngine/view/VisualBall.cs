using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
namespace Billiards
{
    public class VisualBall
    {
        public LogicalBall logicalBall = null;
        public GameObject view = null;
        public GameObject shadowView = null;
        public GameObject hightLightView = null;


        private Color32[] _ballData;
        private Color32[] _ballRender;
        private Texture2D texture2D;

        private int _sourceWidth = 0;
        private int _sourceHeight = 0;

        private double _alphaParent;
        private double _radiusX2;   //  半径2次方
        private double _radius;     // 半径
        private double _alphaValue;

        public VisualBall(LogicalBall logic)
        {
            logicalBall = logic;
            view = new GameObject();
            view.transform.SetParent(TableData.BallLayer.GetComponent<Transform>());
            view.AddComponent<SpriteRenderer>();
            view.name = "ball" + logic.number;
            shadowView = new GameObject();
            shadowView.transform.SetParent(TableData.BallLayer.GetComponent<Transform>());
            shadowView.AddComponent<SpriteRenderer>();
            shadowView.name = "ballShadow" + logic.number;
            shadowView.GetComponent<SpriteRenderer>().sprite = Sprite.Create(TableData.ShadowBitmapClass, new Rect(0.0f, 0.0f, TableData.ShadowBitmapClass.width, TableData.ShadowBitmapClass.height), new Vector2(0.5f, 0.5f)); ;
            shadowView.transform.localScale = new Vector3(1.4f, 1.4f, 1.4f);
            hightLightView = new GameObject();
            hightLightView.transform.SetParent(TableData.BallLayer.GetComponent<Transform>());
            hightLightView.AddComponent<SpriteRenderer>();
            hightLightView.name = "ballHightLight" + logic.number;
            hightLightView.GetComponent<SpriteRenderer>().sprite = Sprite.Create(TableData.HighlightClass, new Rect(0.0f, 0.0f, TableData.HighlightClass.width, TableData.HighlightClass.height), new Vector2(0.5f, 0.5f));

            _ballData = BallData.GetBallData((int)logic.type);
            int wh = (int)Math.Ceiling((logic.radius * 2 + 1));
            texture2D = new Texture2D(wh, wh, TextureFormat.ARGB32, false);
            _sourceWidth = TableData.BallData_BallMaskTextureClass.width;
            _sourceHeight = TableData.BallData_BallMaskTextureClass.height;
            view.GetComponent<SpriteRenderer>().sprite = Sprite.Create(texture2D, new Rect(0.0f, 0.0f, texture2D.width, texture2D.height), new Vector2(0.5f, 0.5f));
            // _ballRender = new Color32[texture2D.width * texture2D.height];
            _ballRender = texture2D.GetPixels32();
            _radius = logic.radius;
            _radiusX2 = (_radius * _radius);
            _alphaValue = ((_radius - 1) * (_radius - 1));
            _alphaParent = (0x0100 / (_radiusX2 - _alphaValue));
            RenderBall(_ballData, _ballRender, logic.rotation, 0, 0);
            texture2D.SetPixels32(_ballRender);
            texture2D.Apply(false);
        }

        public void RenderBall(LogicalBall logicalBall)
        {
            view.transform.localPosition = new Vector3((float)(logicalBall.position.x * TableData.ScaleX), (float)(logicalBall.position.y * TableData.ScaleY), TableData.Ball_Layer);
            shadowView.transform.localPosition = new Vector3((float)(logicalBall.position.x * TableData.ScaleX), (float)(logicalBall.position.y * TableData.ScaleY), TableData.Shadow_Layer);
            hightLightView.transform.localPosition = new Vector3((float)(logicalBall.position.x * TableData.ScaleX), (float)(logicalBall.position.y * TableData.ScaleY), TableData.Hight_Light_Layer);

            RenderBall(_ballData, _ballRender, logicalBall.rotation, 0, 0);
            texture2D.SetPixels32(_ballRender);
            texture2D.Apply(false);
        }

        public void RenderBall(Color32[] ballSource, Color32[] ballTarget, Matrix3D rotation, double xOffset = 0, double yOffset = 0)
        {
            double sWidth = _sourceWidth >> 1;
            double sHeight = _sourceHeight >> 1;
            int tWidth = texture2D.width;
            int tHeight = texture2D.height;
            int isBack = ((rotation.n33 >= 0)) ? 1 : -1;
            int xIndex = 0;
            int yIndex = 0;
            while (yIndex < tHeight)
            {
                xIndex = 0;
                while (xIndex < tWidth)
                {
                    double xRela = ((xIndex - _radius) + xOffset);
                    double yRela = ((yIndex - _radius) + yOffset);
                    double dist = ((xRela * xRela) + (yRela * yRela));
                    uint pix = 0;
                    if (dist < _radiusX2)
                    {
                        double iVect = (xRela / _radius);
                        double jVect = (yRela / _radius);

                        double kVect = Math.Sqrt(((1 - (iVect * iVect)) - (jVect * jVect)));
                        uint colorDeep = (64 + (uint)(kVect * 191));
                        double xProp = ((((iVect * rotation.n11) + (jVect * rotation.n12)) + (kVect * rotation.n13)) * isBack);
                        double yProp = (((iVect * rotation.n21) + (jVect * rotation.n22)) + (kVect * rotation.n23));
                        int sourceIndex = BallData.GetPixelIndex((int)(sWidth + (sWidth * xProp)), (int)(sHeight + (sHeight * yProp)), _sourceWidth, _sourceHeight);
                        pix = BallData.GetUintColor32(ballSource[sourceIndex]);
                        pix = (((((pix & 0xFF00FF) * colorDeep) >> 8) & 0xFF00FF) + ((((pix & 0xFF00) * colorDeep) >> 8) & 0xFF00));
                        if (dist <= _alphaValue)
                        {
                            pix = (0xFF000000 + pix);
                        }
                        else
                        {
                            int deep = (int)(0x0100 - ((dist - _alphaValue) * _alphaParent));
                            pix = ((uint)(deep << 24) + pix);
                        }
                    }
                    else
                    {
                        pix = 0;
                    }
                    int offsetx = (xIndex + tWidth) % tWidth;
                    int offsety = (yIndex + tHeight) % tHeight;
                    int targetIndex = BallData.GetPixelIndex(offsetx, offsety, tWidth, tHeight);
                    BallData.GetColor32(ref ballTarget[targetIndex], pix);
                    xIndex++;
                }
                yIndex++;
            }
        }
    }
}
