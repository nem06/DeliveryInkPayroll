using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DeliveryInkPayroll
{
    internal class Tip
    {
        public string Product {  get; set; }
        public DateTime BiWeekEnd { get; set; }
        public DateTime TipDate { get; set;}
        public string Route {  get; set; }
        public string Address { get; set; }
        public double Amount { get; set; }
    }
}
