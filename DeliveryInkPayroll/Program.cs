using DeliveryInkPayroll;
using Microsoft.Extensions.Configuration;
using System;
using System.Diagnostics;
using System.IO;
using System.Text.Json;


IConfigurationRoot config = new ConfigurationBuilder()
.AddJsonFile("appsettings.json").Build();

FtpConnect ftpConnect = new(config);
FileHelper fileHelper = new(config);
DBHelper dbHelper = new(config);
ReportHelper reportHelper = new(config);

string[] routes = ["596","597"];

string biWeekEnd = fileHelper.GetBiWeekEdDate();

Console.WriteLine("Running payroll bi week ending "+biWeekEnd);

DateTime endDate = Convert.ToDateTime(biWeekEnd);
DateTime startDate = endDate.AddDays(-13);


foreach (string route in routes)
{
    ftpConnect.DownloadFilesForSite(route, startDate, endDate);
    List<RawDraw> rawDraws = fileHelper.GetRawDraw(route, startDate, endDate);
    dbHelper.RunInsertStoreProcedure("[dbo].[InsertRawDrawData]", JsonSerializer.Serialize(rawDraws, new JsonSerializerOptions { WriteIndented = true }));
}

Console.WriteLine("Draw files fetched & inserted in Database");

List<Collection> collections = fileHelper.GetCollections(endDate);
dbHelper.RunInsertStoreProcedure("[dbo].[InsertCollections]", JsonSerializer.Serialize(collections, new JsonSerializerOptions { WriteIndented = true }));

Console.WriteLine("Collections inserted in Database");

List<Tip> tips = fileHelper.GetTips(endDate);
dbHelper.RunInsertStoreProcedure("[dbo].[InsertTips]", JsonSerializer.Serialize(tips, new JsonSerializerOptions { WriteIndented = true }));
Console.WriteLine("Tips inserted in Database");

List<Employee> employees = JsonSerializer.Deserialize<List<Employee>>(dbHelper.RunGetStoreProcedure("[dbo].[GetCurrentEmployee]", null));

Dictionary<string, string> empIdMapping = new();
foreach (Employee employee in employees)
    empIdMapping[employee.Old_Id] = employee.EmployeeId;

Dictionary<string, List<SiteReport>> siteReport = fileHelper.GetSiteReports(endDate);

foreach (SiteReport re in siteReport["route"])
    re.EmployeeId = empIdMapping[re.EmployeeId];

foreach (SiteReport re in siteReport["other"])
    re.EmployeeId = empIdMapping[re.EmployeeId];

dbHelper.RunInsertStoreProcedure("[dbo].[InsertSiteReport]", JsonSerializer.Serialize(siteReport, new JsonSerializerOptions { WriteIndented = true }));
Console.WriteLine("Site report inserted in Database");

Dictionary<string, string> reportDateString = new();
reportDateString["startDate"] = startDate.ToString("yyyy-MM-dd");
reportDateString["endDate"] = endDate.ToString("yyyy-MM-dd");

string dateJson = JsonSerializer.Serialize(reportDateString, new JsonSerializerOptions { WriteIndented = false });

string reportContent = dbHelper.RunGetStoreProcedure("[dbo].[GetMasterReport]", dateJson);
reportContent = reportContent.Replace("\\", "").Replace("\"[", "[").Replace("]\"", "]");
File.WriteAllText(Path.Combine(config["TemplatePath"], "Reports", "JSONs", biWeekEnd + ".json"), reportContent);
List<MasterReport> masterReport = JsonSerializer.Deserialize<List<MasterReport>>(reportContent);

string weekEnding = endDate.ToString("yyyyMMdd");
string weekEndingHeader = endDate.ToString("dddd, d-MMMM-yyyy");

reportHelper.GenerateReportFile(masterReport, weekEnding);

Console.WriteLine("Report Content File Generated");

reportHelper.GenerateFinalPDF(weekEnding, weekEndingHeader);

Console.WriteLine("Final Report PDF Generated");

