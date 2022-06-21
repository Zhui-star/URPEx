using UnityEngine;
namespace GARREN.URPEx
{
    public class ConeMesh : MonoBehaviour
    {
        #region Unity loop
        private void Start()
        {
            Mesh coneMesh = GenerateConeMesh();
            MeshFilter meshFitler = GetComponent<MeshFilter>();
            if(meshFitler==null)
            {
                meshFitler = this.gameObject.AddComponent<MeshFilter>();
            }

            meshFitler.mesh = coneMesh;
            MeshRenderer meshRender = GetComponent<MeshRenderer>();
            if(meshRender==null)
            {
                meshRender = this.gameObject.AddComponent<MeshRenderer>();
            }
            Material litMat = new Material(Shader.Find("Universal Render Pipeline/Lit"));
            meshRender.material = litMat;
            litMat.color = Color.grey;
        }
        #endregion
        #region Éú³ÉMesh
        private Mesh GenerateConeMesh()
        {
            Mesh coneMesh = new Mesh();
            Vector3 v1 = new Vector3(0, 5, 0);
            Vector3 v2 = new Vector3(-5, 0, 5);
            Vector3 v3 = new Vector3(5, 0, 5);
            Vector3 v4 = new Vector3(5, 0, 0);
            Vector3 v5 = new Vector3(-5, 0, 0);

            Vector3[] vertices = { v1, v2, v3, v4, v5 };

            coneMesh.vertices = vertices;
            int[] trangles =
            {
                2,0,1,
                3,0,2,
                4,0,3,
                1,0,4,
                1,4,3,
                3,2,1
            };

            coneMesh.triangles = trangles;

            Vector2[] uvs =
             {
                new Vector2(0.5f,0.5f),
                new Vector2(1,0),
                new Vector2(0,1),
                new Vector2(1,0),
                new Vector2(0,0),
            };

            coneMesh.uv = uvs;

            return coneMesh;
        }
        #endregion
    }

}
