using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
namespace GARREN.URPEx
{
    public class MatrixToEuler : MonoBehaviour
    {
        [SerializeField]
        private Matrix4x4 m_RotateMatrix;

        /// <summary>
        /// heading pitch bank 
        /// </summary>
        [SerializeField]
        private float h, p, b;

        
    }

}
