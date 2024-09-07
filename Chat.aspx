<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Chat.aspx.cs" Inherits="ChatApplication.Chat" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Chat Application</title>
     <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

 <style>
     #chatContainer {
         border: 1px solid #ccc;
         width: 300px;
         height: 400px;
         overflow-y: auto;
         margin-bottom: 10px;
         padding: 10px;
     }
     .message {
         padding: 5px;
         margin: 5px 0;
         border-radius: 5px;
         max-width: 200px;
     }
     .left {
         background-color: #e0f7fa;
         text-align: left;
         float: left;
         clear: both;
     }
     .right {
         background-color: #c8e6c9;
         text-align: right;
         float: right;
         clear: both;
     }
     .clearfix {
         clear: both;
     }
 </style>
</head>
<body>

    <form id="form1" runat="server">
        <script type="text/javascript">
            function appendMessageToChat(tempmsg) {
                var chatContainer = document.getElementById('chatContainer');

                // Create a new div element
                var newDiv = document.createElement('div');

                // Set the content of the new div
                newDiv.innerHTML = tempmsg;

                // Append the new div to the chat container
                chatContainer.appendChild(newDiv);

                // Optionally, scroll to the bottom to show the new message
                chatContainer.scrollTop = chatContainer.scrollHeight;
            }
</script>
        <div id="chatContainer"></div>
        <br />
        <asp:TextBox ID="txtUserMessage" runat="server" Width="200px" Placeholder="User's message"></asp:TextBox>
        <asp:Button ID="btnSender" runat="server" Text="Send" OnClientClick="sendMessage(); return false;" />
    </form>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script type="text/javascript">
        var $jq = jQuery.noConflict(); 
        $jq(document).ready(function () {

            window.sendMessage = function () {
                var message = $('#<%= txtUserMessage.ClientID %>').val();
                var tabId = "<%= Request.QueryString["tabId"] %>"; // Include tabId in AJAX data,these take query 
                //user...
                $.ajax({
                    type: "POST",
                    url: "chat.aspx/SaveMessage",
                    data: JSON.stringify({ msg: message, sender: 'user', tabId: tabId }),
                    contentType: "application/json; chatset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        //append user message to right side in container
                        $('#chatContainer').append('<div class="message right">' + message + '</div><div class="clearfix"></div>');
                        $('#<%= txtUserMessage.ClientID %>').val('');
                        scrollToBottom(); // Scroll to bottom after appending the message
                    }
                });
            }
            //every two second chaeck for message is there any message send by friend or not
            function pollForMessages() {
                var tabId = "<%= Request.QueryString["tabId"] %>"; // Include tabId in AJAX data
                console.log("...");
                $.ajax({
                    type: "POST",
                    url: "chat.aspx/GetNewMessages",
                    data: JSON.stringify({ tabId: tabId }), // pass tabId
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var messages = response.d;
                        for (var i = 0; i < messages.length; i++) {
                            var message = messages[i];
                            // Append friend message to left side in container
                            $jq('#chatContainer').append('<div class="message left">' + message + '</div><div class="clearfix"></div>');
                            scrollToBottom(); // Scroll to bottom after appending the message   
                        }
                    },
                    complete: function () {
                        setTimeout(pollForMessages, 2000);
                    }//every 2 second
                });
            }

            function scrollToBottom() {
                var chatContainer = $jq('#chatContainer');
                chatContainer.scrollTop(chatContainer[0].scrollHeight);
            }

            $(document).ready(function () {
                pollForMessages();
            });
        });
    </script>
</body>
</html>
