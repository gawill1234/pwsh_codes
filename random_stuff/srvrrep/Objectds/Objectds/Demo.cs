using System;
using System.Collections.Generic;
using System.Windows.Forms;
using Microsoft.Reporting.WinForms;

public class Merchant
{
    private List<Product> m_products;

    public Merchant()
    {
        m_products = new List<Product>();
        m_products.Add(new Product("Pen", 25));
        m_products.Add(new Product("Pencil", 30));
        m_products.Add(new Product("Notebook", 15));
    }

    public List<Product> GetProducts()
    {
        return m_products;
    }
}

public class Product
{
    private string m_name;
    private int m_price;

    public Product(string name, int price)
    {
        m_name = name;
        m_price = price;
    }

    public string Name
    {
        get
        {
            return m_name;
        }
    }

    public int Price
    {
        get
        {
            return m_price;
        }
    }
}

public class Demo : Form
{
    public Demo()
    {
        Merchant merchant = new Merchant();

        this.Text = "Report Control Demo";
        this.ClientSize = new System.Drawing.Size(950, 600);

        ReportViewer reportViewer = new ReportViewer();

        // Set Processing Mode

        reportViewer.ProcessingMode = ProcessingMode.Local;

        // Set RDL file

        reportViewer.LocalReport.ReportPath = "Report1.rdlc";

        // Supply data corresponding to each report data source.

        reportViewer.LocalReport.DataSources.Add(
            new ReportDataSource("Product", merchant.GetProducts()));

        // Add the reportviewer to the form

        reportViewer.Dock = DockStyle.Fill;
        this.Controls.Add(reportViewer);

        // Process and render the report

        reportViewer.RefreshReport();
    }

    [STAThread]
    public static int Main(string[] args)
    {
        Application.Run(new Demo());
        return 0;
    }
}
