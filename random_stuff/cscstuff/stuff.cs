//View.aspx.cs
protected void ShowReport()
{
  System.IO.FileInfo reportFullPath = this.ReportFile;
  //check to make sure the file ACTUALLY exists, before we start working on it
  if (reportFullPath != null)
  {
     //map the reporting engine to the .rdl/.rdlc file
     rvReportViewer.LocalReport.ReportPath = reportFullPath.FullName;  

     // 1. Clear Report Data
     rvReportViewer.LocalReport.DataSources.Clear();

     // 2. Get the data for the report
     // Look-up the DB query in the "DataSets" 
     // element of the report file (.rdl/.rdlc which contains XML)
     RDL.ReportreportDef = RDL.Report.GetReportFromFile(reportFullPath.FullName);

     // Run each query (usually, there is only one) and attach it to the report
     foreach (RDL.DataSet ds in reportDef.DataSets)
     {
        //copy the parameters from the QueryString into the ReportParameters definitions (objects)
        ds.AssignParameters(this.ReportParameters);

        //run the query to get real data for the report
        System.Data.DataTable tbl = ds.GetDataTable(this.DBConnectionString);

        //attach the data/table to the Report's dataset(s), by name
        ReportDataSource rds = new ReportDataSource();
        rds.Name = ds.Name; //This refers to the dataset name in the RDLC file
        rds.Value = tbl;
        rvReportViewer.LocalReport.DataSources.Add(rds);
     }
     rvReportViewer.LocalReport.Refresh();
  }
}
