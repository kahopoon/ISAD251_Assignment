using System;
namespace OrderApplication.Models
{
    public class GetProductDTO : ProductDTO
    {

        public GetProductDTO(Product product) : base(product)
        {
        }

    }
}
