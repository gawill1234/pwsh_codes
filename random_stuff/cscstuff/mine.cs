using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Data.SqlClient;
using System.Xml;
using System.Xml.Serialization;
using System.Data.OleDb;
using System.IO;
using Microsoft.Reporting.Common;
using Microsoft.Reporting.WinForms;
using Microsoft.Reporting.WebForms;

namespace TestHarness
{
    public partial class Form1 : Form
    {
        // Module scope dataset variable
        DataSet dsMyDataSet = new DataSet();
        public Form1()
        {
            InitializeComponent();
        }
        private void Form1_Load(object sender, EventArgs e)
        {
            this.cmbReport.Items.Add("TESTREPORT");
            this.SetupDataSet();
            this.reportViewer1.RefreshReport();
        }
        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }
        private void btnViewreport_Click(object sender, EventArgs e)
        {
            // Reset the report viewer
            this.reportViewer1.Reset();

            // Set processing to local mode
            this.reportViewer1.ProcessingMode = Microsoft.Reporting.WinForms.ProcessingMode.Local;

            // Check which report to test
            if (this.cmbReport.Text.Trim() == "TESTREPORT")
            {
                // Load .rdlc file and add a datasource
                this.reportViewer1.LocalReport.ReportPath = @"\Reports\MyTestReport.rdlc";
                // Loop through each table in our dataset
                for (int i = 0; i < this.dsMyDataSet.Tables.Count; i++)
                {
                    this.reportViewer1.LocalReport.DataSources.Add(this.GetMyDataTable(i));
                }
            }
            // Refresh viewer with above settings
            this.reportViewer1.RefreshReport();
        }

        private Microsoft.Reporting.WinForms.ReportDataSource GetMyDataTable(int i)
        {
            // Form the datasource name - you need a naming convention for this to work
            string sDataSourceName = "Reportdata_Table" + i.ToString().Trim();
            // The line above will generate datasource names of "Reportdata_Table0" and
            // "Reportdata_Table1" for our 2 tabled dataset - we just need to ensure our .rdlc
            // report has been designed to receive 2 datasources with these same names and that
            // the columns match up precisely one-to-one for each table.
            // Return the relevant dataset table
            return new Microsoft.Reporting.WinForms.ReportDataSource(sDataSourceName, this.dsMyDataSet.Tables[i]);
        }

        private void SetupDataSet()
        {
            // Create 1st DataTable to hold some report data
            System.Data.DataTable myTable0 = new DataTable("myTable0");
            System.Data.DataColumn column;
            System.Data.DataRow row;
            // Create 3 columns
            column = new DataColumn();
            column.DataType = System.Type.GetType("System.String");
            column.ColumnName = "ID";
            column.ReadOnly = true;
            column.Unique = true;
            // Add the Column to the DataColumnCollection.
            myTable0.Columns.Add(column);
            column = new DataColumn();
            column.DataType = System.Type.GetType("System.String");
            column.ColumnName = "DESCRIPTION";
            column.ReadOnly = true;
            column.Unique = true;
            // Add the Column to the DataColumnCollection.
            myTable0.Columns.Add(column);
            column = new DataColumn();
            column.DataType = System.Type.GetType("System.String");
            column.ColumnName = "QUANTITY";
            column.ReadOnly = true;
            column.Unique = true;
            // Add the Column to the DataColumnCollection.
            myTable0.Columns.Add(column);
            // Add a row of data
            row = myTable0.NewRow();
            row["ID"] = "1234567890";
            row["DESCRIPTION"] = "Rickenbacker Electric Guitar";
            row["QUANTITY"] = "5";
            // Add the row of data to the table
            myTable0.Rows.Add(row);
            // And a second row
            row = myTable0.NewRow();
            row["ID"] = "777745632";
            row["DESCRIPTION"] = "Gibson Electric Guitar";
            row["QUANTITY"] = "7";
            // Add the row of data to the table
            myTable0.Rows.Add(row);
            // Add myTable0 to global dataset
            this.dsMyDataSet.Tables.Add(myTable0); // dsMyDataSet.Tables[0] object;
            // Create 2nd DataTable to hold some report data
            System.Data.DataTable myTable1 = new DataTable("myTable1");
            // Create 4 columns
            column = new DataColumn();
            column.DataType = System.Type.GetType("System.String");
            column.ColumnName = "CUSTOMER_ID";
            column.ReadOnly = true;
            column.Unique = true;
            // Add the Column to the DataColumnCollection.
            myTable1.Columns.Add(column);
            column = new DataColumn();
            column.DataType = System.Type.GetType("System.String");
            column.ColumnName = "NAME";
            column.ReadOnly = true;
            column.Unique = true;
            // Add the Column to the DataColumnCollection.
            myTable1.Columns.Add(column);
            column = new DataColumn();
            column.DataType = System.Type.GetType("System.String");
            column.ColumnName = "ADDRESS";
            column.ReadOnly = true;
            column.Unique = true;
            // Add the Column to the DataColumnCollection.
            myTable1.Columns.Add(column);
            column = new DataColumn();
            column.DataType = System.Type.GetType("System.String");
            column.ColumnName = "POSTAL_CODE";
            column.ReadOnly = true;
            column.Unique = true;
            // Add the Column to the DataColumnCollection.
            myTable1.Columns.Add(column);
            // Add a row of data
            row = myTable1.NewRow();
            row["CUSTOMER_ID"] = "56790";
            row["NAME"] = "John Lennon";
            row["ADDRESS"] = "Strawberry Fields , Liverpool , England";
            row["POSTAL_CODE"] = "NWE232";
            // Add the row of data to the table
            myTable1.Rows.Add(row);
            // Add a row of data
            row = myTable1.NewRow();
            row["CUSTOMER_ID"] = "44982";
            row["NAME"] = "George Harrison";
            row["ADDRESS"] = "22 Penny Lane , Liverpool , England";
            row["POSTAL_CODE"] = "NWE231";
            // Add the row of data to the table
            myTable1.Rows.Add(row);
            // Add myTable1 to global dataset
            this.dsMyDataSet.Tables.Add(myTable1); // dsMyDataSet.Tables[1] object;
        }
    }
}
