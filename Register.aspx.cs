using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ChatApplication
{
    public partial class Register : System.Web.UI.Page
    {
        DataSet ds;
        SqlConnection con = new SqlConnection();
 
        protected void Page_Load(object sender, EventArgs e)
        {
            ValidationSettings.UnobtrusiveValidationMode = UnobtrusiveValidationMode.None;

            con.ConnectionString = ConfigurationManager.ConnectionStrings["userconnection"].ConnectionString;


        }

        protected void register(object sender, EventArgs e)
        {
            byte[] imageData;

            // Check if an image file is uploaded; if not, use the default image
            if (lblimage.HasFile)
            {
                imageData = ReadFileData(lblimage);
            }
            else
            {
                imageData = LocalDefaultImage();
            }

            // Check for unique username and email
            bool isUsernameUnique = true;
            bool isEmailUnique = true;

            using (SqlCommand checkCmd = new SqlCommand("SELECT COUNT(*) FROM Chatters WHERE name = @username OR email = @useremail", con))
            {
                checkCmd.Parameters.AddWithValue("@username", lblusername.Text);
                checkCmd.Parameters.AddWithValue("@useremail", lblemail.Text);

                con.Open();
                int existingCount = (int)checkCmd.ExecuteScalar();
                con.Close();

                if (existingCount > 0)
                {
                    // Check if username exists
                    using (SqlCommand checkUsernameCmd = new SqlCommand("SELECT COUNT(*) FROM Chatters WHERE name = @username", con))
                    {
                        checkUsernameCmd.Parameters.AddWithValue("@username", lblusername.Text);
                        con.Open();
                        isUsernameUnique = (int)checkUsernameCmd.ExecuteScalar() == 0;
                        con.Close();
                    }

                    // Check if email exists
                    using (SqlCommand checkEmailCmd = new SqlCommand("SELECT COUNT(*) FROM Chatters WHERE email = @useremail", con))
                    {
                        checkEmailCmd.Parameters.AddWithValue("@useremail", lblemail.Text);
                        con.Open();
                        isEmailUnique = (int)checkEmailCmd.ExecuteScalar() == 0;
                        con.Close();
                    }
                }
            }

            // Set error messages if duplicates are found
            if (!isUsernameUnique)
            {
                cvforusername.IsValid = false;
                lblusername.Text = "";
                return;
            }
            if (!isEmailUnique)
            {
                cvforemail.IsValid = false;
                lblemail.Text = "";
                return;
            }

            // If both are unique, proceed to add the new user
            SqlCommand cmd = new SqlCommand();
            cmd.Connection = con;
            cmd.CommandText = "SELECT * FROM Chatters";
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            ds = new DataSet();
            SqlCommandBuilder builder = new SqlCommandBuilder(adapter);

            con.Open();
            adapter.Fill(ds, "chatters");
            con.Close();

            DataTable dt = ds.Tables["chatters"];
            DataRow dr = dt.NewRow();
            dr["name"] = lblusername.Text;
            dr["email"] = lblemail.Text;
            dr["dob"] = lbldob.Text;
            dr["password"] = lblpassword.Text;
            dr["avtar"] = imageData;
            dt.Rows.Add(dr);

            // Update the dataset with new user data
            con.Open();
            adapter.Update(ds, "chatters");
            con.Close();

            // Redirect to the Friends page after registration
            Response.Redirect("Friends.aspx");
        }


        private byte[] ReadFileData(FileUpload uploadControl)
        {
            using (BinaryReader br = new BinaryReader(uploadControl.PostedFile.InputStream))
            {
                return br.ReadBytes(uploadControl.PostedFile.ContentLength);
            }
        }

        private byte[] LocalDefaultImage()
        {
            string defaultImagePath = Server.MapPath("~/Images/avtar.png");
            return File.ReadAllBytes(defaultImagePath);
        }
    }
}