using System;
using System.Data;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;


public class Demo : Form 
{

    private void PrintValues(DataTable table)
    {
        foreach(DataRow row in table.Rows)
        {
             foreach(DataColumn column in table.Columns)
             {
                 Console.Write(row[column] + " ");
             }
             Console.Write("\n");
        }
    }

    private DataTable LoadSalesData()
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

        // reportViewer.Reset();
        reportViewer.ProcessingMode = ProcessingMode.Local;

        // Set RDL file

        reportViewer.LocalReport.DataSources.Clear();
        reportViewer.LocalReport.ReportPath = "NomineeTransactionReview.rdl";
        // reportViewer.LocalReport.ReportEmbeddedResource = "Report1.rdlc";

        // Supply a DataTable corresponding to each report data source

        DataTable dt = LoadSalesData();
        PrintValues(dt);

        ReportDataSource rprtDTSource = new ReportDataSource();
        rprtDTSource.Name = "Sales";
        rprtDTSource.Value = dt;
        reportViewer.LocalReport.DataSources.Add(rprtDTSource);

        //reportViewer.LocalReport.DataSources.Add(
        //    new ReportDataSource("Sales", dt));

        // Add the reportviewer to the form

        reportViewer.Dock = DockStyle.Fill;
        this.Controls.Add(reportViewer);

        // Process and render the report

        try {
            reportViewer.Refresh();
            //reportViewer.EnableEventValidation = "false";
            //reportViewer.AsyncRendering = "false";
            reportViewer.RefreshReport();
        } catch (Exception e) {
            Console.Write(e);
        }
    }

    [STAThread]
    static int Main(string[] args) 
    {
        Application.Run(new Demo());
        return 0;
    }
}

