<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="ChatApplication.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:TextBox ID="lbluser" runat="server" Placeholder="Enter user id"></asp:TextBox>
            <asp:TextBox ID="lblfriend" runat="server" Placeholder="Enter friend id"></asp:TextBox>
            <asp:Button ID="setsession" runat="server" Text="Button" OnClientClick="setting_session" OnClick="setsession_Click" />
        </div>
    </form>
</body>
</html>
