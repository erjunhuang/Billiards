using System.Collections.Generic;
using UnityEngine;

namespace Billiards
{
    public class BilliardsTool {
        public static void SetColor32Array(Color32[] buffer, List<uint> color32Table) {
            for (int i = 0, len = color32Table.Count; i < len; ++i) {
                var color32 = color32Table[i];
                buffer[i].a = (byte)((color32 >> 24) & 0xFF);
                buffer[i].r = (byte)((color32 >> 16) & 0xFF);
                buffer[i].g = (byte)((color32 >> 8) & 0xFF);
                buffer[i].b = (byte)((color32) & 0xFF);
            }
        }
    }
}