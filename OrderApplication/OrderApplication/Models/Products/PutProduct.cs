using System;
namespace OrderApplication.Models
{
    public class PutProduct
    {
        public string AccessToken { get; set; }
        public string Name { get; set; }
        public string Type { get; set; }
        public string Description { get; set; }
        public string ImagePath { get; set; }
        public string Price { get; set; }
        public string Status { get; set; }

    }
}
