<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Diagnostics.aspx.cs" Inherits="ReportViewer2013.Diagnostics" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Diagnostics</title>
</head>
<body>
    <form id="form1" runat="server">
        <h1>Diagnostics for the Report Viewer project</h1>
        <div>
            <h3>Intro:</h3>
            <p>If you are having problems getting these example files to run, 
            check this information and confirm that the settings are correct, 
            the permissions are valid and required files are present.</p><br />

            <h3>Diagnostics:</h3>
            <table border="1" cellspacing="0" cellpadding="4">
            <tr style="background-color:lightblue">
                <th>Test</th><th>Settings</th><th>Result</th>
            </tr>
            <tr>
                <td><b>DB Connection</b></td>
                <td> <asp:Label ID="lblConnectionString" runat="server" /></td>
                <td> <asp:Label ID="lblConnectionTest" runat="server" /></td>
            </tr><tr>
                <td><b>Report Path</b></td>
                <td> <asp:Label ID="lblReportPath" runat="server" /></td>
                <td> Permissions: <asp:Label ID="lblPathPermissionTest" runat="server" /></td>
            </tr>
            </table>
            <asp:Label ID="lblError" runat="server" ForeColor="Red" /><br />

            <h3>Fix:</h3>
            <p>To change these settings, right-click your project 
                (in "Solution Explorer" to your right) in Visual Studio.  
                <a href="Content/VStudioProperties1.png" target="_blank">Choose "Properties"</a> 
                (bottom of the list). Select the section (left)
                called "<a href="Content/VStudioProperties2.png" target="_blank">Settings</a>".  
                Set the "Values" to work with your machine and your database.  
                When you deploy, you can just change the values in 
                your web.config file.
            </p>

        </div><br />

        <div>
        </div>
    </form>
</body>
</html>
