using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using Microsoft.Reporting.WebForms;

public partial class CS : System.Web.UI.Page
{
protected void Page_Load(object sender, EventArgs e)
{
    if (!IsPostBack)
    {
        ReportViewer1.ProcessingMode = ProcessingMode.Local;
        ReportViewer1.LocalReport.ReportPath = Server.MapPath("~/Report.rdlc");
        Customers dsCustomers = GetData("select top 20 * from customers");
        ReportDataSource datasource = new ReportDataSource("Customers", dsCustomers.Tables[0]);
        ReportViewer1.LocalReport.DataSources.Clear();
        ReportViewer1.LocalReport.DataSources.Add(datasource);
    }
}

private Customers GetData(string query)
{
    string conString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;
    SqlCommand cmd = new SqlCommand(query);
    using (SqlConnection con = new SqlConnection(conString))
    {
        using (SqlDataAdapter sda = new SqlDataAdapter())
        {
            cmd.Connection = con;

            sda.SelectCommand = cmd;
            using (Customers dsCustomers = new Customers())
            {
                sda.Fill(dsCustomers, "DataTable1");
                return dsCustomers;
            }
        }
    }
}
}