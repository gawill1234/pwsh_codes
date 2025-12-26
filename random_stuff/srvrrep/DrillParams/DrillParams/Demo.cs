using System;
using System.IO;
using System.Data;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;

public class Demo : Form 
{
    void DemoDrillthroughEventHandler(object sender, DrillthroughEventArgs e)
    {
        using (FileStream stream = new FileStream("drilldest.rdl", FileMode.Open))
        {
            e.Report.LoadReportDefinition(stream);
        }

        ReportParameterInfoCollection parameters = e.Report.GetParameters();
        ReportParameterInfo parameter = parameters[0];
        MessageBox.Show("parameter value = " + parameter.Values[0], "Debugging");
    }

    public Demo()
    {
        this.Text = "Report Control Demo";
        this.ClientSize = new System.Drawing.Size(950, 600);

        ReportViewer reportViewer = new ReportViewer();

        // Set Processing Mode

        reportViewer.ProcessingMode = ProcessingMode.Local;

        // Set RDL file

        using (FileStream stream = new FileStream("drillthru.rdl", FileMode.Open))
        {
            reportViewer.LocalReport.LoadReportDefinition(stream);
        }

        // Add a handler for drillthrough

        reportViewer.Drillthrough += new DrillthroughEventHandler(DemoDrillthroughEventHandler);

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

