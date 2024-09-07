using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Services;
using System.EnterpriseServices;
using System.Collections;


namespace ChatApplication
{
    public class ChatMessage
    {
        public string chat_msg_text { get; set; }
        public string sender_id { get; set; }
        public string receiver_id { get; set; }
        public string time { get; set; }
        public string whose_msg { get; set; }//friends message or user message 
    }
    public partial class Chat : System.Web.UI.Page
    {
        private static List<ChatMessage> chatting = new List<ChatMessage>();
        static string user_id;
        static string friend_id;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string tabId = Request.QueryString["tabId"];
                
                if (tabId == null)
                {
                    Response.Redirect("Login.aspx");
                    return;
                }
                
                ViewState["tabId"] = tabId;
                
                if (Session["user_id" + tabId] == null || Session["friend_id" + tabId] == null)
                {
                    Response.Redirect("Login.aspx");
                }

                user_id = Session["user_id" + tabId].ToString();
                friend_id = Session["friend_id" + tabId].ToString();

                LoadChatHistory();
            }
            else
            {
                string tabId = ViewState["tabId"] as string;
            }
        }

        private void LoadChatHistory() {
            chatting.Clear();
            SqlConnection con = new SqlConnection();
            con.ConnectionString = ConfigurationManager.ConnectionStrings["userConnection"].ConnectionString;

            try
            {
                //no need of finally
                using (con)
                {
                    //just to find username 
                    string q1 = "select * from chatters where id=" + user_id;
                    SqlCommand cmd1 = new SqlCommand(q1,con);
                    con.Open();
                    SqlDataReader rdr1 = cmd1.ExecuteReader();

                    while (rdr1.Read())
                        Response.Write("user:" + rdr1["name"].ToString());

                    rdr1.Close();

                    //sql query orderd by time and all chat between user and friend
                    string command = "select * from Chat where sender_id = @p1 and receiver_id = @p2 or sender_id=@p2 and receiver_id = @p1 order by time";
                    SqlCommand cmd = new SqlCommand(command, con);
                    cmd.Parameters.AddWithValue("@p1", user_id);
                    cmd.Parameters.AddWithValue("@p2", friend_id);
                    SqlDataReader rdr = cmd.ExecuteReader();
                    while (rdr.Read())
                    {
                        ChatMessage message = new ChatMessage
                        {
                            chat_msg_text = rdr["message"].ToString(),
                            sender_id = rdr["sender_id"].ToString(),
                            receiver_id = rdr["receiver_id"].ToString(),
                            time = rdr["time"].ToString(),
                            whose_msg = (rdr["sender_id"].ToString() == user_id) ? "user" : "friend",
                        };
                        //Response.Write(message.chat_msg_text);
                        chatting.Add(message);
                    }
                    rdr.Close();
                }
            }
            catch (Exception ex)
            {
                Response.Write("error:" + ex.ToString());
            }

            DisplayChatHistory();
        }
        private void DisplayChatHistory() { 
           
            string combinedScript = @" <script>
                                           function appendMessage(message,sender) {
                                                     const chatContainer = document.getElementById('chatContainer');
                                                     const messageElement = document.createElement('div');
                                                     messageElement.classList.add('message');
                                                     messageElement.classList.add(sender === 'user' ? 'right' : 'left');
                                                     messageElement.textContent = message;
                                                     chatContainer.appendChild(messageElement);

                                                     const clearfix = document.createElement('div');
                                                     clearfix.classList.add('clearfix');
                                                     chatContainer.appendChild(clearfix);
                                           }";

              foreach (var message in chatting)
              {
                    string msg = message.chat_msg_text;
                    string sender = message.whose_msg;

                    combinedScript += "appendMessage('" + msg + "','" + sender + "');";
              }
                combinedScript += "</script>";

                ClientScript.RegisterStartupScript(this.GetType(),"appendMessage",combinedScript,false);
        }


        [WebMethod]
        public static void SaveMessage(string msg, string sender,string tabId)
        {
            // Add message to chat history
            string r_id = HttpContext.Current.Session["friend_id" + tabId].ToString();
            string s_id = HttpContext.Current.Session["user_id" + tabId].ToString();

            chatting.Add(new ChatMessage { chat_msg_text = msg, whose_msg = sender });
            SqlConnection con = new SqlConnection();
            con.ConnectionString = ConfigurationManager.ConnectionStrings["userConnection"].ConnectionString;

            try
            {
                //no need of finally
                using (con)
                {
                    string command = "insert into Chat (sender_id,receiver_id,message,time) values(@s_id,@r_id,@msg,@time)";
                    SqlCommand cmd = new SqlCommand(command, con);
                    cmd.Parameters.AddWithValue("@s_id", s_id);
                    cmd.Parameters.AddWithValue("@r_id", r_id);
                    cmd.Parameters.AddWithValue("@msg", msg);
                    DateTime localDate = DateTime.Now;
                    cmd.Parameters.AddWithValue("@time", localDate);

                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                  }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }
        }
        

        [WebMethod]
        public static List<string> GetNewMessages(string tabId)
        {
            string user_id = HttpContext.Current.Session["user_id" + tabId].ToString();
            string friend_id = HttpContext.Current.Session["friend_id" + tabId].ToString();

            List<string> newMessages = new List<string>();

            SqlConnection con = new SqlConnection();
            con.ConnectionString = ConfigurationManager.ConnectionStrings["userConnection"].ConnectionString;

            try
            {
                
                using (con)
                {
                    string query = "SELECT message FROM chat WHERE sender_id=@friend_id and receiver_id=@user_id and time >= DATEADD(second, -2, GETDATE()) ORDER BY time";
                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@user_id", user_id);
                    cmd.Parameters.AddWithValue("@friend_id",friend_id);
                    
                    con.Open();
                    SqlDataReader rdr = cmd.ExecuteReader();
                        
                    while (rdr.Read())
                    {    
                        newMessages.Add(rdr["message"].ToString());
                        Console.Write(rdr["message"].ToString());
                    }
                }

            }
            catch (Exception e)
            {
                Console.Write("error: " + e);
                newMessages.Add(e.ToString());
            }
            return newMessages;
        }
        public static void ClearList()
        {
            chatting.Clear();   
        }  
    }
}