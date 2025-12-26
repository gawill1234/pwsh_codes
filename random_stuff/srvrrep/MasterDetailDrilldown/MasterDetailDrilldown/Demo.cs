using System;
using System.Data;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;

public class Demo : Form 
{
    private DataTable LoadDemoData()
    {
        // Load data from XML file
        DataSet dataSet = new DataSet();
        dataSet.ReadXml("data.xml");
        return dataSet.Tables[0];
    }

    public Demo()
    {
        this.Text = "Report Control Demo";
        this.ClientSize = new System.Drawing.Size(950, 600);

        ReportViewer reportViewer = new ReportViewer();

        // Set Processing Mode

        reportViewer.ProcessingMode = ProcessingMode.Local;

        // Set RDL file

        reportViewer.LocalReport.ReportPath = "Report1.rdlc";

        // Supply a DataTable corresponding to each report dataset

        reportViewer.LocalReport.DataSources.Add(
            new ReportDataSource("DataSet1_DataTable1", LoadDemoData()));

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

