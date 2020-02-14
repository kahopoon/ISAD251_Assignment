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
    public class ProductController : ControllerBase
    {
        private readonly OrderContext _context;

        public ProductController(OrderContext context)
        {
            _context = context;
        }

        // GET: api/Product
        [HttpGet]
        public async Task<ActionResult<IEnumerable<GetProductDTO>>> GetProducts([FromQuery(Name = "accessToken")] string accessToken)
        {

            if (!this.ValidTokenUser(accessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            var adminAccount = await _context.Users.Where(user => user.AccessToken == accessToken).FirstAsync();
            if (adminAccount == null)
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            var allProducts = await _context.Products.ToListAsync();
            List<GetProductDTO> allProductsDTO = new List<GetProductDTO>();
            foreach (Product product in allProducts)
            {
                allProductsDTO.Add(new GetProductDTO(product));
            }

            return allProductsDTO;
        }

        // GET: api/Product/5
        [HttpGet("{id}")]
        public async Task<ActionResult<GetProductDTO>> GetProduct(string id, [FromQuery(Name = "accessToken")] string accessToken)
        {
            var productToGet = await _context.Products.FindAsync(id);

            if (productToGet == null)
            {
                return BadRequest(this.GetError(Error.PRODUCT_NOT_FOUND));
            }

            if (!this.ValidTokenUser(accessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            GetProductDTO getProductDTO = new GetProductDTO(productToGet);
            return getProductDTO;
        }

        // PUT: api/Product/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for
        // more details see https://aka.ms/RazorPagesCRUD.
        [HttpPut("{id}")]
        public async Task<ActionResult<PutProductDTO>> PutProduct(string id, PutProduct putProduct)
        {
            var productToPut = await _context.Products.FindAsync(id);

            PutProduct putProductModel = putProduct;

            if (productToPut == null)
            {
                return BadRequest(this.GetError(Error.PRODUCT_NOT_FOUND));
            }
            if (!this.ValidTokenAdmin(putProductModel.AccessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            if (putProductModel.Name != null && putProductModel.Name.Length > 0)
            {
                productToPut.Name = putProduct.Name;
            }
            if (putProductModel.Type != null && putProductModel.Type.Length > 0)
            {
                productToPut.Type = putProduct.Type;
            }
            if (putProductModel.Description != null && putProductModel.Description.Length > 0)
            {
                productToPut.Description = putProduct.Description;
            }
            if (putProductModel.ImagePath != null && putProductModel.ImagePath.Length > 0)
            {
                productToPut.ImagePath = putProduct.ImagePath;
            }
            if (putProductModel.Price != null && putProductModel.Price.Length > 0)
            {
                productToPut.Price = Convert.ToDecimal(putProductModel.Price);
            }
            if (putProductModel.Status != null && putProductModel.Status.Length > 0)
            {
                productToPut.Status = putProduct.Status;
            }

            _context.Entry(productToPut).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw;
            }

            PutProductDTO putProductDTO = new PutProductDTO(productToPut);
            return putProductDTO;
        }

        // POST: api/Product
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for
        // more details see https://aka.ms/RazorPagesCRUD.
        [HttpPost]
        public async Task<ActionResult<CreateProductDTO>> PostProduct(CreateProduct createProduct)
        {
            CreateProduct createProductModel = createProduct;

            if (!this.ValidTokenAdmin(createProductModel.AccessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }


            if (createProductModel.Name == null || createProductModel.Name.Length == 0)
            {
                return BadRequest(this.GetError(Error.MISSING_NAME));
            }
            if (createProductModel.Type == null || createProductModel.Type.Length == 0)
            {
                return BadRequest(this.GetError(Error.MISSING_TYPE));
            }
            if (createProductModel.Description == null || createProductModel.Description.Length == 0)
            {
                return BadRequest(this.GetError(Error.MISSING_DESCRIPTION));
            }
            if (createProductModel.ImagePath == null || createProductModel.ImagePath.Length == 0)
            {
                return BadRequest(this.GetError(Error.MISSING_IMAGE_PATH));
            }
            if (createProductModel.Status == null || createProductModel.Status.Length == 0)
            {
                return BadRequest(this.GetError(Error.MISSING_STATUS));
            }

            Product product = new Product();
            product.ProductId = Guid.NewGuid().ToString();
            product.Name = createProductModel.Name;
            product.Type = createProductModel.Type;
            product.Description = createProductModel.Description;
            product.ImagePath = createProductModel.ImagePath;
            product.Status = createProductModel.Status;
            product.Price = Convert.ToDecimal(createProductModel.Price);
            
            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            CreateProductDTO productDTO = new CreateProductDTO(product);
            return CreatedAtAction(nameof(GetProduct), new { id = product.ProductId }, productDTO);
        }


        // DELETE: api/Product/5
        [HttpDelete("{id}")]
        public async Task<ActionResult<RemoveProductDTO>> DeleteProduct(string id, RemoveProduct removeProduct)
        {
            var productToRemove = await _context.Products.FindAsync(id);

            RemoveProduct removeProductModel = removeProduct;

            if (productToRemove == null)
            {
                return BadRequest(this.GetError(Error.PRODUCT_NOT_FOUND));
            }
            if (!this.ValidTokenAdmin(removeProductModel.AccessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            productToRemove.Status = "INACTIVE";

            _context.Entry(productToRemove).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw;
            }

            RemoveProductDTO removeProductDTO = new RemoveProductDTO(productToRemove);
            return removeProductDTO;
        }

        public ErrorView GetError(Error error)
        {
            ErrorView errorView = new ErrorView();
            errorView.Code = (int)error;
            errorView.Description = error.ToString();
            return errorView;
        }

        public User GetUserByToken(string token)
        {
            var userAccount = _context.Users.Where(user => user.AccessToken == token).First();
            return userAccount;
        }

        public Boolean ValidTokenUser(string token)
        {
            if (token == null)
            {
                return false;
            }
            var userAccount = this.GetUserByToken(token);
            if (userAccount != null)
            {
                return !userAccount.tokenExpired();
            }
            return false;
        }

        public Boolean ValidTokenAdmin(string token)
        {
            if (token == null)
            {
                return false;
            }
            var userAccount = this.GetUserByToken(token);
            if (userAccount != null)
            {
                return !userAccount.tokenExpired() && userAccount.isAdmin();
            }
            return false;
        }

    }
}
