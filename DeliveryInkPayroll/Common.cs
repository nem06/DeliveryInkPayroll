using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace DeliveryInkPayroll
{
    internal class Common(IConfiguration configuration)
    {
        private readonly IConfiguration _configuration = configuration;
        
    }
}
