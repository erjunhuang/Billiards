namespace Billiards
{
    public class Rectangle
    {
        public double x;
        public double y;
        public double width;
        public double height;
        public double top;
        public double bottom;
        public double right;
        public double left;
        public Rectangle(double x, double y, double width, double height)
        {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
            this.left = this.x;
            this.top = this.y;
            this.right = this.x + this.width;
            this.bottom = this.y + this.height;
        }

        public bool ContainsPoint(double x, double y)
        {
            if (x < right && x > left && y > top && y < bottom)
                return true;
            return false;
        }
    }
}
