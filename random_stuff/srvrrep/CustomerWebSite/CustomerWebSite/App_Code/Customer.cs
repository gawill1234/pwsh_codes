using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using Microsoft.VisualBasic.FileIO;

public class Customer
{
    private int m_customerId;
    private string m_firstName;
    private string m_lastName;
    private string m_emailAddress;
    private string m_phone;
    private string m_city;
    private string m_stateProvince;
    private string m_postalCode;
    private int m_numOrders;

    public int CustomerID
    {
        get { return m_customerId; }
        set { m_customerId = value; }
    }

    public string FirstName
    {
        get { return m_firstName; }
        set { m_firstName = value; }
    }

    public string LastName
    {
        get { return m_lastName; }
        set { m_lastName = value; }
    }

    public string EmailAddress
    {
        get { return m_emailAddress; }
        set { m_emailAddress = value; }
    }

    public string Phone
    {
        get { return m_phone; }
        set { m_phone = value; }
    }

    public string City
    {
        get { return m_city; }
        set { m_city = value; }
    }

    public string StateProvince
    {
        get { return m_stateProvince; }
        set { m_stateProvince = value; }
    }

    public string PostalCode
    {
        get { return m_postalCode; }
        set { m_postalCode = value; }
    }

    public int NumOrders
    {
        get { return m_numOrders; }
        set { m_numOrders = value; }
    }
}

public class Utils
{
    public static IEnumerable<Customer> LoadCustomerList()
    {
        string fileName = HttpContext.Current.Request.MapPath("customers.csv");
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
}
