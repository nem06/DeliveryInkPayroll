using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace DeliveryInkPayroll
{
    internal class DayDraw
    {
        public DateTime Date { get; set; }
        public List<RawDraw> Draws { get; set; } = [];
        public Dictionary<(string, string, string, string), (int, int)> ProductCount { get; set; } = new();
    }

    internal class RawDraw
    {
        public DateTime Date { get; set; }
        public string? Day {  get; set; }
        public string? DayClass {  get; set; }
        public DateTime WeekEnding { get; set; }
        public string? Plant {  get; set; }
        public string? Product { get; set; }
        public string? CustomerClassification { get; set; }
        public string? Route { get; set; }
        public int Draw {  get; set; }
        public int CATAddressID {  get; set; }
        public string? ZipCode { get; set; }
        public string? ZipPlus4 { get; set; }
        public int Count { get; set; }
    }
}
