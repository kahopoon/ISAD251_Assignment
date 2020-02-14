using System;
namespace OrderApplication.Models
{
    public class GetUserDTO : UserDTO
    {

        public GetUserDTO(User user) : base(user)
        {
        }

    }
}
