using System;
using System.Data;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;

public class Demo : Form 
{
    private DataTable LoadEmployeesData()
    {
        DataSet dataSet = new DataSet();
        dataSet.ReadXml("employees.xml");
        return dataSet.Tables[0];
    }

    private DataTable LoadDepartmentsData()
    {
        DataSet dataSet = new DataSet();
        dataSet.ReadXml("departments.xml");
        return dataSet.Tables[0];
    }

    void DemoDrillthroughEventHandler(object sender, DrillthroughEventArgs e)
    {
        LocalReport localReport = (LocalReport)e.Report;
        localReport.DataSources.Add(new ReportDataSource("Employees", LoadEmployeesData()));
    }

    public Demo()
    {
        this.Text = "Report Control Demo";
        this.ClientSize = new System.Drawing.Size(950, 600);

        ReportViewer reportViewer = new ReportViewer();

        // Set Processing Mode.

        reportViewer.ProcessingMode = ProcessingMode.Local;

        // Set RDL file.

        reportViewer.LocalReport.ReportPath = "Departments.rdlc";

        // Supply a DataTable corresponding to each report data source.

        reportViewer.LocalReport.DataSources.Add(
            new ReportDataSource("Departments", LoadDepartmentsData()));

        // Add a handler for drillthrough.

        reportViewer.Drillthrough += new DrillthroughEventHandler(DemoDrillthroughEventHandler);

        // Add the reportviewer to the form.

        reportViewer.Dock = DockStyle.Fill;
        this.Controls.Add(reportViewer);

        // Process and render the report.

        reportViewer.RefreshReport();
    }

    [STAThread]
    public static int Main(string[] args) 
    {
        Application.Run(new Demo());
        return 0;
    }
}

