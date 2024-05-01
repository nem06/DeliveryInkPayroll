using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DeliveryInkPayroll
{
    internal class Collection
    {
        public string SubscriptionID {  get; set; }
        public double Amount { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        //public string Phone { get; set; }
        //public DateTime CollectionDate { get; set; }
        public string Route { get; set; }
        public DateTime BiWeekEnd { get; set; }
        public string EmployeeID {  get; set; }

    }
}
