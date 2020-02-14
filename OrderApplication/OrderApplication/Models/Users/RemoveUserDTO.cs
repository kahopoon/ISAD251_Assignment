using System;
namespace OrderApplication.Models
{
    public class RemoveUserDTO : UserDTO
    {
        public RemoveUserDTO(User user) : base(user)
        {
        }
    }
}
