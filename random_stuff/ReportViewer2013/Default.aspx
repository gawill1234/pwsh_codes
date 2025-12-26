<%@ Page Title="Home Page" Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="ReportViewer2013._Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Report Viewer Project</title>
</head>
<body>
    <form id="frmDefault" runat="server">
        <h1>Report Viewer for Studio 2013 (or 2012, 2015)</h1>
        <div>
            <b>Intro:</b> This project is designed to run .RDL files (SSRS reports) which were made for SSRS 2012+, without installing SSRS.  
            My previous project was designed to work with .RDL files which were made for SSRS 2008.  It would not run reports for Report Builder 3+ or SSRS 2010+.
        </div>
        <div>
            <b>Examples:</b><br />
            <ul>
                <li><a href="Diagnostics.aspx">Diagnostics</a> - use this page to troubleshoot your settings and get ideas which will help get this demo running.</li>
                <li><a href="View.aspx">Example</a> - blank report, to test basic setup and pre-requesites</li>
                <li><a href="View.aspx?Path=SQLTables">Example 2</a> - a list of tables in the "Master" database in SQL server</li>
                <li><a href="View.aspx?Path=SQLTables_w_Image">Example 3</a> - a list of tables, with an image file
                    <br />Note: the rest of these reports require that you are connected to a SSRS DB (which is a little ironic).</li>
                <li><a href="View.aspx?Path=SSRS_Users&Database=SSRS">SSRS Users</a> - Shows all SSRS users (in SSRS user table)</li>
                <li><a href="View.aspx?Path=SSRS_Users_w_Image&Database=SSRS">SSRS Users -w- Image</a></li>
                <li><a href="View.aspx?Path=SSRS_Users_w_Part&Database=SSRS">SSRS Users -w- Report Part</a></li>
            </ul>

        </div>
    </form>
</body>
</html>
