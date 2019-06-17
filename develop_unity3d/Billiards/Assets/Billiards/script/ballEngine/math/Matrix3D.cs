using System;

namespace Billiards
{
    /// <summary>
    /// 三阶矩阵
    /// </summary>
    public class Matrix3D
    {
        public double n31;
        public double n21;
        public double n11;
        public double n23;
        public double n13;
        public double n32;
        public double n22;
        public double n12;
        public double n33;

        public Matrix3D()
        {
            this.Reset();
        }

        public void Reset()
        {
            this.n11 = this.n22 = this.n33 = 1;
            this.n12 = this.n13 = this.n21 = this.n23 = this.n31 = this.n32 = 0;
        }

        public void Multiply(Matrix3D b)
        {
            double tn12 = this.n11 * b.n12 + this.n12 * b.n22 + this.n13 * b.n32;
            double tn11 = this.n11 * b.n11 + this.n12 * b.n21 + this.n13 * b.n31;
            double tn13 = this.n11 * b.n13 + this.n12 * b.n23 + this.n13 * b.n33;
            double tn21 = this.n21 * b.n11 + this.n22 * b.n21 + this.n23 * b.n31;
            double tn22 = this.n21 * b.n12 + this.n22 * b.n22 + this.n23 * b.n32;
            double tn23 = this.n21 * b.n13 + this.n22 * b.n23 + this.n23 * b.n33;
            double tn31 = this.n31 * b.n11 + this.n32 * b.n21 + this.n33 * b.n31;
            double tn32 = this.n31 * b.n12 + this.n32 * b.n22 + this.n33 * b.n32;
            double tn33 = this.n31 * b.n13 + this.n32 * b.n23 + this.n33 * b.n33;
            this.n11 = tn11;
            this.n12 = tn12;
            this.n13 = tn13;
            this.n21 = tn21;
            this.n22 = tn22;
            this.n23 = tn23;
            this.n31 = tn31;
            this.n32 = tn32;
            this.n33 = tn33;
        }

        public void Add(Number3D num)
        {
            double z;
            double x = num.x;
            double y = num.y;
            z = num.z;
            num.x = this.n11 * x + this.n12 * y + this.n13 * z;
            num.y = this.n21 * x + this.n22 * y + this.n23 * z;
            num.z = this.n31 * x + this.n32 * y + this.n33 * z;
        }

        public void RotationMatrix(Number3D point, double rad)
        {
            double x = point.x;
            double y = point.y;
            double z = point.z;
            double nCos = Math.Cos(rad);
            double nSin = Math.Sin(rad);
            double scos = 1 - nCos;
            double sxy = x * y * scos;
            double syz = y * z * scos;
            double sxz = x * z * scos;
            double sz = nSin * z;
            double sy = nSin * y;
            double sx = nSin * x;
            this.n11 = nCos + x * x * scos;
            this.n12 = -sz + sxy;
            this.n13 = sy + sxz;
            this.n21 = sz + sxy;
            this.n22 = nCos + y * y * scos;
            this.n23 = -sx + syz;
            this.n31 = -sy + sxz;
            this.n32 = sx + syz;
            this.n33 = nCos + z * z * scos;
        }

        public void CopyTo(Matrix3D another)
        {
            another.n11 = this.n11;
            another.n12 = this.n12;
            another.n13 = this.n13;
            another.n21 = this.n21;
            another.n22 = this.n22;
            another.n23 = this.n23;
            another.n31 = this.n31;
            another.n32 = this.n32;
            another.n33 = this.n33;
        }

        public void CopyFrom(Matrix3D another)
        {
            this.n11 = another.n11;
            this.n12 = another.n12;
            this.n13 = another.n13;
            this.n21 = another.n21;
            this.n22 = another.n22;
            this.n23 = another.n23;
            this.n31 = another.n31;
            this.n32 = another.n32;
            this.n33 = another.n33;
        }

        public Matrix3D Clone()
        {
            var matrix3D = new Matrix3D();
            matrix3D.CopyFrom(this);
            return matrix3D;
        }
    }
}