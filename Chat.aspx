  ﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Chat.aspx.cs" Inherits="ChatApplication.Chat" %>

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
     .message {
    position: relative;
    padding: 5px;
    margin: 5px 0;
    border-radius: 5px;
    max-width: 200px;
    }

    .message .delete-button {
        display: none; /* Hide button by default */
        position: absolute;
        top: 5px;
        right: 5px;
        background: none;
        border: none;
        cursor: pointer;
        font-size: 16px;
    }

    .message:hover .delete-button {
        display: inline-block; /* Show button on hover */
    }

    .pdf-preview, .pdf-message-preview {
    display: flex;
    align-items: center;
    padding: 8px;
    background: #f5f5f5;
    border-radius: 4px;
    margin-top: 8px;
}


.pdf-container {
    background: #f5f5f5;
    border-radius: 8px;
    padding: 12px;
    margin-top: 8px;
    width: fit-content;
}

.pdf-preview {
    display: flex;
    align-items: center;
    margin-bottom: 8px;
}

.pdf-icon {
    font-size: 24px;
    margin-right: 8px;
}

.pdf-filename {
    font-size: 14px;
    color: #333;
    word-break: break-word;
}

.pdf-buttons {
    display: flex;
    gap: 8px;
    margin-top: 8px;
}

.pdf-button {
    padding: 6px 12px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    display: flex;
    align-items: center;
    gap: 4px;
    transition: background-color 0.2s;
}

.open-button {
    background-color: #e3f2fd;
    color: #1976d2;
}

.open-button:hover {
    background-color: #bbdefb;
}

.save-button {
    background-color: #e8f5e9;
    color: #2e7d32;
}

.save-button:hover {
    background-color: #c8e6c9;
}
 </style>
