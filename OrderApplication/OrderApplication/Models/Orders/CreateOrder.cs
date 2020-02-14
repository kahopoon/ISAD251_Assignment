using System;
using System.Collections.Generic;

namespace OrderApplication.Models.Orders
{
    public class CreateOrder
    {
        public string AccessToken { get; set; }

        public ICollection<CreateOrderProduct> OrderProducts { get; set; }
    }
}
