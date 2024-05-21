using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic.FileIO;


namespace DeliveryInkPayroll
{
    internal  class FileHelper(IConfiguration configuration)
    {
        private readonly IConfiguration _configuration = configuration;

        public string GetBiWeekEdDate()
        {
            return File.ReadAllText(Path.Combine(_configuration["TemplatePath"], "biweekend.txt"));
        }

        public List<RawDraw> GetRawDraw(string site, DateTime startDate, DateTime endDate)
        {
            List<RawDraw> draws = new List<RawDraw>();

            List<DateTime> dateList = Enumerable.Range(0, 1 + endDate.Subtract(startDate).Days)
                          .Select(offset => startDate.AddDays(offset)).ToList();

            string? filePrefix = _configuration["ftpConnect:credential:" + site + ":filePrefix"];

            foreach (DateTime date in dateList)
            {
                string fileName = "RemoteFiles\\" + filePrefix + date.ToString("yyyyMMdd") + ".CSV";
                using (TextFieldParser parser = new(fileName))
                {
                    parser.TextFieldType = FieldType.Delimited;
                    parser.SetDelimiters(",");

                    // Skip the header
                    parser.ReadLine();

                    // Parse the remaining lines
                    while (!parser.EndOfData)
                    {
                        string[] fields = parser.ReadFields();

                        RawDraw rawDraw = new()
                        {
                            Date = date,
                            Day = date.ToString("dddd"),
                            Plant = fields[2],
                            Route = fields[3],
                            Product = fields[4],
                            CustomerClassification = fields[5],
                            Draw = int.Parse(fields[6]),
                            CATAddressID = int.Parse(fields[7]),
                            ZipCode = fields[8],
                            ZipPlus4 = fields[9],
                            Count = int.Parse(fields[10])
                        };

                        if (date.DayOfWeek == DayOfWeek.Sunday)
                            rawDraw.DayClass = "SUN";
                        else if (date.DayOfWeek == DayOfWeek.Saturday)
                            rawDraw.DayClass = "SAT";
                        else
                            rawDraw.DayClass = "MF";
                        if (date.DayOfWeek == DayOfWeek.Sunday)
                            rawDraw.WeekEnding = date;
                        else
                            rawDraw.WeekEnding = date.AddDays(7 - (int)date.DayOfWeek);

                        draws.Add(rawDraw);
                    }
                }
            }

            DirectoryInfo di = new DirectoryInfo("RemoteFiles\\");
            foreach (FileInfo file in di.GetFiles())
                file.Delete();

            return draws;
        }

        public Dictionary<string, List<SiteReport>> GetSiteReports(DateTime biWeekEnd)
        {
            List<SiteReport> routeReports = new List<SiteReport>();
            List<SiteReport> otherTaskReports = new List<SiteReport>();
            Dictionary<string, List<SiteReport>> siteReport = new();

            string fileName = Path.Combine(_configuration["TemplatePath"], biWeekEnd.ToString("yyyy-MM-dd"), "InputFiles", "SiteReport.CSV");

            using (TextFieldParser parser = new(fileName))
            {
                parser.TextFieldType = FieldType.Delimited;
                parser.SetDelimiters(",");

                // Skip the header
                string[] header = parser.ReadFields();

                // Parse the remaining lines
                while (!parser.EndOfData)
                {
                    string[] fields = parser.ReadFields();

                    for(int i = 2; i < 16; i++)
                    {
                        if (!string.IsNullOrEmpty(fields[i]))
                        {
                            SiteReport report = new()
                            {
                                Date = Convert.ToDateTime(header[i]),
                                TaskType = fields[0],
                                TaskName = fields[1],
                                EmployeeId = fields[i]
                            };
                            if(fields[0] == "Route")
                                routeReports.Add(report);
                            else
                                otherTaskReports.Add(report);
                        }
                    }
                }
            }
            siteReport["route"] = routeReports;
            siteReport["other"] = otherTaskReports;

            return siteReport;
        }

        public List<Collection> GetCollections(DateTime biWeekEnd)
        {
            List<Collection> collections = new List<Collection>();

            string fileName = Path.Combine(_configuration["TemplatePath"], biWeekEnd.ToString("yyyy-MM-dd"), "InputFiles", "CollectionList.CSV");

            if (File.Exists(fileName))
            {
                using (TextFieldParser parser = new(fileName))
                {
                    parser.TextFieldType = FieldType.Delimited;
                    parser.SetDelimiters(",");
                    while (!parser.EndOfData)
                    {
                        string[] fields = parser.ReadFields();
                        Collection collection = new()
                        {
                            SubscriptionID = fields[0],
                            Amount = Convert.ToDouble(fields[1]),
                            Name = fields[2].Trim(),
                            Address = fields[3].Trim(),
                            Route = fields[4].Trim(),
                            EmployeeID = fields[5].Trim(),
                            BiWeekEnd = biWeekEnd,
                        };
                        collections.Add(collection);
                    }
                }
            }

            return collections;
        }

        public List<Tip> GetTips(DateTime biWeekEnd)
        {
            List<Tip> tips = new List<Tip>();

            string fileName = Path.Combine(_configuration["TemplatePath"], biWeekEnd.ToString("yyyy-MM-dd"), "InputFiles",  "Tips.CSV");

            if (File.Exists(fileName))
            {
                Dictionary<string, string> subsRouteMapping = new Dictionary<string, string>();

                string[] ids = ["D46", "D47"];
                foreach (string id in ids)
                {
                    string subssFile = Path.Combine(_configuration["TemplatePath"], id + "-Subs.CSV");

                    using (TextFieldParser parser = new(subssFile))
                    {
                        parser.TextFieldType = FieldType.Delimited;
                        parser.SetDelimiters(",");
                        parser.ReadFields(); //skip headers
                        while (!parser.EndOfData)
                        {
                            string[] fields = parser.ReadFields();
                            subsRouteMapping[fields[3].Replace("'","")] = fields[14];
                        }
                    }
                }

                using (TextFieldParser parser = new(fileName))
                {
                    parser.TextFieldType = FieldType.Delimited;
                    parser.SetDelimiters(",");
                    while (!parser.EndOfData)
                    {
                        string[] fields = parser.ReadFields();
                        Tip tip = new()
                        {
                            Product = fields[0],                      
                            Address = fields[2].Trim(),
                            TipDate = Convert.ToDateTime(fields[3]),
                            Amount = Convert.ToDouble(fields[4]),
                            Route = string.IsNullOrEmpty(fields[5]) ? subsRouteMapping[fields[1]] : fields[5],
                            BiWeekEnd = biWeekEnd,
                        };
                        tips.Add(tip);
                    }
                }
            }
            return tips;
        }
    }
}
