using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Microsoft.Reporting.WebForms;

public partial class _Default : System.Web.UI.Page 
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DataSet dataSet = new DataSet();
            dataSet.ReadXml(MapPath("Department.xml"));

            ReportDataSource dataSource = new ReportDataSource("DepartmentDataSet_Department", dataSet.Tables[0]);
            ReportViewer1.LocalReport.DataSources.Add(dataSource);
        }
    }

    protected void ReportViewer1_SubreportProcessing(object sender, SubreportProcessingEventArgs e)
    {
        DataSet dataSet = new DataSet();
        dataSet.ReadXml(MapPath("Employee.xml"));

        ReportDataSource dataSource = new ReportDataSource("EmployeeDataSet_Employee", dataSet.Tables[0]);
        e.DataSources.Add(dataSource);
    }
}
