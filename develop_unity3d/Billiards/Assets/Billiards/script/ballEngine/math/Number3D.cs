using System;
namespace Billiards
{
    /// <summary>
    /// 三维向量
    /// </summary>
    public class Number3D
    {
        public static double toDEGREES = 57.2957795130823;
        private static Number3D temp = Number3D.ZERO;
        public static double toRADIANS = 0.0174532925199433;

        public double z;
        public double x;
        public double y;

        public Number3D(double x = 0, double y = 0, double z = 0)
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }

        public void Normalize()
        {
            double mod = Math.Sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
            if (mod != 0 && mod != 1)
            {
                mod = 1 / mod;
                this.x = this.x * mod;
                this.y = this.y * mod;
                this.z = this.z * mod;
            };
        }

        public void Reset(double newx = 0, double newy = 0, double newz = 0)
        {
            this.x = newx;
            this.y = newy;
            this.z = newz;
        }

        public void CopyTo(Number3D another)
        {
            another.x = this.x;
            another.y = this.y;
            another.z = this.z;
        }

        public void CopyFrom(Number3D another)
        {
            this.x = another.x;
            this.y = another.y;
            this.z = another.z;
        }


        public bool IsModuloGreaterThan(double v)
        {
            return this.ModuloSquared > (v * v);
        }

        public void RotateX(double angle)
        {
            if (Common.useDEGREES)
            {
                angle = angle * toRADIANS;
            };
            double cosRY = Math.Cos(angle);
            double sinRY = Math.Sin(angle);
            temp.CopyFrom(this);
            this.y = temp.y * cosRY - temp.z * sinRY;
            this.z = temp.y * sinRY + temp.z * cosRY;
        }

        public void RotateY(double angle)
        {
            if (Common.useDEGREES)
            {
                angle = angle * toRADIANS;
            };
            double cosRY = Math.Cos(angle);
            double sinRY = Math.Sin(angle);
            temp.CopyFrom(this);
            this.x = temp.x * cosRY + temp.z * sinRY;
            this.z = temp.x * -sinRY + temp.z * cosRY;
        }

        public void RotateZ(double angle)
        {
            if (Common.useDEGREES)
            {
                angle = angle * toRADIANS;
            };
            double cosRY = Math.Cos(angle);
            double sinRY = Math.Sin(angle);
            temp.CopyFrom(this);
            this.x = temp.x * cosRY - temp.y * sinRY;
            this.y = temp.x * sinRY + temp.y * cosRY;
        }

        public void Add(double x = 0, double y = 0, double z = 0)
        {
            this.x = this.x + x;
            this.y = this.y + y;
            this.z = this.z + z;
        }

        public void Reverse()
        {
            this.x = -this.x;
            this.y = -this.y;
            this.z = -this.z;
        }

        public Number3D Clone()
        {
            return new Number3D(this.x, this.y, this.z);
        }

        public void PlusEq(Number3D v)
        {
            this.x = this.x + v.x;
            this.y = this.y + v.y;
            this.z = this.z + v.z;
        }

        public bool IsModuloEqualTo(double v)
        {
            return this.ModuloSquared == (v * v);
        }

        public void MultiplyEq(double n)
        {
            this.x = this.x * n;
            this.y = this.y * n;
            this.z = this.z * n;
        }

        public bool IsModuloLessThan(double v)
        {
            return this.ModuloSquared < (v * v);
        }

        public void Normalise()
        {
            double len = this.Modulo;
            if (len != 0)
            {
                this.x = this.x / len;
                this.y = this.y / len;
                this.z = this.z / len;
            }
            else
            {
                this.x = 0;
                this.y = 0;
                this.z = 0;
            };
        }

        public void MinusEq(Number3D v)
        {
            this.x = this.x - v.x;
            this.y = this.y - v.y;
            this.z = this.z - v.z;
        }

        public static Number3D Sub(Number3D v, Number3D w)
        {
            return new Number3D(v.x - w.x, v.y - w.y, v.z - w.z);
        }

        public static Number3D Unit(Number3D v)
        {
            Number3D t = v.Clone();
            t.Normalise();
            return t;
        }

        public static Number3D Cross(Number3D v, Number3D w, Number3D targetN = null)
        {
            if (targetN == null)
            {
                targetN = ZERO;
            };
            targetN.Reset(w.y * v.z - w.z * v.y, w.z * v.x - w.x * v.z, w.x * v.y - w.y * v.x);
            return targetN;
        }

        public static double Dot(Number3D v, Number3D w)
        {
            return v.x * w.x + v.y * w.y + w.z * v.z;
        }

        public static Number3D Scale(Number3D v, double scale)
        {
            return new Number3D(v.x * scale, v.y * scale, v.z * scale);
        }

        public static Number3D AddEp(Number3D v, Number3D w)
        {
            return new Number3D(v.x + w.x, v.y + w.y, v.z + w.z);
        }

        public double Modulo
        {
            get
            {
                return Math.Sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
            }
        }

        public static Number3D ZERO
        {
            get
            {
                return new Number3D(0, 0, 0);
            }
        }

        public double ModuloSquared
        {
            get
            {
                return this.x * this.x + this.y * this.y + this.z * this.z;
            }
        }
    }
}