</head>
<body>
     
    <form id="form1" runat="server">
        <div id="chatContainer"></div>
        <div id="emojiPicker" style="display:none; position:absolute; background:white; border:1px solid #ccc; 
           padding:10px; border-radius:5px; box-shadow:0 2px 5px rgba(0,0,0,0.2); z-index:1000;">
        </div>
        <div id="upload" style="margin-top:20px;"></div>
        <br />
        <img src="Images/attach.png" alt="Attach File" style="width:24px; cursor:pointer; vertical-align:middle;" onclick="triggerFileUpload();" />
        <img src="https://cdn-icons-png.flaticon.com/512/1500/1500458.png" alt="Add Emoji" style="width:24px; cursor:pointer; margin-left:5px; vertical-align:middle;" 
         onclick  ="toggleEmojiPicker();" />


        <asp:FileUpload ID="fileUploader" runat="server" Style="display:none;"  OnChange="previewFile()" />
        <asp:TextBox ID="txtUserMessage" runat="server" Width="200px" Placeholder="User's message"></asp:TextBox>
        <asp:CustomValidator ID="cvforchat" runat="server" ControlToValidate="txtUserMessage" Display="Dynamic" ForeColor="Red"></asp:CustomValidator>
        <asp:Button ID="btnSender" runat="server" Text="Send" OnClientClick="sendMessage(); return false;" />
    </form>
    <script>
        // Common emojis array
        const commonEmojis = [
            '😊', '😂', '🤣', '❤️', '😍',
            '👍', '😒', '😘', '😭', '😩',
            '🙂', '😔', '😉', '😌', '😁',
            '😎', '😢', '🙄', '😳', '😜',
            '😴', '😪', '😯', '🤔', '😐',
            '✅','🙏','💡', '📊', '🎯', 
            '👋', '💪', '🤝', '⭐', '🔥',
            '✨', '🎉', '🎯', '💯', 
        ];

        // Initialize emoji picker
        function initEmojiPicker() {
            const emojiPicker = document.getElementById('emojiPicker');

            // Clear existing content
            emojiPicker.innerHTML = '';

            // Create emoji grid
            commonEmojis.forEach(emoji => {
                const emojiSpan = document.createElement('span');
                emojiSpan.textContent = emoji;
                emojiSpan.style.cssText = `
            cursor: pointer;
            padding: 5px;
            font-size: 20px;
            display: inline-block;
            transition: transform 0.1s;
        `;

                // Hover effect
                emojiSpan.onmouseover = () => {
                    emojiSpan.style.transform = 'scale(1.2)';
                };
                emojiSpan.onmouseout = () => {
                    emojiSpan.style.transform = 'scale(1)';
                };

                // Click handler
                emojiSpan.onclick = () => {
                    addEmojiToMessage(emoji);
                };

                emojiPicker.appendChild(emojiSpan);
            });
        }

        // Toggle emoji picker visibility
        function toggleEmojiPicker() {
            const emojiPicker = document.getElementById('emojiPicker');
            const emojiButton = event.target;

            if (emojiPicker.style.display === 'none') {
                // Position the picker below the emoji button
                const buttonRect = emojiButton.getBoundingClientRect();
                emojiPicker.style.top = `${buttonRect.bottom + window.scrollY + 5}px`;
                emojiPicker.style.left = `${buttonRect.left + window.scrollX}px`;

                emojiPicker.style.display = 'block';
                initEmojiPicker();

                // Close picker when clicking outside
                document.addEventListener('click', closeEmojiPicker);
            } else {
                closeEmojiPicker();
            }

            event.stopPropagation();
        }

        // Close emoji picker
        function closeEmojiPicker(event) {
            const emojiPicker = document.getElementById('emojiPicker');
            if (event && (event.target.closest('#emojiPicker') || event.target.closest('img[alt="Add Emoji"]'))) {
                return;
            }
            emojiPicker.style.display = 'none';
            document.removeEventListener('click', closeEmojiPicker);
        }

        // Add emoji to message
        function addEmojiToMessage(emoji) {
            const txtUserMessage = document.getElementById('<%= txtUserMessage.ClientID %>');
            txtUserMessage.value += emoji;
            txtUserMessage.focus();
        }

        // Add CSS to your stylesheet
        const style = document.createElement('style');
        style.textContent = `
    #emojiPicker {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 5px;
        max-width: 250px;
        background: white;
    }
    
    #emojiPicker span:hover {
        background: #f0f0f0;
        border-radius: 5px;
    }
`;
        document.head.appendChild(style);


    </script>
    <script>
        class PDFHandler {
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
                console.log("in open pdf");
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
                        console.log("newWindown");
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

        function triggerFileUpload() {
            document.getElementById('<%= fileUploader.ClientID %>').click();
        }

        function appendMessageToChat(tempmsg) {
            var chatContainer = document.getElementById('chatContainer');
            var newDiv = document.createElement('div');
            newDiv.innerHTML = tempmsg;
            chatContainer.appendChild(newDiv);
            chatContainer.scrollTop = chatContainer.scrollHeight;
        }


        function previewFile() {
            const fileInput = document.getElementById('<%= fileUploader.ClientID %>');
            const file = fileInput.files[0];
            const uploadDiv = document.getElementById('upload');
            uploadDiv.innerHTML = '';

            if (file && file.type) {
                const fileType = file.type;
                const fileReader = new FileReader();

                if (fileType.startsWith("image/")) {
                    fileReader.onload = function (e) {
                        const img = document.createElement('img');
                        img.src = e.target.result;
                        img.style.maxWidth = "80px";
                        img.style.maxHeight = "80px"
                        uploadDiv.appendChild(img);
                    };
                    fileReader.readAsDataURL(file);
                } else if (fileType === "application/pdf") {
                    const previewContainer = document.createElement('div');
                    previewContainer.className = 'pdf-preview';
                    previewContainer.innerHTML = `
                    <div class="pdf-icon">📄</div>
                    <div class="pdf-filename">${file.name}</div>
                   `;
                    uploadDiv.appendChild(previewContainer);

                } 
                else
                { 
                      uploadDiv.innerHTML = "<p>Unsupported file format.</p>";
                }

            }
        }
    </script>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

    <script type="text/javascript">
        var $jq = jQuery.noConflict();
        $jq(document).ready(function () {

            window.sendMessage = function () {
                const uploadDiv = document.getElementById('upload');
                uploadDiv.innerHTML = '';

                var message = SafeString($('#<%= txtUserMessage.ClientID %>').val());
                var fileInput = document.getElementById('<%= fileUploader.ClientID %>');
                var imageBase64 = "";

                if (fileInput.files && fileInput.files[0]) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        imageBase64 = e.target.result.split(',')[1];
                        const file = fileInput.files[0];
                        const fileType = file.type;
                        const fileName = file.name;

                        $.ajax({
                            type: "POST",
                            url: "chat.aspx/SaveMessage",
                            data: JSON.stringify({
                                    msg: message,
                                    sender: 'user',
                                    img: imageBase64,
                                    fileType: fileType,
                                    fileName: fileName
                            }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                console.log(message);
                                const chatContainer = document.getElementById('chatContainer');

                                const messageWrapper = document.createElement('div');
                                messageWrapper.classList.add('message');
                                messageWrapper.classList.add('right');

                                if (fileType === 'application/pdf') {
                                    // PDF handling code remains the 

                                    const pdfContainer = document.createElement('div');
                                    pdfContainer.classList.add('pdf-container');

                                    const pdfPreview = document.createElement('div');
                                    pdfPreview.classList.add('pdf-preview');
                                    pdfPreview.innerHTML = `<div class="pdf-icon">📄</div><div class="pdf-filename">${fileName}</div>`;

                                    pdfContainer.appendChild(pdfPreview);
                                    messageWrapper.appendChild(pdfContainer);

                                    // Create button container
                                    //const buttonContainer = document.createElement('div');
                                    //buttonContainer.classList.add('pdf-buttons');

                                    // Create Open button
                                    //const openButton = document.createElement('button');
                                    //openButton.classList.add('pdf-button', 'open-button');
                                    //openButton.innerHTML = '👁️ Open';
                                    const pdfHandler = new PDFHandler(imageBase64, fileName, messageWrapper);
                                    if (message) {
                                        const messageText = document.createElement('div');
                                        messageText.classList.add('message-text');
                                        messageText.textContent = RestoreString(message);
                                        messageWrapper.appendChild(messageText);
                                    }
                                    //openButton.onclick = function () {
                                    //    pdfHandler.openPDF();
                                        //const byteCharacters = atob(imageBase64);
                                        //const byteNumbers = new Array(byteCharacters.length);
                                        //for (let i = 0; i < byteCharacters.length; i++) {
                                        //    byteNumbers[i] = byteCharacters.charCodeAt(i);
                                        //}
                                        //const byteArray = new Uint8Array(byteNumbers);
                                        //const blob = new Blob([byteArray], { type: 'application/pdf' });
                                        //const pdfUrl = URL.createObjectURL(blob);
                                        //window.open(pdfUrl, '_blank');

                                    //};

                                    // Create Save As button
                                    //const saveButton = document.createElement('button');
                                    //saveButton.classList.add('pdf-button', 'save-button');
                                    //saveButton.innerHTML = '💾 Save As';
                                    //saveButton.onclick = function () {
                                    //    pdfHandler.savePDF();
                                        //const byteCharacters = atob(imageBase64);
                                        //const byteNumbers = new Array(byteCharacters.length);
                                        //for (let i = 0; i < byteCharacters.length; i++) {
                                        //    byteNumbers[i] = byteCharacters.charCodeAt(i);
                                        //}
                                        //const byteArray = new Uint8Array(byteNumbers);
                                        //const blob = new Blob([byteArray], { type: 'application/pdf' });

                                        //const downloadLink = document.createElement('a');
                                        //downloadLink.href = URL.createObjectURL(blob);
                                        //downloadLink.download = fileName || 'document.pdf';
                                        //document.body.appendChild(downloadLink);
                                        //downloadLink.click();
                                        //document.body.removeChild(downloadLink);
                                        //URL.revokeObjectURL(downloadLink.href);
                                    //};

                                    //buttonContainer.appendChild(openButton);
                                    //buttonContainer.appendChild(saveButton);
                                    //pdfContainer.appendChild(buttonContainer);

                                    //chatContainer.appendChild(messageWrapper);
                                } else {

                                    if (imageBase64 && fileType !== 'application/pdf') {
                                        const imageElement = document.createElement('img');
                                        imageElement.src = `data:${fileType};base64,${imageBase64}`;
                                        imageElement.style.maxWidth = '200px';
                                        imageElement.style.maxHeight = '200px';
                                        imageElement.style.marginTop = '8px';
                                        imageElement.style.borderRadius = '4px';
                                        messageWrapper.appendChild(imageElement);
                                    }

                                    if (message) {
                                        const messageText = document.createElement('div');
                                        messageText.classList.add('message-text');
                                        messageText.textContent = RestoreString(message);
                                        messageWrapper.appendChild(messageText);
                                    }

                                }
                                const deleteButton = document.createElement('button');
                                deleteButton.classList.add('delete-button');
                                deleteButton.innerHTML = '❌';
                                deleteButton.title = 'Delete Message';
                                deleteButton.hidden = true;

                                messageWrapper.onmouseenter = () => deleteButton.hidden = false;
                                messageWrapper.onmouseleave = () => deleteButton.hidden = true;

                                deleteButton.onclick = function () {
                                    messageWrapper.remove();
                                };

                                messageWrapper.appendChild(deleteButton);
                                chatContainer.appendChild(messageWrapper);

                                const clearfix = document.createElement('div');
                                clearfix.classList.add('clearfix');
                                chatContainer.appendChild(clearfix);


                                $('#<%= txtUserMessage.ClientID %>').val('');
                    $('#<%= fileUploader.ClientID %>').val('');
                    scrollToBottom();
                },
                error: function(xhr, status, error) {
                    console.error('Error:', error);
                    console.error('Status:', status);
                    console.error('Response:', xhr.responseText);
                }
            });
        };
        reader.readAsDataURL(fileInput.files[0]);
    } else {
        // For text-only messages, match the same parameter structure as file messages
        $.ajax({
            type: "POST",
            url: "chat.aspx/SaveMessage",
            data: JSON.stringify({ 
                msg: message,
                sender: 'user',
                img: '',
                fileType: '',
                fileName:''
            }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                const chatContainer = document.getElementById('chatContainer');

                const messageWrapper = document.createElement('div');
                messageWrapper.classList.add('message');
                messageWrapper.classList.add('right');

                const messageText = document.createElement('div');
                messageText.classList.add('message-text');
                messageText.textContent = RestoreString(message);
                messageWrapper.appendChild(messageText);

                
                chatContainer.appendChild(messageWrapper);

                const clearfix = document.createElement('div');
                clearfix.classList.add('clearfix');
                chatContainer.appendChild(clearfix);

                $('#<%= txtUserMessage.ClientID %>').val('');
                $('#<%= fileUploader.ClientID %>').val('');
            },
            error: function (xhr, status, error) {
                console.error('Error:', error);
                console.error('Status:', status);
                console.error('Response:', xhr.responseText);
            }
        });
                }
            };
            function pollForMessages() {

                //console.log("...");
                $.ajax({
                    type: "POST",
                    url: "chat.aspx/GetNewMessages",
                    data: JSON.stringify({}),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response && response.d) {
                            var messages = response.d;
                            for (var i = 0; i < messages.length; i++) {
                                var message = messages[i];

                                //var messageHtml = '<div class="message left">';
                                const chatContainer = document.getElementById('chatContainer');

                                const messageWrapper = document.createElement('div');
                                messageWrapper.classList.add('message');
                                messageWrapper.classList.add('left');

                                if (message.filetype === 'Image') {
                                    const imageElement = document.createElement('img');
                                    imageElement.src = `data:image/png;base64,${message.ImageBase64}`;
                                    imageElement.style.maxWidth = '200px';
                                    imageElement.style.maxHeight = '200px';
                                    imageElement.style.marginTop = '8px';
                                    imageElement.style.borderRadius = '4px';
                                    messageWrapper.appendChild(imageElement);

                                } else if (message.ImageBase64) {

                                    const pdfContainer = document.createElement('div');
                                    pdfContainer.classList.add('pdf-container');

                                    const pdfPreview = document.createElement('div');
                                    pdfPreview.classList.add('pdf-preview');
                                    pdfPreview.innerHTML = `<div class="pdf-icon">📄</div><div class="pdf-filename">${message.filetype}</div>`;

                                    pdfContainer.appendChild(pdfPreview);
                                    messageWrapper.appendChild(pdfContainer);

                                    const pdfHandler = new PDFHandler(message.ImageBase64, message.filetype, messageWrapper);

                                    chatContainer.appendChild(messageWrapper);
                                }

                                if (message.MessageText) {

                                    const messageText = document.createElement('div');
                                    messageText.classList.add('message-text');
                                    messageText.textContent = RestoreString(message.MessageText);
                                    messageWrapper.appendChild(messageText);

                                }

                                const deleteButton = document.createElement('button');
                                deleteButton.classList.add('delete-button');
                                deleteButton.innerHTML = '❌';
                                deleteButton.title = 'Delete Message';
                                deleteButton.hidden = 'hidden';

                                messageWrapper.appendChild(deleteButton);

                                deleteButton.onclick = function (e) {
                                    e.preventDefault(); // Prevent any default button behavior

                                    if (confirm('Are you sure you want to delete this message?')) {
                                        console.log('Deleting message:', chatId);

                                        $.ajax({
                                            type: 'POST',
                                            url: 'Chat.aspx/DeleteMessage',
                                            data: JSON.stringify({ chatId: chatId }),
                                            contentType: 'application/json; charset=utf-8',
                                            dataType: 'json',
                                            success: function (response) {
                                                if (response.d === 'Message deleted successfully') {
                                                    // Remove the message element from DOM
                                                    messageWrapper.remove();
                                                    clearfix.remove();

                                                    // Optional: Show a success notification
                                                    const notification = document.createElement('div');
                                                    notification.textContent = 'Message deleted';
                                                    notification.style.cssText = `position: fixed;bottom: 20px;right: 20px;background: #4CAF50;color: white;padding: 10px 20px;border-radius: 4px;z-index: 1000;`;
                                                    document.body.appendChild(notification);

                                                    // Remove notification after 3 seconds
                                                    setTimeout(() => notification.remove(), 3000);
                                                } else {
                                                    alert('Failed to delete message: ' + response.d);
                                                }
                                            },
                                            error: function (xhr, status, error) {
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


                                chatContainer.appendChild(messageWrapper);

                                const clearfix = document.createElement('div');
                                clearfix.classList.add('clearfix');
                                chatContainer.appendChild(clearfix);
                                //messageHtml += '</div><div class="clearfix"></div>';
                                //$jq('#chatContainer').append(messageHtml);

                                scrollToBottom();


                            }
                        }
                    },
                    complete: function () {
                        setTimeout(pollForMessages, 2000);
                    }//every 2 second
                });
            }
            

            function triggerPDFSave(pdfHandler) {
                const syntheticEvent = new Event('synthetic');
                pdfHandler.savePDF(syntheticEvent);
            }

            function escapeHtml(unsafe) {
                return unsafe
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/"/g, "&quot;")
                    .replace(/'/g, "&#039;");
            }

            function scrollToBottom() {
                var chatContainer = $jq('#chatContainer');
                chatContainer.scrollTop(chatContainer[0].scrollHeight);
            }

            $(document).ready(function () {
                pollForMessages();
            });
            

        });

        

        // SafeString function in JavaScript
        function SafeString(input) {
            if (!input) return input;

            return input.replace(/['"\\<>&$#%^*()+=~`|[\]{}:;,?@]/g, function (match) {
                const specialCharMap = {
                    "'": "-----SINGLE_QUOTE-----",
                    '"': "-------DOUBLE_QUOTE-------",
                    '\\': "-----BACKSLASH-----",
                    '<': "-----LESS_THAN-----",
                    '>': "-----GREATER_THAN-----",
                    '&': "-----AMPERSAND-----",
                    '$': "-----DOLLAR_SIGN-----",
                    '#': "-----HASH-----",
                    '%': "-----PERCENTAGE-----",
                    '^': "-----CARET-----",
                    '*': "-----ASTERISK-----",
                    '(': "-----OPEN_PARENTHESIS-----",
                    ')': "-----CLOSE_PARENTHESIS-----",
                    '+': "-----PLUS-----",
                    '=': "-----EQUALS-----",
                    '~': "-----TILDE-----",
                    '`': "-----BACKTICK-----",
                    '|': "-----PIPE-----",
                    '[': "-----OPEN_SQUARE_BRACKET-----",
                    ']': "-----CLOSE_SQUARE_BRACKET-----",
                    '{': "-----OPEN_CURLY_BRACE-----",
                    '}': "-----CLOSE_CURLY_BRACE-----",
                    ':': "-----COLON-----",
                    ';': "-----SEMICOLON-----",
                    ',': "-----COMMA-----",
                    '?': "-----QUESTION_MARK-----",
                    '@': "-----AT_SIGN-----"
                };
                return specialCharMap[match];
            });
        }

        // RestoreString function in JavaScript
        function RestoreString(safeString) {
            if (!safeString) return safeString;

            const replacements = [
                { pattern: /-----SINGLE_QUOTE-----/g, replacement: "'" },
                { pattern: /-------DOUBLE_QUOTE-------/g, replacement: '"' },
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
    </script>
</body>
</html>