using System;
namespace OrderApplication.Models.Orders
{
    public class OrderProductDTO
    {
        public OrderProductDTO(OrderProduct orderProduct)
        {
            this.ProductId = orderProduct.ProductId;
            this.Quantity = orderProduct.Quantity;
            this.SubTotalPrice = orderProduct.SubTotalPrice;
        }

        public string ProductId { get; set; }
        public int Quantity { get; set; }
        public decimal SubTotalPrice { get; set; }
    }
}
