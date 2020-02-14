using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OrderApplication.Models;
using System.Net.Http;


namespace OrderApplication.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly OrderContext _context;

        public UserController(OrderContext context)
        {
            _context = context;
        }

        // GET: api/User
        [HttpGet]
        public async Task<ActionResult<IEnumerable<GetUserDTO>>> GetUsers([FromQuery(Name = "accessToken")] string accessToken)
        {
            if(accessToken == null)
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            var userAccount = await _context.Users.Where(user => user.AccessToken == accessToken).FirstAsync();
            if (userAccount == null || !userAccount.isAdmin())
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }
            if (userAccount.tokenExpired())
            {
                return BadRequest(this.GetError(Error.EXPIRED_TOKEN));
            }

            var allUsers = await _context.Users.ToListAsync();
            List<GetUserDTO> allUsersDTO = new List<GetUserDTO>();
            foreach (User user in allUsers)
            {
                allUsersDTO.Add(new GetUserDTO(user));
            }

            return allUsersDTO;
        }

        // GET: api/User/5
        [HttpGet("{email}")]
        public async Task<ActionResult<GetUserDTO>> GetUser(string email, [FromQuery(Name = "password")] string password, [FromQuery(Name = "accessToken")] string accessToken)
        {
            var userToGet = await _context.Users.Where(user => user.Email == email).FirstAsync();

            if (userToGet == null)
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            if (password == null && accessToken == null)
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }
            if (!userToGet.Password.Equals(new AES().EncryptToBase64String(password)))
            {
                return BadRequest(this.GetError(Error.INVALID_PASSWORD));
            }
            if (accessToken != null && !accessToken.Equals(userToGet.AccessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }
            if (accessToken != null && userToGet.tokenExpired())
            {
                return BadRequest(this.GetError(Error.EXPIRED_TOKEN));
            }

            var expiresTimestamp = new DateTimeOffset(DateTime.UtcNow).ToUnixTimeSeconds() + 60 * 60 * 24;
            userToGet.TokenExpires = expiresTimestamp.ToString();

            _context.Entry(userToGet).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw;
            }

            GetUserDTO getUserDTO = new GetUserDTO(userToGet);
            return getUserDTO;
        }

        // PUT: api/User/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for
        // more details see https://aka.ms/RazorPagesCRUD.
        [HttpPut("{email}")]
        public async Task<ActionResult<PutUserDTO>> PutUser(string email, PutUser putUser)
        {
            var userToPut = await _context.Users.Where(user => user.Email == email).FirstAsync();

            PutUser putUserModel = putUser;

            if(userToPut == null)
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }
            if (putUser.AccessToken == null || !putUserModel.AccessToken.Equals(userToPut.AccessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }
            if (userToPut.tokenExpired())
            {
                return BadRequest(this.GetError(Error.EXPIRED_TOKEN));
            }

            if (putUserModel.Name != null && putUserModel.Name.Length > 0)
            {
                userToPut.Name = putUser.Name;
            }
            if (putUserModel.Email != null && putUserModel.Email.Length > 0)
            {
                var emailExistUser = await _context.Users.Where(user => user.Email == putUserModel.Email).FirstAsync();
                if(emailExistUser != null)
                {
                    return BadRequest(this.GetError(Error.DUPLICATED_EMAIL));
                }
                userToPut.Email = putUser.Email;
            }
            if (putUserModel.Password != null && putUserModel.Password.Length > 0)
            {
                userToPut.Password = new AES().EncryptToBase64String(putUser.Password);
            }

            _context.Entry(userToPut).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw;
            }

            PutUserDTO putUserDTO = new PutUserDTO(userToPut);
            return putUserDTO;
        }

        // POST: api/User
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for
        // more details see https://aka.ms/RazorPagesCRUD.
        [HttpPost]
        public async Task<ActionResult<CreateUserDTO>> PostUser(CreateUser createUser)
        {
            CreateUser createUserModel = createUser;

            if (createUserModel.Name == null || createUserModel.Name.Length == 0)
            {
                return BadRequest(this.GetError(Error.MISSING_NAME));
            }
            if (createUserModel.Email == null || createUserModel.Email.Length == 0)
            {
                return BadRequest(this.GetError(Error.MISSING_EMAIL));
            }
            if (createUserModel.Password == null || createUserModel.Password.Length == 0)
            {
                return BadRequest(this.GetError(Error.MISSING_PASSWORD));
            }

            var existingAccount = _context.Users.Where(user => user.Email == createUserModel.Email);
            if (existingAccount.ToArray().Any())
            {
                return BadRequest(this.GetError(Error.DUPLICATED_EMAIL));

            }

            string role = "USER";
            if(createUserModel.ApprovalCode != null && createUserModel.ApprovalCode.Equals("hjskdldfladufh8978o"))
            {
                role = "ADMIN";
            }

            User user = new User();
            user.Name = createUserModel.Name;
            user.Password = new AES().EncryptToBase64String(createUserModel.Password);
            user.Email = createUserModel.Email;
            user.UserId = Guid.NewGuid().ToString();
            user.AccessToken = Guid.NewGuid().ToString();
            user.Role = role;
            var expiresTimestamp = new DateTimeOffset(DateTime.UtcNow).ToUnixTimeSeconds() + 60 * 60 * 24;
            user.TokenExpires = expiresTimestamp.ToString();
            user.Status = "ACTIVE";
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            CreateUserDTO userDTO = new CreateUserDTO(user);
            return CreatedAtAction(nameof(GetUser), new { email = userDTO.Email }, userDTO);
        }

        // DELETE: api/User/5
        [HttpDelete("{email}")]
        public async Task<ActionResult<RemoveUserDTO>> DeleteUser(string email, RemoveUser removeUser)
        {
            var userToRemove = await _context.Users.Where(user => user.Email == email).FirstAsync();

            RemoveUser removeUserModel = removeUser;

            if (userToRemove == null)
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }
            if (removeUser.AccessToken == null || !removeUserModel.AccessToken.Equals(userToRemove.AccessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }
            if (userToRemove.tokenExpired())
            {
                return BadRequest(this.GetError(Error.EXPIRED_TOKEN));
            }

            userToRemove.Status = "INACTIVE";

            _context.Entry(userToRemove).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw;
            }

            RemoveUserDTO removeUserDTO = new RemoveUserDTO(userToRemove);
            return removeUserDTO;
        }

        public ErrorView GetError(Error error)
        {
            ErrorView errorView = new ErrorView();
            errorView.Code = (int)error;
            errorView.Description = error.ToString();
            return errorView;
        }

    }
}
