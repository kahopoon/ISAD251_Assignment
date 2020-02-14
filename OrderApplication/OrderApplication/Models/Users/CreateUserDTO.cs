using System;
namespace OrderApplication.Models
{
    public class CreateUserDTO : UserDTO
    {

        public CreateUserDTO(User user) : base(user)
        {
        }

    }
}
