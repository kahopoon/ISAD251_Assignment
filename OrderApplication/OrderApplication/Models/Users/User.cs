using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace OrderApplication.Models
{
    public class User
    {

        public string UserId { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string Role { get; set; }
        public string AccessToken { get; set; }
        public string TokenExpires { get; set; }
        public string Status { get; set; }

        [Column(TypeName = "datetime2")]
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public DateTime UpdateDatetime { get; set; }


        public Boolean isAdmin()
        {
            return this.Role != null && this.Role.Equals("ADMIN");
        }

        public bool tokenExpired()
        {
            if(this.TokenExpires == null)
            {
                return true;
            }
            var currentTimestamp = new DateTimeOffset(DateTime.UtcNow).ToUnixTimeSeconds();
            return currentTimestamp > Int64.Parse(this.TokenExpires);
        }
    }
}
