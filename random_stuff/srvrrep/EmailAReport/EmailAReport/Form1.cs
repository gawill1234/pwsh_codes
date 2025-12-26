using System;
using System.IO;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;
using Microsoft.Office.Interop.Outlook;

namespace EmailAReport
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            NewDataSet.ReadXml("SalesData.xml");
            this.reportViewer1.RefreshReport();
        }

        private string ExportReport()
        {
            Warning[] warnings;
            string[] streamids;
            string mimeType;
            string encoding;
            string filenameExtension;

            byte[] bytes = reportViewer1.LocalReport.Render(
                "PDF", null, out mimeType, out encoding, out filenameExtension, 
                 out streamids, out warnings);

            string filename = Path.Combine(Path.GetTempPath(), "report.pdf");
            using (FileStream fs = new FileStream(filename, FileMode.Create))
            {
                fs.Write(bytes, 0, bytes.Length);
            }

            return filename;
        }

        private void emailButton_Click(object sender, EventArgs e)
        {
            try
            {
                // Export the report and get the file name.
                string reportFilename = ExportReport();

                // Create an Outlook application object. 
                ApplicationClass outlookApp = new ApplicationClass();

                // Create a new MailItem.
                MailItem mailItem = (MailItem)outlookApp.CreateItem(OlItemType.olMailItem);

                // Add attachment.
                mailItem.Attachments.Add(reportFilename, (int)OlAttachmentType.olByValue,
                                         1, reportFilename);

                // Display the window.
                mailItem.Display(false);
            }
            catch (System.Exception ex)
            {
                MessageBox.Show(ex.Message, "Send email", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}
