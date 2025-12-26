Imports System
Imports System.Data
Imports System.Windows.Forms
Imports Microsoft.Reporting.WinForms

Public Class Demo 
    Inherits Form

    Public Sub New
        me.Text = "Report Control Demo"
        me.ClientSize = new System.Drawing.Size(700, 500)

        Dim reportViewer as ReportViewer = new ReportViewer()
        reportViewer.ShowToolBar = False
        reportViewer.ShowProgress = False

        ' Set Processing Mode

        reportViewer.ProcessingMode = ProcessingMode.Local

        ' Set RDL file

        reportViewer.LocalReport.ReportPath = "Report1.rdlc"

        ' Supply data corresponding to each report data source.

        reportViewer.LocalReport.DataSources.Add( _
            new ReportDataSource("WebLogParser_WebAccess", LogParser.ParseLogFile("access.log")))

        ' Add the reportviewer to the form

        reportViewer.Dock = DockStyle.Fill
        me.Controls.Add(reportViewer)

        ' Process and render the report

        reportViewer.RefreshReport()
    End Sub

    Public Shared Sub Main(args as string()) 
        Application.Run(new Demo())
    End Sub
End Class