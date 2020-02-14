using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace OrderApplication.Models
{
    public class ProductDTO
    {
        public ProductDTO(Product product)
        {
            this.ProductId = product.ProductId;
            this.Name = product.Name;
            this.Type = product.Type;
            this.Description = product.Description;
            this.ImagePath = product.ImagePath;
            this.Status = product.Status;
            this.Price = product.Price;
        }

        public string ProductId { get; set; }
        public string Name { get; set; }
        public string Type { get; set; }
        public string Description { get; set; }
        public string ImagePath { get; set; }
        public decimal Price { get; set; }
        public string Status { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime UpdateDatetime { get; set; }

    }
}
