using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DeliveryInkPayroll
{
    internal class Employee
    {
        public string EmployeeId { get; set; }
        public List<string> Routes { get; set; }
        public string Old_Id { get; set; }
        public string Name { get; set; }
        public string PayeeName { get; set; }

    }
}
