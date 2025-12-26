using System;
using System.Data;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;

public class Demo : Form 
{
    public Demo()
    {
        this.Text = "Report Control Demo";
        this.ClientSize = new System.Drawing.Size(950, 600);

        ReportViewer reportViewer = new ReportViewer();

        // Set Processing Mode

        reportViewer.ProcessingMode = ProcessingMode.Remote;

        // Set report server and report path

        reportViewer.ServerReport.ReportServerUrl = new Uri("http://myhost/reportserver");
        reportViewer.ServerReport.ReportPath = "/Samples/Product Catalog";

        // Add the reportviewer to the form

        reportViewer.Dock = DockStyle.Fill;
        this.Controls.Add(reportViewer);

        // Process and render the report

        reportViewer.RefreshReport();
    }

    [STAThread]
    public static int Main(string[] args) 
    {
        Application.Run(new Demo());
        return 0;
    }
}

