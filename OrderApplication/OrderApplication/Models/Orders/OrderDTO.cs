using System;
using System.Collections.Generic;

namespace OrderApplication.Models.Orders
{
    public class OrderDTO
    {
        public OrderDTO(Order order)
        {
            this.OrderId = order.OrderId;
            this.TotalPrice = order.TotalPrice;
            this.Status = order.Status;
            this.CreateDatetime = order.CreateDatetime;
            this.UpdateDatetime = order.UpdateDatetime;

            this.OrderProducts = new List<OrderProductDTO>();
            foreach(OrderProduct orderProduct in order.OrderProducts)
            {
                this.OrderProducts.Add(new OrderProductDTO(orderProduct));
            }
        }

        public string OrderId { get; set; }
        public decimal TotalPrice { get; set; }
        public string Status { get; set; }
        public DateTime CreateDatetime { get; set; }
        public DateTime UpdateDatetime { get; set; }

        public ICollection<OrderProductDTO> OrderProducts { get; set; }

    }
}
