using System;
using System.Data;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;

public class Demo : Form 
{
    private DataTable LoadSalesData()
    {
        // Load data from XML file
        DataSet dataSet = new DataSet();
        dataSet.ReadXml("data.xml");
        return dataSet.Tables[0];
    }

    void DemoSubreportProcessingEventHandler(object sender, SubreportProcessingEventArgs e)
    {
        e.DataSources.Add(new ReportDataSource("Sales", LoadSalesData()));
    }

    void DemoDrillthroughEventHandler(object sender, DrillthroughEventArgs e)
    {
        LocalReport report = (LocalReport)e.Report;

        report.SubreportProcessing += 
                    new SubreportProcessingEventHandler(DemoSubreportProcessingEventHandler);
    }

    public Demo()
    {
        this.Text = "Report Control Demo";
        this.ClientSize = new System.Drawing.Size(950, 600);

        ReportViewer reportViewer = new ReportViewer();

        // Set Processing Mode

        reportViewer.ProcessingMode = ProcessingMode.Local;

        // Set RDL file

        reportViewer.LocalReport.ReportPath = "test.rdlc";

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

