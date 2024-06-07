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

Dictionary<string, string> reportDateString = new();
reportDateString["startDate"] = startDate.ToString("yyyy-MM-dd");
reportDateString["endDate"] = endDate.ToString("yyyy-MM-dd");

string weekEnding = endDate.ToString("yyyy-MM-dd");
string weekEndingHeader = endDate.ToString("dddd, d-MMMM-yyyy");

string dateJson = JsonSerializer.Serialize(reportDateString, new JsonSerializerOptions { WriteIndented = false });

int dayCount = Convert.ToInt16(dbHelper.RunGetStoreProcedure("[dbo].[CheckDrawData]", dateJson));

bool getDrawFiles = false;

if(dayCount != 14)
    getDrawFiles = true;
else
{
    Console.Write("Draw data already exist in database. Insert again ? (Y/N) : ");
    string userInput = Console.ReadLine();
    if (userInput.ToLower() == "y")
        getDrawFiles = true;
}

if (getDrawFiles)
{
    foreach (string route in routes)
    {
        ftpConnect.DownloadFilesForSite(route, startDate, endDate);
        List<RawDraw> rawDraws = fileHelper.GetRawDraw(route, startDate, endDate);
        dbHelper.RunInsertStoreProcedure("[dbo].[InsertRawDrawData]", JsonSerializer.Serialize(rawDraws, new JsonSerializerOptions { WriteIndented = true }));
    }
    Console.WriteLine("Draw files fetched & inserted in Database");

}

List<Collection> collections = fileHelper.GetCollections(endDate);
dbHelper.RunInsertStoreProcedure("[dbo].[InsertCollections]", JsonSerializer.Serialize(collections, new JsonSerializerOptions { WriteIndented = true }));

Console.WriteLine("Collections inserted in Database");

List<Tip> tips = fileHelper.GetTips(endDate);
dbHelper.RunInsertStoreProcedure("[dbo].[InsertTips]", JsonSerializer.Serialize(tips, new JsonSerializerOptions { WriteIndented = true }));
Console.WriteLine("Tips inserted in Database");

List<Employee> employees = JsonSerializer.Deserialize<List<Employee>>(dbHelper.RunGetStoreProcedure("[dbo].[GetCurrentEmployee]", null));

//Dictionary<string, string> empIdMapping = new();
//foreach (Employee employee in employees)
//    empIdMapping[employee.Old_Id] = employee.EmployeeId;

List<string> employeeList = new();
foreach (Employee employee in employees)
    employeeList.Add(employee.EmployeeId);

Dictionary<string, List<SiteReport>> siteReport = fileHelper.GetSiteReports(endDate);

//foreach (SiteReport re in siteReport["route"])
//    re.EmployeeId = empIdMapping[re.EmployeeId];

//foreach (SiteReport re in siteReport["other"])
//    re.EmployeeId = empIdMapping[re.EmployeeId];

foreach (SiteReport re in siteReport["route"])
    if (!employeeList.Contains(re.EmployeeId))
        throw new Exception(re.EmployeeId + " is not present in database.");

foreach (SiteReport re in siteReport["other"])
    if (!employeeList.Contains(re.EmployeeId))
        throw new Exception(re.EmployeeId + " is not present in database.");

dbHelper.RunInsertStoreProcedure("[dbo].[InsertSiteReport]", JsonSerializer.Serialize(siteReport, new JsonSerializerOptions { WriteIndented = true }));
Console.WriteLine("Site report inserted in Database");

string reportContent = dbHelper.RunGetStoreProcedure("[dbo].[GetMasterReport]", dateJson);
reportContent = reportContent.Replace("\\", "").Replace("\"[", "[").Replace("]\"", "]");
File.WriteAllText(Path.Combine(config["TemplatePath"], weekEnding, "OutputFiles", biWeekEnd + ".json"), reportContent);
List<MasterReport> masterReport = JsonSerializer.Deserialize<List<MasterReport>>(reportContent);

reportHelper.GenerateReportFile(masterReport, weekEnding);

Console.WriteLine("Report Content File Generated");

reportHelper.GenerateFinalPDF(weekEnding, weekEndingHeader);

Console.WriteLine("Final Report PDF Generated");

