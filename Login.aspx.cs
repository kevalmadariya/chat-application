using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ChatApplication
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void setsession_Click(object sender, EventArgs e)
        {
            //string uniqueTabId = Guid.NewGuid().ToString();
            Session["user_id"] = lbluser.Text;//unique session store
            Session["friend_id"] = lblfriend.Text;
            Response.Redirect("Chat.aspx");
            //Response.Redirect("chat.aspx?tabId=" + uniqueTabId);
        }
    }
}