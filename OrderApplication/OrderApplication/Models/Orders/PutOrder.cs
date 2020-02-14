using System;
using System.Collections.Generic;

namespace OrderApplication.Models.Orders
{
    public class PutOrder
    {
        public string AccessToken { get; set; }
        public string Status { get; set; }

        public ICollection<PutOrderProduct> OrderProducts { get; set; }
    }
}
