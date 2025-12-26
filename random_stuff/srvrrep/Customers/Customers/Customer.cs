using System;
using System.Collections.Generic;
using System.Text;

namespace DemoApp
{
    class Customer
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
}
