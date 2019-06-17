using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
namespace Billiards
{
    public class CueAngleView : MonoBehaviour
    {
        public GameObject Cross;
        private float _radius = 0;
        private float _radiusX2 = 0;

        void Start()
        {
            _radius = gameObject.GetComponent<Renderer>().bounds.size.x / 2;
            _radiusX2 = _radius * _radius;
        }

        void OnMouseDrag()
        {
            Vector3 vec = Input.mousePosition;
            Vector3 worldPos = Camera.main.ScreenToWorldPoint(vec);
            Vector3 localPos = gameObject.GetComponent<Transform>().InverseTransformPoint(worldPos);
            localPos.z = Cross.GetComponent<Transform>().localPosition.z;
            if ((localPos.x * localPos.x + localPos.y * localPos.y) < _radiusX2)
            {
                Cross.GetComponent<Transform>().localPosition = localPos;
            }
        }

        void OnMouseDown()
        {
            Vector3 vec = Input.mousePosition;
            Vector3 worldPos = Camera.main.ScreenToWorldPoint(vec);
            Vector3 localPos = gameObject.GetComponent<Transform>().InverseTransformPoint(worldPos);
            localPos.z = Cross.GetComponent<Transform>().localPosition.z;
            if ((localPos.x * localPos.x + localPos.y * localPos.y) < _radiusX2)
            {
                Cross.GetComponent<Transform>().localPosition = localPos;
            }
        }
    }
}
