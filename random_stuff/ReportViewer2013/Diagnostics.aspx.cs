using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ReportViewer2013
{
    public partial class Diagnostics : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                //first: DB connection test
                try
                {
                    System.Data.OleDb.OleDbConnection con = new System.Data.OleDb.OleDbConnection(ReportViewer2013.Properties.Settings.Default.DsnReport);
                    con.Open();
                    con.Close();
                    con.Dispose();
                    lblConnectionTest.Text = "Success (OLEDB)";
                    lblConnectionTest.ForeColor = System.Drawing.Color.DarkGreen;
                }
                catch //(Exception conex)
                {
                    try
                    {
                        System.Data.SqlClient.SqlConnection con = new System.Data.SqlClient.SqlConnection(ReportViewer2013.Properties.Settings.Default.DsnReport);
                        con.Open();
                        con.Close();
                        con.Dispose();
                        lblConnectionTest.Text = "Success (SqlClient)";
                        lblConnectionTest.ForeColor = System.Drawing.Color.DarkGreen;
                    }
                    catch (Exception conex)
                    {
                        lblConnectionTest.Text = "Fail: " + conex.Message;
                        lblConnectionTest.ForeColor = System.Drawing.Color.DarkRed;
                    }
                
                }

                //file path test
                try
                {
                    string path = Server.MapPath(ReportViewer2013.Properties.Settings.Default.ReportPath);
                    lblReportPath.Text = path;
                    if (System.IO.Directory.Exists(path))
                    {
                        System.IO.DirectoryInfo d = new System.IO.DirectoryInfo(path);
                        var files = d.GetFiles();
                        if (files.Length > 0 && !files[0].GetAccessControl().AreAccessRulesProtected)
                        {
                            lblPathPermissionTest.Text = "Success (read, path)";
                            lblPathPermissionTest.ForeColor = System.Drawing.Color.DarkGreen;
                        }
                        else
                        {
                            lblPathPermissionTest.Text = "Fail: access denied";
                            lblPathPermissionTest.ForeColor = System.Drawing.Color.DarkRed;
                        }
                    }
                    else
                    {
                        lblPathPermissionTest.Text = "Fail: path does not exist";
                        lblPathPermissionTest.ForeColor = System.Drawing.Color.DarkRed;
                    }
                }
                catch (Exception pathex)
                {
                    lblPathPermissionTest.Text = "Fail: " + pathex.Message;
                    lblPathPermissionTest.ForeColor = System.Drawing.Color.DarkRed;
                }
                lblError.Text = "";
            }
            catch (Exception ex)
            {
                lblError.Text = ex.Message;
                lblError.ForeColor = System.Drawing.Color.DarkRed;
            }
        }
    }
}