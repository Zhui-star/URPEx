using UnityEngine;
namespace GARREN.URPEx
{
    public class MatrixToEuler : MonoBehaviour
    {
        #region Private Field
        [SerializeField]
        private Matrix4x4 m_RotateMatrix;

        /// <summary>
        /// heading pitch bank 
        /// </summary>
        [SerializeField]
        [ReadOnly]
        private float h, p, b;

        [SerializeField]
        private Transform m_RotateRoot;
        #endregion

        #region Unity Loop

        private void Update()
        {
            MatrixConvertEulerAngle();
            SetTransformRootRotation();
        }
        #endregion

        #region Rotate Action
        private void MatrixConvertEulerAngle()
        {
            float sp = -m_RotateMatrix.m23;
            if(sp<=-1.0f)
            {
                p = -Mathf.PI / 2;
            }else if(sp>=1.0f)
            {
                p = Mathf.PI / 2;
            }
            else
            {
                p = Mathf.Asin(sp);
            }

            if(Mathf.Abs(sp)>0.9999f)
            {
                b = 0.0f;
                h = Mathf.Atan2(-m_RotateMatrix.m31, m_RotateMatrix.m11);
            }
            else
            {
                h = Mathf.Atan2(m_RotateMatrix.m13, m_RotateMatrix.m33);

                b = Mathf.Atan2(m_RotateMatrix.m21, m_RotateMatrix.m22);
            }
        }

        private void SetTransformRootRotation()
        {
            if(m_RotateRoot)
            {
                m_RotateRoot.eulerAngles = new Vector3(p, h, b);
            }
        }
        #endregion

    }

}
