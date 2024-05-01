using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DeliveryInkPayroll
{

    public class MasterReport
    {
        public string EmployeeID { get; set; }
        public string Name { get; set; }
        public string Routes { get; set; }
        public Routelist[] RouteList { get; set; }
        public float EmployeeRouteTotal { get; set; }
        public OtherPayments[] OtherPayments { get; set; }
        public float TotalOtherPay { get; set; }
        public float FinalPay { get; set; }


    }

    public class Routelist
    {
        public string Route { get; set; }
        public Product1[] Products { get; set; }
        public RouteDrawAmount[] RouteDrawAmounts { get; set; }
        public DayClassTotal[] DayClassTotal { get; set; }
        public float DrawGrandTotal { get; set; }
        public Adjustment[] Adjustments { get; set; }
        public Adjustment[] Collections { get; set; }
        public AdjustmentTypeTotal[] AdjustmentTypeTotal { get; set; }
        public float AdjustmentGrandTotal { get; set; }
        public float RouteGrandTotal { get; set; }
    }

    public class Product1
    {
        public string Product { get; set; }
        public Draw1[] Draws { get; set; }
    }

    public class Draw1
    {
        public string Date { get; set; }
        public int DayIndex { get; set; }
        public int Draw { get; set; }
    }

    public class RouteDrawAmount
    {
        public string Product { get; set; }
        public string DayClass { get; set; }
        public int TotalDraw { get; set; }
        public float Rate { get; set; }
        public float Amount { get; set; }
    }

    public class DayClassTotal
    {
        public string DayClass { get; set; }
        public float Amount { get; set; }
    }

    public class AdjustmentTypeTotal
    {
        public string Type { get; set; }
        public float Amount { get; set; }
    }

    public class Adjustment
    {
        public string Description { get; set; }
        public string Type { get; set; }
        public int Draw { get; set; }
        public float Rate { get; set; }
        public float Amount { get; set; }
    }

    public class OtherPayments
    {
        public string Description { get; set; }
        public float Amount { get; set; }
    }


}
