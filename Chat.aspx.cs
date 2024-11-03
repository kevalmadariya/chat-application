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
using System.Text;
using System.IO;
using System.Linq.Expressions;

namespace ChatApplication
{
    public class ChatMessage
    {
        public string chat_id { get; set; }
        public string chat_msg_text { get; set; }
        public string sender_id { get; set; }
        public string receiver_id { get; set; }
        public string time { get; set; }
        public string file { get; set; }
        public string file_type { get; set; }
        public string whose_msg { get; set; }//friends message or user message 
    }


    public partial class Chat : System.Web.UI.Page
    {
        private static List<ChatMessage> chatting = new List<ChatMessage>();
        static string user_id;
        static string friend_id;
        
        protected void Page_Load(object sender, EventArgs e)
        {

            ValidationSettings.UnobtrusiveValidationMode = UnobtrusiveValidationMode.None;

            if (!IsPostBack)
            {
                if (Session["user_id"] == null || Session["friend_id"] == null)
                {
                    Response.Redirect("Login.aspx");
                    return;
                }

                user_id = Session["user_id"].ToString();
                friend_id = Session["friend_id"].ToString();

                LoadChatHistory();
            }
            else
            {
                //LoadChatHistory();

            }
        }

        private void LoadChatHistory()
        {
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
                    SqlCommand cmd1 = new SqlCommand(q1, con);
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
                        string imageBase64 = null;

                        if (rdr["file"] != DBNull.Value)
                        {
                            byte[] imageBytes = (byte[])rdr["file"];

                            if (rdr["type"].ToString() == "image")
                            {
                                imageBase64 = "data:image/jpeg;base64," + Convert.ToBase64String(imageBytes);
                            }
                            else
                            {
                                imageBase64 = Convert.ToBase64String(imageBytes);
                            }
                        }

                        ChatMessage message = new ChatMessage
                        {
                            chat_id = rdr["id"].ToString(),
                            chat_msg_text = rdr["message"].ToString(),
                            sender_id = rdr["sender_id"].ToString(),
                            receiver_id = rdr["receiver_id"].ToString(),
                            time = rdr["time"].ToString(),
                            file = imageBase64,
                            file_type = rdr["type"].ToString(),
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
        private void DisplayChatHistory()
        {
            string combinedScript = @"
        <script>
        class PDFHandler2 {
            constructor(imageBase64, fileName = 'document.pdf', messageWrapper) {
                this.imageBase64 = imageBase64;
                this.fileName = fileName;
                this.messageWrapper = messageWrapper;
                this.setupButtons();
            }

            // Convert base64 to Blob
            createPDFBlob() {
                try {
                    const byteCharacters = atob(this.imageBase64);
                    const byteNumbers = new Array(byteCharacters.length);

                    for (let i = 0; i < byteCharacters.length; i++) {
                        byteNumbers[i] = byteCharacters.charCodeAt(i);
                    }

                    const byteArray = new Uint8Array(byteNumbers);
                    return new Blob([byteArray], { type: 'application/pdf' });
                } catch (error) {
                    console.error('Error creating PDF blob:', error);
                    throw error;
                }
            }

            // Open PDF in new tab
            openPDF(event) {
                console.log(""in open pdf"");
                event.preventDefault();

                try {
                    const blob = this.createPDFBlob();
                    const pdfUrl = URL.createObjectURL(blob);

                    const newWindow = window.open();
                    if (newWindow) {
                        newWindow.location.href = pdfUrl;
                        // Cleanup URL object after window loads
                        newWindow.onload = () => {
                            URL.revokeObjectURL(pdfUrl);
                        };
                        console.log(""newWindown"");
                    } else {
                        alert('Please allow popup windows for this site');
                    }
                } catch (error) {
                    console.error('Error opening PDF:', error);
                    alert('Error opening PDF. Please try again.');
                }
            }

            // Save PDF
            savePDF(event) {
                event.preventDefault();

                try {
                    const blob = this.createPDFBlob();
                    const downloadUrl = URL.createObjectURL(blob);

                    const downloadLink = document.createElement('a');
                    downloadLink.style.display = 'none';
                    downloadLink.href = downloadUrl;
                    downloadLink.download = this.fileName;

                    document.body.appendChild(downloadLink);
                    downloadLink.click();

                    // Cleanup
                    setTimeout(() => {
                        document.body.removeChild(downloadLink);
                        URL.revokeObjectURL(downloadUrl);
                    }, 100);
                } catch (error) {
                    console.error('Error saving PDF:', error);
                    alert('Error saving PDF. Please try again.');
                }
            }

            setupButtons() {
                // Create Open button
                const openButton = document.createElement('button');
                openButton.classList.add('pdf-button', 'open-button');
                openButton.innerHTML = '📂 Open PDF';
                openButton.onclick = this.openPDF.bind(this);
                // Create Save button
                const saveButton = document.createElement('button');
                saveButton.classList.add('pdf-button', 'save-button');
                saveButton.innerHTML = '💾 Save As';
                saveButton.onclick = this.savePDF.bind(this);

                // Add buttons to container
                const buttonContainer = document.createElement('div');
                buttonContainer.classList.add('pdf-buttons');
                buttonContainer.appendChild(openButton);
                buttonContainer.appendChild(saveButton);

                if (this.messageWrapper && this.messageWrapper instanceof Element) {
                    this.messageWrapper.appendChild(buttonContainer);
                } else {
                    console.error('Invalid MessageWrapper element provided');
                }
            }
        }
        function appendMessage(message, sender, imageData, chatId, fileType) {
            const chatContainer = document.getElementById('chatContainer');
            const messageWrapper = document.createElement('div');
            messageWrapper.classList.add('message');
            messageWrapper.classList.add(sender === 'user' ? 'right' : 'left');
            messageWrapper.setAttribute('data-message-id', chatId); // Add message ID as data attribute
            
            // Handle image if present
            if (fileType === 'Image') {
                const imageElement = document.createElement('img');
                imageElement.src = `data:image/png;base64,${imageData}`;
                imageElement.style.maxWidth = '200px';
                imageElement.style.maxHeight = '200px';
                imageElement.style.marginTop = '8px';
                imageElement.style.borderRadius = '4px';
                messageWrapper.appendChild(imageElement);
            }
            else if(imageData){
                messageWrapper.classList.add('message');
                messageWrapper.classList.add('left');

                const pdfContainer = document.createElement('div');
                pdfContainer.classList.add('pdf-container');

                const pdfPreview = document.createElement('div');
                pdfPreview.classList.add('pdf-preview');
                pdfPreview.innerHTML = `<div class='pdf-icon'>📄</div><div class='pdf-filename'>${fileType}</div>`;

                pdfContainer.appendChild(pdfPreview);
                messageWrapper.appendChild(pdfContainer);
                const pdfHandler = new PDFHandler2(imageData, fileType , messageWrapper); 

            }

            if(message){
                const messageText = document.createElement('div');
                messageText.classList.add('message-text');
                messageText.textContent = RestoreString(message);
                messageWrapper.appendChild(messageText);
            }
           
 
            chatContainer.appendChild(messageWrapper);

            const clearfix = document.createElement('div');
            clearfix.classList.add('clearfix');
            chatContainer.appendChild(clearfix);
      
            const deleteButton = document.createElement('button');
            deleteButton.classList.add('delete-button');
            deleteButton.innerHTML = '❌';
            deleteButton.title = 'Delete Message';
            deleteButton.hidden = 'hidden';
            
            messageWrapper.appendChild(deleteButton);            

            deleteButton.onclick = function(e) {
                e.preventDefault(); // Prevent any default button behavior
        
                if (confirm('Are you sure you want to delete this message?')) {
                    console.log('Deleting message:', chatId);
            
                    $.ajax({
                        type: 'POST',
                        url: 'Chat.aspx/DeleteMessage',
                        data: JSON.stringify({ chatId: chatId }),
                        contentType: 'application/json; charset=utf-8',
                        dataType: 'json',
                        success: function(response) {
                            if (response.d === 'Message deleted successfully') {
                                // Remove the message element from DOM
                                messageWrapper.remove();
                                clearfix.remove();
                        
                                // Optional: Show a success notification
                                const notification = document.createElement('div');
                                notification.textContent = 'Message deleted';
                                notification.style.cssText = `
                                    position: fixed;
                                    bottom: 20px;
                                    right: 20px;
                                    background: #4CAF50;
                                    color: white;
                                    padding: 10px 20px;
                                    border-radius: 4px;
                                    z-index: 1000;
                                `;
                                document.body.appendChild(notification);
                        
                                // Remove notification after 3 seconds
                                setTimeout(() => notification.remove(), 3000);
                            } else {
                                alert('Failed to delete message: ' + response.d);
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error('Error deleting message:', error);
                            alert('Error deleting message. Please try again.');
                        }
                    });
                }
            };
    
            // Show delete button on hover (optional)
            messageWrapper.addEventListener('mouseenter', () => {
                deleteButton.hidden = false;
            });
    
            messageWrapper.addEventListener('mouseleave', () => {
                deleteButton.hidden = true;
            });
            
            function RestoreString(safeString) {
            if (!safeString) return safeString;

            const replacements = [
                { pattern: /-----SINGLE_QUOTE-----/g, replacement: ""'"" },
                { pattern: /-------DOUBLE_QUOTE-------/g, replacement: '""' },
                { pattern: /-----BACKSLASH-----/g, replacement: '\\' },
                { pattern: /-----LESS_THAN-----/g, replacement: '<' },
                { pattern: /-----GREATER_THAN-----/g, replacement: '>' },
                { pattern: /-----AMPERSAND-----/g, replacement: '&' },
                { pattern: /-----DOLLAR_SIGN-----/g, replacement: '$' },
                { pattern: /-----HASH-----/g, replacement: '#' },
                { pattern: /-----PERCENTAGE-----/g, replacement: '%' },
                { pattern: /-----CARET-----/g, replacement: '^' },
                { pattern: /-----ASTERISK-----/g, replacement: '*' },
                { pattern: /-----OPEN_PARENTHESIS-----/g, replacement: '(' },
                { pattern: /-----CLOSE_PARENTHESIS-----/g, replacement: ')' },
                { pattern: /-----PLUS-----/g, replacement: '+' },
                { pattern: /-----EQUALS-----/g, replacement: '=' },
                { pattern: /-----TILDE-----/g, replacement: '~' },
                { pattern: /-----BACKTICK-----/g, replacement: '`' },
                { pattern: /-----PIPE-----/g, replacement: '|' },
                { pattern: /-----OPEN_SQUARE_BRACKET-----/g, replacement: '[' },
                { pattern: /-----CLOSE_SQUARE_BRACKET-----/g, replacement: ']' },
                { pattern: /-----OPEN_CURLY_BRACE-----/g, replacement: '{' },
                { pattern: /-----CLOSE_CURLY_BRACE-----/g, replacement: '}' },
                { pattern: /-----COLON-----/g, replacement: ':' },
                { pattern: /-----SEMICOLON-----/g, replacement: ';' },
                { pattern: /-----COMMA-----/g, replacement: ',' },
                { pattern: /-----QUESTION_MARK-----/g, replacement: '?' },
                { pattern: /-----AT_SIGN-----/g, replacement: '@' }
            ];

            return replacements.reduce((str, replacement) =>
                str.replace(replacement.pattern, replacement.replacement),
                safeString
            );
        }
            
        }";
            foreach (var message in chatting)
            {
                string msg = message.chat_msg_text;
                string sender = message.whose_msg;
                string img = message.file;
                string chat_id = message.chat_id;
                string file_type = message.file_type;
                combinedScript += "appendMessage('" + msg + "','" + sender + "','" + img + "','" + chat_id + "','" + file_type + "');";
            }
            combinedScript += "</script>";

            ClientScript.RegisterStartupScript(this.GetType(), "appendMessage", combinedScript, false);
        }


        [WebMethod]
        public static void SaveMessage(string msg, string sender, string img,string fileType,string fileName)
        {
            msg = SafeString(msg);
            if (fileType.StartsWith("image"))
            {
                fileType = "Image";
            }
            else
            {
                fileType = fileName;
            }

            byte[] imageData = null;
            if (!string.IsNullOrEmpty(img))
            {
                imageData = Convert.FromBase64String(img);
            }

            // Add message to chat history
            string r_id = HttpContext.Current.Session["friend_id"].ToString();
            string s_id = HttpContext.Current.Session["user_id"].ToString();

            DateTime localDate = DateTime.Now;

            chatting.Add(new ChatMessage { chat_msg_text = msg, whose_msg = sender });


            SqlConnection con = new SqlConnection();
            con.ConnectionString = ConfigurationManager.ConnectionStrings["userConnection"].ConnectionString;

            try
            {
                //no need of finally
                using (con)
                {
                    SqlCommand cmd = new SqlCommand();
                    cmd.Connection = con;
                    cmd.CommandText = "select * from Chat";

                    SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                    DataSet ds = new DataSet();
                    SqlCommandBuilder builder = new SqlCommandBuilder(adapter);

                    con.Open();
                    adapter.Fill(ds, "Chat");
                    con.Close();

                    DataTable dt = ds.Tables["Chat"];
                    DataRow dr = dt.NewRow();
                    dr["message"] = msg;
                    dr["sender_id"] = s_id;
                    dr["receiver_id"] = r_id;
                    dr["time"] = localDate;
                    if (imageData != null)
                    {
                        dr["file"] = imageData;
                        dr["type"] = fileType;
                    }

                    dt.Rows.Add(dr);
                    con.Open();
                    adapter.Update(ds, "Chat");
                    con.Close();

                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }
        }


        public class ChatModel
        {
            //public int MessageId { get; set; }
            public string MessageText { get; set; }
            public string ImageBase64 { get; set; } // To hold base64 string of image
            public string filetype { get; set; }
        }

        [WebMethod]
        public static List<ChatModel> GetNewMessages()
        {
            string user_id = HttpContext.Current.Session["user_id"].ToString();
            string friend_id = HttpContext.Current.Session["friend_id"].ToString();
            List<ChatModel> newMessages = new List<ChatModel>();

            using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["userConnection"].ConnectionString))
            {
                string query = @"SELECT message, [file] , type 
                        FROM chat 
                        WHERE sender_id = @friend_id 
                        AND receiver_id = @user_id 
                        AND time >= DATEADD(second, -2, GETDATE()) 
                        ORDER BY time";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@user_id", user_id);
                    cmd.Parameters.AddWithValue("@friend_id", friend_id);

                    con.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string message = RestoreString(rdr["message"].ToString());
                            string imageBase64 = null;
                            string type = null;
                            // Properly convert byte array to base64 string
                            if (rdr["file"] != DBNull.Value)
                            {
                                byte[] imageBytes = (byte[])rdr["file"];
                                imageBase64 = Convert.ToBase64String(imageBytes);
                                type = rdr["type"].ToString();
                            }

                            var chatmodel = new ChatModel
                            {
                                MessageText = message,
                                ImageBase64 = imageBase64,
                                filetype = type
                            };

                            newMessages.Add(chatmodel);
                        }
                    }
                }
            }
            return newMessages;
        }

        
        [WebMethod]
        public static string DeleteMessage(int chatId)
        {
            SqlConnection con = new SqlConnection();
            con.ConnectionString = ConfigurationManager.ConnectionStrings["userConnection"].ConnectionString;

            using (con)
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("DELETE FROM Chat WHERE Id = @chatId", con);
                    cmd.Parameters.AddWithValue("@chatId", chatId);

                    con.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();
                    con.Close();

                    if (rowsAffected > 0)
                    {
                        return "Message deleted successfully";
                    }
                    else
                    {
                        return "Message not found";
                    }
                }
                catch (Exception ex)
                {
                    // Log exception (optional)
                    return "Error: " + ex.Message;
                }
            }
        }

        //public static string SafeString(string input)
        //{
        //    if (string.IsNullOrEmpty(input))
        //        return input;

        //    // Replace single quotes with 5 dashes
        //    input = input.Replace("'", "-----");

        //    // Replace double quotes with 7 dashes
        //    input = input.Replace("\"", "-------");

        //    return input;
        //}

        //public static string RestoreString(string safeString)
        //{
        //    if (string.IsNullOrEmpty(safeString))
        //        return safeString;

        //    // Restore single quotes
        //    safeString = safeString.Replace("-----", "'");

        //    // Restore double quotes
        //    safeString = safeString.Replace("-------", "\"");

        //    return safeString;
        //}

        public static string SafeString(string input)
        {
            if (string.IsNullOrEmpty(input))
                return input;

            StringBuilder sb = new StringBuilder(input.Length * 2);

            foreach (char c in input)
            {
                switch (c)
                {
                    case '\'':
                        sb.Append("-----SINGLE_QUOTE-----");
                        break;
                    case '\"':
                        sb.Append("-------DOUBLE_QUOTE-------");
                        break;
                    case '\\':
                        sb.Append("-----BACKSLASH-----");
                        break;
                    case '<':
                        sb.Append("-----LESS_THAN-----");
                        break;
                    case '>':
                        sb.Append("-----GREATER_THAN-----");
                        break;
                    case '&':
                        sb.Append("-----AMPERSAND-----");
                        break;
                    case '$':
                        sb.Append("-----DOLLAR_SIGN-----");
                        break;
                    case '#':
                        sb.Append("-----HASH-----");
                        break;
                    case '%':
                        sb.Append("-----PERCENTAGE-----");
                        break;
                    case '^':
                        sb.Append("-----CARET-----");
                        break;
                    case '*':
                        sb.Append("-----ASTERISK-----");
                        break;
                    case '(':
                        sb.Append("-----OPEN_PARENTHESIS-----");
                        break;
                    case ')':
                        sb.Append("-----CLOSE_PARENTHESIS-----");
                        break;
                    case '+':
                        sb.Append("-----PLUS-----");
                        break;
                    case '=':
                        sb.Append("-----EQUALS-----");
                        break;
                    case '~':
                        sb.Append("-----TILDE-----");
                        break;
                    case '`':
                        sb.Append("-----BACKTICK-----");
                        break;
                    case '|':
                        sb.Append("-----PIPE-----");
                        break;
                    case '[':
                        sb.Append("-----OPEN_SQUARE_BRACKET-----");
                        break;
                    case ']':
                        sb.Append("-----CLOSE_SQUARE_BRACKET-----");
                        break;
                    case '{':
                        sb.Append("-----OPEN_CURLY_BRACE-----");
                        break;
                    case '}':
                        sb.Append("-----CLOSE_CURLY_BRACE-----");
                        break;
                    case ':':
                        sb.Append("-----COLON-----");
                        break;
                    case ';':
                        sb.Append("-----SEMICOLON-----");
                        break;
                    case ',':
                        sb.Append("-----COMMA-----");
                        break;
                    case '?':
                        sb.Append("-----QUESTION_MARK-----");
                        break;
                    case '@':
                        sb.Append("-----AT_SIGN-----");
                        break;
                    default:
                        sb.Append(c);
                        break;
                }
            }

            return sb.ToString();
        }

        public static string RestoreString(string safeString)
        {
            if (string.IsNullOrEmpty(safeString))
                return safeString;

            return safeString
                .Replace("-----SINGLE_QUOTE-----", "'")
                .Replace("-------DOUBLE_QUOTE-------", "\"")
                .Replace("-----BACKSLASH-----", "\\")
                .Replace("-----LESS_THAN-----", "<")
                .Replace("-----GREATER_THAN-----", ">")
                .Replace("-----AMPERSAND-----", "&")
                .Replace("-----DOLLAR_SIGN-----", "$")
                .Replace("-----HASH-----", "#")
                .Replace("-----PERCENTAGE-----", "%")
                .Replace("-----CARET-----", "^")
                .Replace("-----ASTERISK-----", "*")
                .Replace("-----OPEN_PARENTHESIS-----", "(")
                .Replace("-----CLOSE_PARENTHESIS-----", ")")
                .Replace("-----PLUS-----", "+")
                .Replace("-----EQUALS-----", "=")
                .Replace("-----TILDE-----", "~")
                .Replace("-----BACKTICK-----", "`")
                .Replace("-----PIPE-----", "|")
                .Replace("-----OPEN_SQUARE_BRACKET-----", "[")
                .Replace("-----CLOSE_SQUARE_BRACKET-----", "]")
                .Replace("-----OPEN_CURLY_BRACE-----", "{")
                .Replace("-----CLOSE_CURLY_BRACE-----", "}")
                .Replace("-----COLON-----", ":")
                .Replace("-----SEMICOLON-----", ";")
                .Replace("-----COMMA-----", ",")
                .Replace("-----QUESTION_MARK-----", "?")
                .Replace("-----AT_SIGN-----", "@");
        }
        public static void ClearList()
        {
            chatting.Clear();
        }
    }
}