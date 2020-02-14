using System;
namespace OrderApplication.Models
{
    public class CreateProductDTO : ProductDTO
    {

        public CreateProductDTO(Product product) : base(product)
        {
        }

    }
}
