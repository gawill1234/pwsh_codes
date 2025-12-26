using System;
using System.IO;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Collections;
using Microsoft.VisualBasic.FileIO;
using Microsoft.Reporting.WinForms;

namespace DemoApp
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
            SetColors();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // Load customer list from data file.
            string dataFileName = "customers.csv";
            IEnumerable<Customer> customerList = LoadCustomerList(dataFileName);

            // Get list of all cities in the data file and set it to city dropdown.
            string[] cityList = GetAllCities(customerList);
            cityDropDown.Items.AddRange(cityList);
            cityDropDown.SelectedIndex = 0;

            // Set report data and parameters and display report.
            CustomerBindingSource.DataSource = customerList;
            SetReportParameters();
            reportViewer1.RefreshReport();
        }

        private IEnumerable<Customer> LoadCustomerList(string fileName)
        {
            List<Customer> customerList = new List<Customer>();

            using (TextFieldParser parser = new TextFieldParser(fileName))
            {
                parser.Delimiters = new string[] { "," };
                parser.HasFieldsEnclosedInQuotes = true;

                string[] fields;
                while ((fields = parser.ReadFields()) != null)
                {
                    Customer customer = new Customer();
                    customer.CustomerID = int.Parse(fields[0]);
                    customer.FirstName = fields[1];
                    customer.LastName = fields[2];
                    customer.EmailAddress = fields[3];
                    customer.Phone = fields[4];
                    customer.City = fields[5];
                    customer.StateProvince = fields[6];
                    customer.PostalCode = fields[7];
                    customer.NumOrders = int.Parse(fields[8]);

                    customerList.Add(customer);
                }
            }

            return customerList;
        }

        private string[] GetAllCities(IEnumerable<Customer> customerList)
        {
            Dictionary<string, string> cityDict = new Dictionary<string, string>();
            foreach (Customer customer in customerList)
                cityDict[customer.City] = string.Empty;

            ArrayList cityList = new ArrayList();
            foreach (string city in cityDict.Keys)
                cityList.Add(city);

            return (string[])cityList.ToArray(typeof(string));
        }

        private void cityDropDown_SelectedIndexChanged(object sender, EventArgs e)
        {
            SetReportParameters();
            reportViewer1.RefreshReport();
        }

        private void SetReportParameters()
        {
            ReportParameter[] parameters = new ReportParameter[1];
            parameters[0] = new ReportParameter("City", cityDropDown.Text);
            this.reportViewer1.LocalReport.SetParameters(parameters);
        }

        private void SetColors()
        {
            this.parameterPanel.BackColor = ProfessionalColors.ToolStripGradientMiddle;
        }

        private void Form1_SystemColorsChanged(object sender, EventArgs e)
        {
            SetColors();
        }
    }
}
