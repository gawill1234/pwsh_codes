using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Collections.Generic;
using Microsoft.Reporting.WebForms;

public partial class _Default : System.Web.UI.Page 
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Supply report data.

            IEnumerable<Customer> customerList = Utils.LoadCustomerList();
            this.ReportViewer1.LocalReport.DataSources.Add(new ReportDataSource("Customer", customerList));

            // Populate parameter control.

            DropDownList1.Items.Add(new ListItem("<Choose City>", ""));
            IEnumerable<string> cities = GetAllCities(customerList);
            foreach (string city in cities)
                DropDownList1.Items.Add(city);

            // Hide report body until user selects a parameter.

            this.ReportViewer1.ShowReportBody = false;
        }
    }

    protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (DropDownList1.SelectedValue == "")
        {
            // User didn't select a valid parameter value.
            this.ReportViewer1.ShowReportBody = false;
        }
        else
        {
            this.ReportViewer1.ShowReportBody = true;
            SetReportParameters();
        }
    }

    private void SetReportParameters()
    {
        ReportParameter cityParameter = new ReportParameter("City", DropDownList1.SelectedValue);
        this.ReportViewer1.LocalReport.SetParameters(new ReportParameter[] { cityParameter });
    }

    /// <summary>
    /// Utility function to return a sorted list of unique city names.
    /// </summary>
    public IEnumerable<string> GetAllCities(IEnumerable<Customer> customerList)
    {
        Dictionary<string, string> cityDict = new Dictionary<string, string>();
        foreach (Customer customer in customerList)
            cityDict[customer.City] = string.Empty;

        List<string> cityList = new List<string>();
        foreach (string city in cityDict.Keys)
            cityList.Add(city);

        cityList.Sort();

        return cityList;
    }
}
