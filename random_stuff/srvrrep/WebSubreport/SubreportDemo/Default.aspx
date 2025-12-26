<%@ Page Language="C#" AutoEventWireup="true"  CodeFile="Default.aspx.cs" Inherits="_Default" %>

<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=8.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <rsweb:ReportViewer ID="ReportViewer1" runat="server" Font-Names="Verdana" Font-Size="8pt"
            Height="100%" Width="100%" AsyncRendering="False" SizeToReportContent="True">
            <LocalReport ReportPath="Departments.rdlc" OnSubreportProcessing="ReportViewer1_SubreportProcessing">
            </LocalReport>
        </rsweb:ReportViewer>
        &nbsp;
    
    </div>
    </form>
</body>
</html>
