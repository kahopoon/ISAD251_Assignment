using System;
using System.ComponentModel.DataAnnotations.Schema;
using OrderApplication.Controllers;

namespace OrderApplication.Models
{
    public class UserDTO
    {
        public UserDTO(User user)
        {
            this.Name = user.Name;
            this.Email = user.Email;
            this.Role = user.Role;
            this.AccessToken = user.AccessToken;
            this.TokenExpires = user.TokenExpires;
            this.Password = this.GetMaskedPassword(user.Password);
            this.Status = user.Status;
            this.UpdateDatetime = user.UpdateDatetime;
        }

        public string Name { get; set; }
        public string Email { get; set; }
        public string Role { get; set; }
        public string Password { get; set; }
        public string AccessToken { get; set; }
        public string TokenExpires { get; set; }
        public string Status { get; set; }
        public DateTime UpdateDatetime { get; set; }

        public string GetMaskedPassword(string encryptedPassword)
        {
            string plainPassword = new AES().DecryptFromBase64String(encryptedPassword);
            string maskedPassword = "";
            for (int i = 0; i < plainPassword.Length; i++)
            {
                if (i == 0 || i == plainPassword.Length - 1)
                {
                    maskedPassword += plainPassword[i];
                }
                else
                {
                    maskedPassword += "*";
                }
            }
            return maskedPassword;
        }
    }
}
