/*
 * N个点组成一个平面 求出该平面最合适的点
 */
using UnityEngine;
namespace GARREN.URPEx
{
    public class ComputeBestFitNormal : MonoBehaviour
    {
        #region 私有字段
        [SerializeField]
        //随机N个点
        private Transform[] m_PointTrs;

        private Vector3 m_ResultNormal;
        #endregion

        #region Debug 调试
        private void OnDrawGizmosSelected()
        {
           Vector3 sumPosition=Vector3.zero;
           for(int pointIndex=0;pointIndex<m_PointTrs.Length;pointIndex++)
            {
                sumPosition += m_PointTrs[pointIndex].position;
            }

            Vector3 avgPosition =  sumPosition / m_PointTrs.Length;

            ComputeBestFitNormalByNPoint();

            Gizmos.color = Color.green;
            Gizmos.DrawRay(avgPosition, m_ResultNormal);
        }
        #endregion

        #region 平面相关
        /// <summary>
        /// 通过多个点拟合出一条最合适的平面法线，并把这个法线归一化
        /// </summary>
        private void ComputeBestFitNormalByNPoint()
        {
            m_ResultNormal = Vector3.zero;

            if (m_PointTrs.Length <= 0)
                return;

            Vector3 p = m_PointTrs[m_PointTrs.Length - 1].position;

            for(int pointIndex=0;pointIndex<m_PointTrs.Length;pointIndex++)
            {
                Vector3 c = m_PointTrs[pointIndex].position;

                m_ResultNormal.x += (p.z + c.z) * (p.y - c.y);
                m_ResultNormal.y += (p.x + c.x) * (p.z - c.z);
                m_ResultNormal.z += (p.y + c.y) * (p.x - c.x);

                p = c;
            }

            m_ResultNormal=m_ResultNormal.normalized;
        }
        #endregion
    }

}
