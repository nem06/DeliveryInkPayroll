using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.FileSystemGlobbing.Internal;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace DeliveryInkPayroll
{
    internal class ReportHelper
    {
        private readonly IConfiguration _configuration;
        private string templateDirectoryPath {  get; set; }
        private string headerTemplate {  get; set; }
        private string reportTemplate {  get; set; }
        private string employeeTemplate { get; set; }
        private string routeTableTemplate { get; set; }
        private string routeTableProductHeader { get; set; }
        private string routeTableProductTotal { get; set; }
        private string routeTableProductRowTemplate { get; set; }
        private string routeTableProductTotalTemplate { get; set; }
        private string routeTableAdjustmentTemplate { get; set; }
        private string routeTableAdjustmentRowTemplate { get; set; }
        private string routeTableCollectionTemplate { get; set; }
        private string otherWorkRowTemplate { get; set; }

        public ReportHelper(IConfiguration configuration) 
        {
            _configuration = configuration;
            templateDirectoryPath = _configuration["TemplatePath"];
            headerTemplate = File.ReadAllText(Path.Combine("Templates", "header-template.html"));
            reportTemplate = File.ReadAllText(Path.Combine("Templates", "report-template.html"));
            employeeTemplate = File.ReadAllText(Path.Combine("Templates", "employee-template.html"));
            routeTableTemplate = File.ReadAllText(Path.Combine("Templates", "route-table-template.html"));
            routeTableProductHeader = File.ReadAllText(Path.Combine("Templates", "route-table-product-header.html"));
            routeTableProductTotal = File.ReadAllText(Path.Combine("Templates", "route-table-product-total.html"));
            routeTableProductRowTemplate = File.ReadAllText(Path.Combine("Templates", "route-table-product-row-template.html"));
            routeTableProductTotalTemplate = File.ReadAllText(Path.Combine("Templates", "route-table-product-total-template.html"));
            routeTableAdjustmentTemplate = File.ReadAllText(Path.Combine("Templates", "route-table-adjustment-template.html"));
            routeTableCollectionTemplate = File.ReadAllText(Path.Combine("Templates", "route-table-collection-template.html"));
            routeTableAdjustmentRowTemplate = File.ReadAllText(Path.Combine("Templates", "route-table-adjustment-row-template.html"));
            otherWorkRowTemplate = File.ReadAllText(Path.Combine("Templates", "otherwork-row-template.html"));
        }

        public void GenerateReportFile(List<MasterReport> masterReport, string weekEnding)
        {
            string masterReportString = "";
            foreach (MasterReport report in masterReport) 
            {
                string employeeReport = employeeTemplate;
                employeeReport = employeeReport.Replace("[[NAME]]", report.Name)
                                    .Replace("[[ROUTES]]", report.Routes);

                string routeTablesString = "";
                if (report.RouteList != null)
                    foreach(Routelist route in report.RouteList)
                    {
                        string routeData = routeTableTemplate;
                        routeData = routeTableTemplate.Replace("[[ROUTE]]", route.Route);
                        string productRows = "";
                        if(route.Products != null)
                        {
                            routeData = routeData.Replace("[[THEAD-PRODUCT]]", routeTableProductHeader);
                            routeData = routeData.Replace("[[TBODY-PRODUCT-TOTAL]]", routeTableProductTotal);

                            foreach (Product1 product in route.Products)
                            {
                                string productRow = routeTableProductRowTemplate;

                                productRow =productRow.Replace("[[PRODUCT]]", product.Product);
                                foreach(Draw1 draw in product.Draws)
                                    productRow = productRow.Replace("[["+ draw.DayIndex.ToString() +"]]", draw.Draw.ToString());

                                foreach(RouteDrawAmount routeDrawAmount in route.RouteDrawAmounts)
                                    if(routeDrawAmount.Product == product.Product)
                                        if (routeDrawAmount.DayClass == "MF")
                                            productRow = productRow.Replace("[[M-F_TOTAL]]", routeDrawAmount.TotalDraw.ToString())
                                                .Replace("[[M-F_RATE]]", routeDrawAmount.Rate.ToString("F2"))
                                                .Replace("[[M-F_AMOUNT]]", routeDrawAmount.Amount.ToString("F2"));
                                        else if (routeDrawAmount.DayClass == "SAT")
                                            productRow = productRow.Replace("[[SAT_TOTAL]]", routeDrawAmount.TotalDraw.ToString())
                                                .Replace("[[SAT_RATE]]", routeDrawAmount.Rate.ToString("F2"))
                                                .Replace("[[SAT_AMOUNT]]", routeDrawAmount.Amount.ToString("F2"));
                                        else if (routeDrawAmount.DayClass == "SUN")
                                            productRow = productRow.Replace("[[SUN_TOTAL]]", routeDrawAmount.TotalDraw.ToString())
                                                .Replace("[[SUN_RATE]]", routeDrawAmount.Rate.ToString("F2"))
                                                .Replace("[[SUN_AMOUNT]]", routeDrawAmount.Amount.ToString("F2"));


                                productRows += productRow;
                            }
                            routeData = routeData.Replace("[[TBODY-PRODUCT]]", productRows);

                            string dayClassTotalString = routeTableProductTotalTemplate;
                            foreach (DayClassTotal dayClassTotal in route.DayClassTotal)
                                if (dayClassTotal.DayClass == "MF")
                                    dayClassTotalString = dayClassTotalString.Replace("[[M-F]]", dayClassTotal.Amount.ToString("F2"));
                                else if (dayClassTotal.DayClass == "SAT")
                                    dayClassTotalString = dayClassTotalString.Replace("[[SAT]]", dayClassTotal.Amount.ToString("F2"));
                                else if (dayClassTotal.DayClass == "SUN")
                                    dayClassTotalString = dayClassTotalString.Replace("[[SUN]]", dayClassTotal.Amount.ToString("F2"));

                            routeData = routeData.Replace("[[TBODY-PRODUCT-TOTALS]]", dayClassTotalString);
                        }

                        if(route.Adjustments != null)
                        {
                            string adjustments = routeTableAdjustmentTemplate;
                            string adjustmentRows = "";

                            string drawDiscription = "";
                            string insDiscription = "";
                            string rtAdjDiscription = "";
                            string tipsDiscription = "";


                            foreach (Adjustment adjustment in route.Adjustments)
                            {
                                if (adjustment.Type.Contains("DRAW"))
                                    drawDiscription += drawDiscription != "" ? ",&emsp;" + adjustment.Description : adjustment.Description;
                                if (adjustment.Type.Contains("INS"))
                                    insDiscription += insDiscription != "" ? ",&emsp;" + adjustment.Description : adjustment.Description;
                                if (adjustment.Type.Contains("RTADJ"))
                                    rtAdjDiscription += rtAdjDiscription != "" ? ",&emsp;" + adjustment.Description : adjustment.Description;
                                if (adjustment.Type.Contains("TIPS"))
                                    tipsDiscription += tipsDiscription != "" ? ",&emsp;" + adjustment.Description : adjustment.Description;
                            }

                            if(drawDiscription != "")
                            {
                                string adjustmentRow = routeTableAdjustmentRowTemplate;
                                adjustmentRow = adjustmentRow.Replace("[[ADJ-DESC]]", drawDiscription);
                                foreach(AdjustmentTypeTotal adjustmentTypeTotal in route.AdjustmentTypeTotal)
                                    if(adjustmentTypeTotal.Type == "DRAW")
                                    {
                                        adjustmentRow = adjustmentRow.Replace("[[ADJ-AMOUNT]]", adjustmentTypeTotal.Amount.ToString("F2"));
                                        break;
                                    }
                                adjustmentRows += adjustmentRow;
                            }

                            if (insDiscription != "")
                            {
                                string adjustmentRow = routeTableAdjustmentRowTemplate;
                                adjustmentRow = adjustmentRow.Replace("[[ADJ-DESC]]", insDiscription);
                                foreach (AdjustmentTypeTotal adjustmentTypeTotal in route.AdjustmentTypeTotal)
                                    if (adjustmentTypeTotal.Type == "INS")
                                    {
                                        adjustmentRow = adjustmentRow.Replace("[[ADJ-AMOUNT]]", adjustmentTypeTotal.Amount.ToString("F2"));
                                        break;
                                    }
                                adjustmentRows += adjustmentRow;
                            }

                            if (rtAdjDiscription != "")
                            {
                                string adjustmentRow = routeTableAdjustmentRowTemplate;
                                adjustmentRow = adjustmentRow.Replace("[[ADJ-DESC]]", rtAdjDiscription);
                                foreach (AdjustmentTypeTotal adjustmentTypeTotal in route.AdjustmentTypeTotal)
                                    if (adjustmentTypeTotal.Type == "RTADJ")
                                    {
                                        adjustmentRow = adjustmentRow.Replace("[[ADJ-AMOUNT]]", adjustmentTypeTotal.Amount.ToString("F2"));
                                        break;
                                    }
                                adjustmentRows += adjustmentRow;
                            }

                            if (tipsDiscription != "")
                            {
                                string adjustmentRow = routeTableAdjustmentRowTemplate;
                                adjustmentRow = adjustmentRow.Replace("[[ADJ-DESC]]", tipsDiscription);
                                foreach (AdjustmentTypeTotal adjustmentTypeTotal in route.AdjustmentTypeTotal)
                                    if (adjustmentTypeTotal.Type == "TIPS")
                                    {
                                        adjustmentRow = adjustmentRow.Replace("[[ADJ-AMOUNT]]", adjustmentTypeTotal.Amount.ToString("F2"));
                                        break;
                                    }
                                adjustmentRows += adjustmentRow;
                            }

                            adjustments = adjustments.Replace("[[ADJUSTMENT-ROWS]]", adjustmentRows);

                            routeData = routeData.Replace("[[ADJUSTMENTS]]", adjustments);
                        }

                        routeData = routeData.Replace("[[TOTAL-DRAW]]", route.DrawGrandTotal.ToString("F2"))
                            .Replace("[[TOTAL-ADJUSTMENT]]",route.AdjustmentGrandTotal.ToString("F2"))
                            .Replace("[[TOTAL-ROUTE]]", route.RouteGrandTotal.ToString("F2"));

                        if (route.Collections != null)
                        {
                            string collections = routeTableCollectionTemplate;
                            string collectionRows = "";

                            foreach (var collection in route.Collections)
                            {
                                string collectionRow = routeTableAdjustmentRowTemplate;
                                collectionRow = collectionRow.Replace("[[ADJ-DESC]]", collection.Description);
                                collectionRow = collectionRow.Replace("[[ADJ-AMOUNT]]", collection.Amount.ToString("F2"));
                                collectionRows += collectionRow;
                            }
                            collections = collections.Replace("[[COLLECTION-ROWS]]", collectionRows);
                            routeData = routeData.Replace("[[COLLECTIONS]]", collections);
                        }

                        routeTablesString += routeData;
                    }


                MatchCollection matches = new Regex(@"\[\[(.*?)\]\]").Matches(routeTablesString);
                foreach (Match match in matches)
                    routeTablesString = routeTablesString.Replace(match.Value, "");

                employeeReport = employeeReport.Replace("[[ROUTE-TABLES]]", routeTablesString);
                employeeReport = employeeReport.Replace("[[ROUTES-TOTAL]]", report.EmployeeRouteTotal.ToString("F2"))
                                    .Replace("[[FINAL-PAY]]", report.FinalPay.ToString("F2"));

                string otherPaymentRows = "";
                if (report.OtherPayments != null)
                    foreach(OtherPayments otherPayment in report.OtherPayments)
                    {
                        string otherPaymentRow = otherWorkRowTemplate;
                        otherPaymentRow = otherPaymentRow.Replace("[[DESCRIPTION]]", otherPayment.Description)
                                            .Replace("[[AMOUNT]]", otherPayment.Amount > 0 ? ('$' + otherPayment.Amount.ToString("F2")) : ("-$" + (otherPayment.Amount - (otherPayment.Amount*2)).ToString("F2")));
                        otherPaymentRows += otherPaymentRow;
                    }

                employeeReport = employeeReport.Replace("[[EXTRAWORK-ROWS]]", otherPaymentRows);

                masterReportString += employeeReport;
            }

            reportTemplate = reportTemplate.Replace("[[CONTENT]]", masterReportString);

            File.WriteAllText(Path.Combine("Templates", "report-body-" + weekEnding + ".html"),reportTemplate);

        }

        public void GenerateFinalPDF(string weekEnding, string weekEndingReportFormat)
        {

            headerTemplate = headerTemplate.Replace("[[DATE]]", weekEndingReportFormat);

            File.WriteAllText(Path.Combine("Templates", "report-header-" + weekEnding + ".html"), headerTemplate);

            Process process = new Process();

            string inputHeaderFilePath = "\"" + Path.Combine("Templates", "report-header-" + weekEnding + ".html") + "\"";
            string outputHeaderFilePath = "\"" + Path.Combine("Templates", "report-header-" + weekEnding + ".pdf") + "\"";

            process.StartInfo.FileName = Path.Combine("exes", "weasyprint.exe");
            process.StartInfo.Arguments = inputHeaderFilePath + " " + outputHeaderFilePath;

            process.Start();
            process.WaitForExit();
            process.Close();

            Console.WriteLine("Header PDF generated.");

            string inputReportBodyFilePath = "\"" + Path.Combine("Templates", "report-body-" + weekEnding + ".html") + "\"";
            string outputReportBodyFilePath = "\"" + Path.Combine("Templates", "report-body-" + weekEnding + ".pdf") + "\"";

            process.StartInfo.FileName = Path.Combine("exes","weasyprint.exe");
            process.StartInfo.Arguments = inputReportBodyFilePath + " " + outputReportBodyFilePath;

            process.Start();
            process.WaitForExit();
            process.Close();

            Console.WriteLine("Report content PDF generated.");

            string finalReportPath = "\"" + Path.Combine(templateDirectoryPath, weekEnding, "OutputFiles", "Billing Master Report " + weekEnding + ".pdf") + "\"";

            process.StartInfo.FileName = Path.Combine("exes", "mergepdf.exe");
            process.StartInfo.Arguments = outputHeaderFilePath + " " + outputReportBodyFilePath + " " + finalReportPath;

            process.Start();
            process.WaitForExit();
            process.Close();
        }
    }
}
