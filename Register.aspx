<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="ChatApplication.Register" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ChatApp Registration</title>
    <style type="text/css">
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f0f2f5;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .container {
            background-color: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
        }

        .form-title {
            color: #1877f2;
            text-align: center;
            margin-bottom: 1.5rem;
            font-size: 24px;
        }

        .form-group {
            margin-bottom: 1rem;
        }

        .form-label {
            display: block;
            margin-bottom: 0.5rem;
            color: #1c1e21;
            font-weight: 500;
        }

        .form-control {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #ddd;
            border-radius: 6px;
            box-sizing: border-box;
            margin-bottom: 0.5rem;
        }

        .form-control:focus {
            outline: none;
            border-color: #1877f2;
            box-shadow: 0 0 0 2px rgba(24, 119, 242, 0.2);
        }

        .validation-error {
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }

        .btn-register {
            background-color: #1877f2;
            color: white;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 6px;
            width: 100%;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .btn-register:hover {
            background-color: #166fe5;
        }

        .validation-summary {
            margin-top: 1rem;
            padding: 1rem;
            border-radius: 6px;
            background-color: #fff2f2;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="form-title">Join ChatApp</h1>
        <form id="form1" runat="server">
            <div class="form-group">
                <label class="form-label">Username</label>
                <asp:TextBox ID="lblusername" runat="server" CssClass="form-control"></asp:TextBox>
                <asp:CustomValidator ID="cvforusername" Display="Dynamic" runat="server" ControlToValidate="lblusername" Text="This username is already taken. Please choose another one." ErrorMessage="Enter another Username" ForeColor="red"></asp:CustomValidator>
                <asp:RequiredFieldValidator ID="rqfvforusername" runat="server" 
                    ControlToValidate="lblusername" 
                    Text="Please enter username" 
                    CssClass="validation-error" 
                    Display="Dynamic"
                    ErrorMessage="Username is required"></asp:RequiredFieldValidator>
            </div>

            <div class="form-group">
                <label class="form-label">Email</label>
                <asp:TextBox ID="lblemail" runat="server" TextMode="Email" CssClass="form-control"></asp:TextBox>
                <asp:CustomValidator ID="cvforemail" Display="Dynamic" runat="server" ControlToValidate="lblusername" Text="This email is already registered. Please use a different email." ErrorMessage="Enter another Email" ForeColor="red"></asp:CustomValidator>
                <asp:RequiredFieldValidator ID="rqdvforemail" runat="server" 
                    ControlToValidate="lblemail" 
                    Text="Please enter email" 
                    CssClass="validation-error" 
                    Display="Dynamic"
                    ErrorMessage="Email is required"></asp:RequiredFieldValidator>
            </div>

            <div class="form-group">
                <label class="form-label">Profile Picture</label>
                <asp:FileUpload ID="lblimage" runat="server" CssClass="form-control"></asp:FileUpload>
                <asp:CustomValidator ID="cvforimage" runat="server" ControlToValidate="lblimage" ClientValidationFunction="cvFileSize_ServerValidate" Text="image not more than 2Mb" ErrorMessage="image upto 2MB allowed" ForeColor="red"></asp:CustomValidator>
            </div>


            <div class="form-group">
                <label class="form-label">Date of Birth</label>
                <asp:TextBox ID="lbldob" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rqfvfordob" runat="server" 
                    ControlToValidate="lbldob" 
                    Text="Please enter date of birth" 
                    CssClass="validation-error" 
                    Display="Dynamic"
                    ErrorMessage="Date of Birth is required"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="cvfordob" runat="server" 
                    ControlToValidate="lbldob" 
                    Type="Date" 
                    MinimumValue="01/01/1924" 
                    MaximumValue="01/01/2025" 
                    Text="Invalid date of birth" 
                    CssClass="validation-error" 
                    Display="Dynamic"
                    ErrorMessage="Date of Birth must be between 1924 and 2025"></asp:RangeValidator>
            </div>

            <div class="form-group">
                <label class="form-label">Password</label>
                <asp:TextBox ID="lblpassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rqfvforpassword" runat="server" 
                    ControlToValidate="lblpassword" 
                    Text="Please enter password" 
                    CssClass="validation-error" 
                    Display="Dynamic"
                    ErrorMessage="Password is required"></asp:RequiredFieldValidator>
            </div>

            <div class="form-group">
                <label class="form-label">Confirm Password</label>
                <asp:TextBox ID="lblcpassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rdfvforcpassword" runat="server" 
                    ControlToValidate="lblcpassword" 
                    Text="Please confirm password" 
                    CssClass="validation-error" 
                    Display="Dynamic"
                    ErrorMessage="Password confirmation is required"></asp:RequiredFieldValidator>
                <asp:CompareValidator ID="cvforcpassword" runat="server" 
                    ControlToCompare="lblpassword" 
                    ControlToValidate="lblcpassword" 
                    Operator="Equal" 
                    Text="Passwords do not match" 
                    CssClass="validation-error" 
                    Display="Dynamic"
                    ErrorMessage="Password confirmation does not match"></asp:CompareValidator>
            </div>

            <asp:Button Text="Create Account" runat="server" OnClick="register" CssClass="btn-register" />

            <asp:ValidationSummary ID="validatesummary" runat="server" 
                CssClass="validation-summary" 
                DisplayMode="BulletList" 
                HeaderText="Please correct the following errors:" />
        </form>
    </div>
</body>

  <script type="text/javascript">
      function cvFileSize_ServerValidate(Source, args) {
          const maxFileSize = 2 * 1024 * 1024; // 2 MB in bytes
          const fileInput = document.getElementById('<%= lblimage.ClientID %>');

          if (fileInput.files && fileInput.files[0]) {
              const fileSize = fileInput.files[0].size;
              args.IsValid = fileSize <= maxFileSize;
          } else {
              args.IsValid = true;
          }

      }
  </script>

</html>