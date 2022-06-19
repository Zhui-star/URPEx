/*
 * BoundingBox 实现 @3D数学:图像与游戏开发
 */
using UnityEngine;
using System.Collections.Generic;
namespace GARREN.URPEx
{ 
    public class AABB3
    {
        private Vector3 m_MinPoint;
        private Vector3 m_MaxPoint;

        public void Empty()
        {
            m_MaxPoint.Set(-Mathf.Infinity, -Mathf.Infinity, -Mathf.Infinity);
            m_MinPoint.Set(Mathf.Infinity, Mathf.Infinity, Mathf.Infinity);
        }

        public void  Add(Vector3 p)
        {
            if (p.x < m_MinPoint.x) m_MinPoint.x = p.x;
            if (p.x > m_MaxPoint.x) m_MaxPoint.x = p.x;
            if (p.y < m_MinPoint.y) m_MinPoint.y = p.y;
            if (p.y > m_MaxPoint.y) m_MaxPoint.y = p.y;
            if (p.z < m_MinPoint.z) m_MinPoint.z = p.z;
            if (p.z > m_MaxPoint.z) m_MaxPoint.z = p.z;
        }

        public Vector3[] GetMinMaxPoint()
        {
            Vector3[] minMaxPoint = new Vector3[2] { m_MinPoint, m_MaxPoint };
            return minMaxPoint;
        }
    }

    public class AABBBoundingBox : MonoBehaviour
    {
        #region private filed
        //Position list count
        [SerializeField]
        private int N;

        //Min random value and max random value
        private const int MIN = -10;
        private const int MAX = 10;

        AABB3 aabb3;
        #endregion

        #region Unity Loop
        private void Start()
        {
            aabb3 = new AABB3();
            aabb3.Empty();
            for(int index=0;index<N;index++)
            {
                Vector3 randomPosition = RandomPosition();
                aabb3.Add(randomPosition);
            }
        }

        void OnDrawGizmosSelected()
        {
            if (aabb3 == null)
                return;

            Vector3[] minMaxPoint = aabb3.GetMinMaxPoint();
            Vector3 center = (minMaxPoint[1] - minMaxPoint[0]) / 2;
            Gizmos.color = Color.green;
            Gizmos.DrawWireCube(center,
                new Vector3(minMaxPoint[1].x - minMaxPoint[0].x, minMaxPoint[1].y - minMaxPoint[0].y, minMaxPoint[1].z
                - minMaxPoint[0].z));
        }

        #endregion
        #region Random Position
        /// <summary>
        /// Generate a random position
        /// </summary>
        /// <returns></returns>
        private Vector3 RandomPosition()
        {
            float x= Random.Range(MIN, MAX);
            float y = Random.Range(MIN, MAX);
            float z  = Random.Range(MIN, MAX);

            return new Vector3(x, y, z);
        }
        #endregion
    }

}

