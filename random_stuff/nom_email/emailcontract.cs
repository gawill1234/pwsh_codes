using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;


namespace nominee_email {
   class SendEmail {
      
      /*
       *  Ok, I admit this one is a bit weird.  It sorts
       *  all the letters in an array by counting the each
       *  of the letters in the array.  I.e., For the word
       *  "mississippi" it would create and array that said
       *  of "i", there are 4.  m is 1, p is 2 and s is 4.
       *  then it build a new array based off of those counts.
       *  Which yields "iiiimppssss".
       *
       *  This is a variant of sortastring.c with the code
       *  added to show if two strings are anagrams of each
       *  other.
       */
      
      static void runnit() {

         Console.Write("stuff\n");
         return;
      
      }
      
      static void create_db_conn() {
      
         string connetionString;
         SqlConnection cnn;

         // connetionString = @"Data Source=WIN-50GP30FGO75;Initial Catalog=Demodb;User ID=sa;Password=demol23";

         connetionString = @"Server=VAC20VNNAES810.va.gov;Database=Cad_Alpha800;User Id=EASDevBoxUser;Password=P@55w0rds01#;MultipleActiveResultSets=True;application name=ESB;Encrypt=True;TrustServerCertificate=True";
         cnn = new SqlConnection(connetionString);
         cnn.Open();
         MessageBox.Show("Connection Open  !");
         cnn.Close();
      
         return;
      }
      
      static void Main(string[] args) {
      
         create_db_conn();
         runnit();
      }
   }
}
