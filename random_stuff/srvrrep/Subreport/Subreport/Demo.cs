using System;
using System.Data;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;

public class Demo : Form 
{
    private DataTable orderDetailsData = null;

    private DataTable LoadOrdersData()
    {
        // Load data from XML file
        DataSet dataSet = new DataSet();
        dataSet.ReadXml("OrderData.xml");
        return dataSet.Tables[0];
    }

    private DataTable LoadOrderDetailsData()
    {
        // Load data from XML file
        DataSet dataSet = new DataSet();
        dataSet.ReadXml("OrderDetailData.xml");
        return dataSet.Tables[0];
    }

    void DemoSubreportProcessingEventHandler(object sender, SubreportProcessingEventArgs e)
    {
        if (orderDetailsData == null)
            orderDetailsData = LoadOrderDetailsData();
        e.DataSources.Add(new ReportDataSource("DataSet1_OrderDetails", orderDetailsData));
    }

    public Demo()
    {
        this.Text = "Report Control Demo";
        this.ClientSize = new System.Drawing.Size(700, 600);

        ReportViewer reportViewer = new ReportViewer();

        // Set Processing Mode

        reportViewer.ProcessingMode = ProcessingMode.Local;

        // Set RDL file

        reportViewer.LocalReport.ReportPath = "Orders.rdlc";

        // Add a handler for SubreportProcessing

        reportViewer.LocalReport.SubreportProcessing += 
                    new SubreportProcessingEventHandler(DemoSubreportProcessingEventHandler);

        // Supply a DataTable corresponding to each report dataset

        reportViewer.LocalReport.DataSources.Add(
            new ReportDataSource("DataSet1_Orders", LoadOrdersData()));

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

