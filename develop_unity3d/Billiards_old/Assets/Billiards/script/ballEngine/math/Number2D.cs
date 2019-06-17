using System;
namespace Billiards
{
    /// <summary>
    /// 二维向量
    /// </summary>
    public class Number2D
    {

        public const double RADTODEG = 57.2957795130823;
        public const double DEGTORAD = 0.0174532925199433;

        public double x;
        public double y;

        public Number2D(double x = 0, double y = 0)
        {
            this.x = x;
            this.y = y;
        }

        public void DivideEq(double d)
        {
            this.x = this.x / d;
            this.y = this.y / d;
        }

        public void Scale(double value)
        {
            this.x = this.x * value;
            this.y = this.y * value;
        }

        public void Reset(double x = 0, double y = 0)
        {
            this.x = x;
            this.y = y;
        }

        public void CopyTo(Number2D another)
        {
            another.x = this.x;
            another.y = this.y;
        }

        public void CopyFrom(Number2D another)
        {
            this.x = another.x;
            this.y = another.y;
        }

        public double ModuloSquared
        {
            get
            {
                return this.x * this.x + this.y * this.y;
            }
        }

        public double Angle()
        {
            if (Common.useDEGREES)
            {
                return RADTODEG * Math.Atan2(this.y, this.x);
            }
            return Math.Atan2(this.y, this.x);
        }

        public void Rotate(double angle)
        {
            double tmpx = x;
            double tmpy = y;
            if (Common.useDEGREES)
            {
                angle = angle * DEGTORAD;
            }
            double cosRY = Math.Cos(angle);
            double sinRY = Math.Sin(angle);

            this.x = tmpx * cosRY - tmpy * sinRY;
            this.y = tmpx * sinRY + tmpy * cosRY;
        }

        public Number2D Clone()
        {
            return new Number2D(this.x, this.y);
        }

        public void Add(double x, double y)
        {
            this.x = this.x + x;
            this.y = this.y + y;
        }

        public void Reverse()
        {
            this.x = -this.x;
            this.y = -this.y;
        }

        public bool IsModuloGreaterThan(double v)
        {
            return this.ModuloSquared > (v * v);

        }

        public void PlusEq(Number2D v)
        {
            this.x = this.x + v.x;
            this.y = this.y + v.y;
        }

        public bool IsModuloEqualTo(double v)
        {
            return this.ModuloSquared == (v * v);
        }

        public void MultiplyEq(double d)
        {
            this.x = this.x * d;
            this.y = this.y * d;
        }

        public void Normalise()
        {
            double m = this.Modulo;
            this.x = this.x / m;
            this.y = this.y / m;
        }

        public bool IsModuloLessThan(double v)
        {
            return this.ModuloSquared < (v * v);
        }
        public void minusEq(Number2D v)
        {
            this.x = this.x - v.x;
            this.y = this.y - v.y;
        }

        public static double Cross(Number2D v, Number2D w)
        {
            return v.x * w.y + v.y * w.x;
        }

        public static double Dot(Number2D v, Number2D w)
        {
            return v.x * w.x + v.y * w.y;
        }

        public double Length
        {
            get
            {
                return Math.Sqrt(this.x * this.x + this.y * this.y);
            }
        }

        public double Modulo
        {
            get
            {
                return Math.Sqrt(this.x * this.x + this.y * this.y);
            }
        }
    }

}