using System;
using System.Data;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;
using System.Data.SqlClient;


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

        // return "Data Source=MSSQL1;Initial Catalog=AdventureWorks;"
        // + "Integrated Security=true;";
        // Server=myServerAddress<,portifneeded>;Database=myDataBase;User Id=myUsername;Password=myPassword;
        // Data Source=myServer;Initial Catalog=myDB;Integrated Security=true;Column Encryption Setting=enabled;
        // Server=VAC20VNNAES810.va.gov;Database=Cad_Alpha;integrated security=True;MultipleActiveResultSets=True;application name=ESB;Encrypt=True;TrustServerCertificate=True;MultiSubnetFailover=True

        SqlConnection conn = new SqlConnection();
        conn.ConnectionString =
          "Server=vac20vnnaes810.va.gov;" +
          "Database=Cad_Alpha800;" +
          "User id=EASDevBoxUser;" +
          "Password=P@55w0rds01#;";

        conn.Open();
        SqlDataAdapter da = new SqlDataAdapter();
        da.SelectCommand = new SqlCommand(@"SELECT * FROM Core.Users", conn);
        DataSet dataSet = new DataSet();
        DataTable dataTable = new DataTable();

        da.Fill(dataSet, "Core.Users");
        dataTable = dataSet.Tables["Core.Users"];

        return dataTable;
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
        reportViewer.LocalReport.ReportPath = "Appointment_Memorandum.rdl";
        // reportViewer.LocalReport.ReportPath = "stoopid.rdlc";
        // reportViewer.LocalReport.ReportEmbeddedResource = "Report1.rdlc";

        // Supply a DataTable corresponding to each report data source

        DataTable dt = LoadSalesData();
        PrintValues(dt);
    }

    [STAThread]
    static int Main(string[] args) 
    {
        Application.Run(new Demo());
        return 0;
    }
}

