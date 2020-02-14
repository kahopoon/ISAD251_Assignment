using System;
namespace OrderApplication.Models
{
    public class RemoveProductDTO : ProductDTO
    {
        public RemoveProductDTO(Product product) : base(product)
        {
        }
    }
}
