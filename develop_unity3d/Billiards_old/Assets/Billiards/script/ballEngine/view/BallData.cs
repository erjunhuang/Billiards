using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace Billiards
{
    public class BallData
    {
        private static uint backColor = 0xEEECD3;
        private const uint BLACK = 0x231509;
        private static uint[] colors = { 0xFFC600, 0x2944B5, 0xDB1313, 0x63116D, 0xFF6000, 0x414208, 0x650E00, BLACK };

        public static Color32[] GetBallData(int number)
        {
            uint bColor;
            uint pixDeep;
            uint pixDeep2;
            uint pix1;
            uint pix2;
            uint bpix;
            bool isDoubleColor;
            int bWidth = TableData.BallData_BallMaskTextureClass.width;
            int bHeight = TableData.BallData_BallMaskTextureClass.height;
            int wLenght = TableData.BallData_ballNumberClass.width;
            int numPos = ((bWidth - wLenght) / 2);
            int xPos = 0;
            int yPos = ((number - 1) * wLenght);
            int xIndex = 0;
            int yIndex = 0;
            Color32[] incolor32s = TableData.BallData_BallMaskTextureClass.GetPixels32();
            Color32[] outcolor32s = new Color32[bWidth * bHeight];
            if (number == 0)
            {
                while (yIndex < bHeight)
                {
                    xIndex = 0;
                    while (xIndex < bWidth)
                    {
                        int colorindex = GetPixelIndex(xIndex, yIndex, bWidth, bHeight);
                        uint colorU = 0xFFFFFFFF;
                        int radius = (xIndex - bWidth / 2) * (xIndex - bWidth / 2) + (yIndex - bHeight / 2) * (yIndex - bHeight / 2);
                        if (radius < 10)
                            colorU = 0xFF990033;
                        GetColor32(ref outcolor32s[colorindex], colorU);
                        xIndex++;
                    }
                    yIndex++;
                }
            }
            else
            {
                isDoubleColor = (number > 8);
                bColor = colors[((number - 1) % colors.Length)];

                while (yIndex < bHeight)
                {
                    xIndex = 0;
                    while (xIndex < bWidth)
                    {
                        int colorindex = GetPixelIndex(xIndex, yIndex, bWidth, bHeight);
                        uint colorU = GetUintColor32(incolor32s[colorindex]);
                        if (isDoubleColor)
                        {
                            pixDeep = ((colorU & 0xFF00) >> 8);
                        }
                        else
                        {
                            pixDeep = (colorU & 0xFF);
                        };
                        pixDeep2 = (0xFF - pixDeep);
                        pix1 = ((((pixDeep * (bColor & 0xFF00FF)) & 0xFF00FF00) >> 8) + (((pixDeep2 * (backColor & 0xFF00FF)) & 0xFF00FF00) >> 8));
                        pix2 = ((((pixDeep * (bColor & 0xFF00)) >> 8) & 0xFF00) + (((pixDeep2 * (backColor & 0xFF00)) >> 8) & 0xFF00));
                        uint outcolor32 = ((pix1 | pix2) | 0xFF000000);
                        GetColor32(ref outcolor32s[colorindex], outcolor32);
                        xIndex++;
                    };
                    yIndex++;
                };
                yIndex = 0;
                Color32[] numberColor32s = TableData.BallData_ballNumberClass.GetPixels32();
                while (yIndex < wLenght)
                {
                    xIndex = 0;
                    while (xIndex < wLenght)
                    {
                        int colorindex = GetPixelIndex((xIndex + numPos), (yIndex + numPos), bWidth, bHeight);
                        bpix = GetUintColor32(outcolor32s[colorindex]);
                        pixDeep = (GetUintColor32(numberColor32s[GetPixelIndex((xIndex + xPos), (yIndex + yPos), TableData.BallData_ballNumberClass.width, TableData.BallData_ballNumberClass.height)]) & 0xFF);
                        pixDeep2 = (0xFF - pixDeep);
                        pix1 = ((((pixDeep * (BLACK & 0xFF00FF)) & 0xFF00FF00) >> 8) + (((pixDeep2 * (bpix & 0xFF00FF)) & 0xFF00FF00) >> 8));
                        pix2 = ((((pixDeep * (BLACK & 0xFF00)) >> 8) & 0xFF00) + (((pixDeep2 * (bpix & 0xFF00)) >> 8) & 0xFF00));
                        uint outcolor32 = ((pix1 | pix2) | 0xFF000000);
                        GetColor32(ref outcolor32s[colorindex], outcolor32);
                        xIndex++;
                    };
                    yIndex++;
                };
            };
            return (outcolor32s);
        }


        /**
         * x, y是从上往下  从左往右
         * unity Pixels32数组索引 是从下往上 从左往右 暂时做个转换 
         *
         */
        public static int GetPixelIndex(int x, int y, int width, int height)
        {
            int index = (height - y - 1) * width + x;
            return index;
        }

        public static uint GetUintColor32(Color32 color)
        {
            uint r = color.r;
            uint g = color.g;
            uint b = color.b;
            uint a = color.a;
            return (a << 24) + (r << 16) + (g << 8) + b;
        }

        public static void GetColor32(ref Color32 color, uint uintColor)
        {
            uint r = (uintColor >> 16) & 0xFF;
            uint g = (uintColor >> 8) & 0xFF;
            uint b = (uintColor) & 0xFF;
            uint a = (uintColor >> 24) & 0xFF;
            color.r = (byte)r;
            color.g = (byte)g;
            color.b = (byte)b;
            color.a = (byte)a;
        }
    }
}
