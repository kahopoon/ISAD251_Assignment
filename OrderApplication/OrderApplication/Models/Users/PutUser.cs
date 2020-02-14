using System;
namespace OrderApplication.Models
{
    public class PutUser
    {
        public string AccessToken { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }

    }
}
