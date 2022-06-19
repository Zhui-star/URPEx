/*
 * N�������һ��ƽ�� �����ƽ������ʵĵ�
 */
using UnityEngine;
namespace GARREN.URPEx
{
    public class ComputeBestFitNormal : MonoBehaviour
    {
        #region ˽���ֶ�
        [SerializeField]
        //���N����
        private Transform[] m_PointTrs;

        private Vector3 m_ResultNormal;
        #endregion

        #region Debug ����
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

        #region ƽ�����
        /// <summary>
        /// ͨ���������ϳ�һ������ʵ�ƽ�淨�ߣ�����������߹�һ��
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
