using System;
namespace OrderApplication.Models
{
    public class OrderProduct
    {
        public string OrderProductId { get; set; }
        public string OrderId { get; set; }
        public string ProductId { get; set; }
        public int Quantity { get; set; }
        public decimal SubTotalPrice { get; set; }

    }
}
