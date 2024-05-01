using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Renci.SshNet;
using System.Collections;

namespace DeliveryInkPayroll
{
    internal class FtpConnect(IConfiguration configuration)
    {
        private readonly IConfiguration _configuration = configuration;
        private string? host;
        private int port;
        private string? userName;
        private string? password;
        private string? filePrefix;

        public void DownloadFilesForSite(string site, DateTime startDate, DateTime endDate)
        {
            var settings = _configuration.GetRequiredSection("ftpConnect");
            host = settings["ftpServer"];
            port = Convert.ToInt32(settings["ftpPort"]);
            userName = _configuration["ftpConnect:credential:" + site + ":username"];
            password = _configuration["ftpConnect:credential:" + site + ":password"];
            filePrefix = _configuration["ftpConnect:credential:" + site + ":filePrefix"];

            Directory.CreateDirectory("RemoteFiles");

            List<DateTime> dateList = Enumerable.Range(0, 1 + endDate.Subtract(startDate).Days)
                                      .Select(offset => startDate.AddDays(offset)).ToList();
            
            var client = new SftpClient(host, port, userName, password);

            try
            {
                client.Connect();

                foreach(DateTime date in dateList)
                {
                    string fileName = filePrefix + date.ToString("yyyyMMdd") + ".CSV";

                    string remoteFilePath = "Outgoing/" + fileName;
                    string localFilePath = Path.Combine("RemoteFiles", fileName);

                    using var fileStream = File.Create(localFilePath);
                    client.DownloadFile(remoteFilePath, fileStream);
                }             
            }
            catch (Exception )
            {
                throw;
            }
            finally
            {
                client.Dispose();
            }
        }
    }
}
