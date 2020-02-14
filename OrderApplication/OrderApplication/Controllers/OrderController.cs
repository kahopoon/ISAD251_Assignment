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
using OrderApplication.Models.Orders;

namespace OrderApplication.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OrderController : ControllerBase
    {
        private readonly OrderContext _context;

        public OrderController(OrderContext context)
        {
            _context = context;
        }

        // GET: api/Product
        [HttpGet]
        public async Task<ActionResult<IEnumerable<OrderDTO>>> GetOrders([FromQuery(Name = "accessToken")] string accessToken)
        {
            if (!this.ValidTokenUser(accessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            List<OrderDTO> allOrdersDTO = new List<OrderDTO>();

            if (this.ValidTokenAdmin(accessToken))
            {
                var allOrders = await _context.Orders.Include("OrderProducts").ToListAsync();
                foreach (Order order in allOrders)
                {
                    allOrdersDTO.Add(new OrderDTO(order));
                }
            } else
            {
                var currentUser = this.GetUserByToken(accessToken);
                var allOrders = await _context.Orders.Include("OrderProducts").Where(order => order.UserId == currentUser.UserId).ToListAsync();
                foreach (Order order in allOrders)
                {
                    allOrdersDTO.Add(new OrderDTO(order));
                }
            }
            return allOrdersDTO;
        }

        // GET: api/Product/5
        [HttpGet("{id}")]
        public async Task<ActionResult<OrderDTO>> GetOrder(string id, [FromQuery(Name = "accessToken")] string accessToken)
        {
            if (!this.ValidTokenUser(accessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            var orderToGet = await _context.Orders.Include("OrderProducts").FirstOrDefaultAsync(order => order.OrderId == id);

            if(!this.GetUserByToken(accessToken).UserId.Equals(orderToGet.UserId))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            OrderDTO orderDTO = new OrderDTO(orderToGet);
            return orderDTO;
        }

        // PUT: api/Product/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for
        // more details see https://aka.ms/RazorPagesCRUD.
        [HttpPut("{id}")]
        public async Task<ActionResult<OrderDTO>> PutOrder(string id, PutOrder putOrder)
        {

            if (!this.ValidTokenUser(putOrder.AccessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            if (id == null)
            {
                return BadRequest(this.GetError(Error.MISSING_ORDER_ID));
            }
            if (putOrder.OrderProducts == null)
            {
                return BadRequest(this.GetError(Error.MISSING_ORDER_PRODUCT));
            }

            var currentUser = this.GetUserByToken(putOrder.AccessToken);
            var orderToPut = await _context.Orders.Include("OrderProducts").FirstOrDefaultAsync(order => order.OrderId == id);

            if(orderToPut == null)
            {
                return BadRequest(this.GetError(Error.ORDER_NOT_FOUND));
            }
            if(!orderToPut.UserId.Equals(currentUser.UserId))
            {
                if(!this.ValidTokenAdmin(putOrder.AccessToken))
                {
                    return BadRequest(this.GetError(Error.INVALID_TOKEN));
                }
            }

            List<OrderProduct> orderProducts = new List<OrderProduct>();
            foreach (PutOrderProduct putOrderProduct in putOrder.OrderProducts)
            {
                Product productToOrder = this.GetProductById(putOrderProduct.ProductId);

                if (productToOrder == null)
                {
                    return BadRequest(this.GetError(Error.PRODUCT_NOT_FOUND));
                }
                if (putOrderProduct.Quantity == 0)
                {
                    return BadRequest(this.GetError(Error.MISSING_QUANTITY));
                }

                OrderProduct orderProduct = new OrderProduct();
                orderProduct.OrderId = orderToPut.OrderId;
                orderProduct.OrderProductId = Guid.NewGuid().ToString();
                orderProduct.ProductId = putOrderProduct.ProductId;
                orderProduct.Quantity = putOrderProduct.Quantity;
                orderProduct.SubTotalPrice = decimal.Multiply(productToOrder.Price, new decimal(orderProduct.Quantity));
                orderProducts.Add(orderProduct);
                _context.OrderProducts.Add(orderProduct);
            }

            decimal currentTotalPrice = orderToPut.OrderProducts.Sum(orderProduct => orderProduct.SubTotalPrice);
            decimal addPrice = orderProducts.Sum(orderProduct => orderProduct.SubTotalPrice);
            decimal newTotalPrice = decimal.Add(currentTotalPrice, addPrice);

            orderToPut.TotalPrice = newTotalPrice;

            if(this.ValidTokenAdmin(putOrder.AccessToken) && putOrder.Status != null)
            {
                orderToPut.Status = putOrder.Status;
            }

            _context.Entry(orderToPut).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw;
            }

            OrderDTO orderDTO = new OrderDTO(orderToPut);
            return orderDTO;
        }

        // POST: api/Product
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for
        // more details see https://aka.ms/RazorPagesCRUD.
        [HttpPost]
        public async Task<ActionResult<OrderDTO>> PostOrder(CreateOrder createOrder)
        {

            if (!this.ValidTokenUser(createOrder.AccessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            if(createOrder.OrderProducts == null || createOrder.OrderProducts.Count == 0)
            {
                return BadRequest(this.GetError(Error.MISSING_ORDER_PRODUCT));
            }

            var orderId = Guid.NewGuid().ToString();
            var userId = this.GetUserByToken(createOrder.AccessToken).UserId;

            Guid.NewGuid().ToString();

            List<OrderProduct> orderProducts = new List<OrderProduct>();
            foreach(CreateOrderProduct createOrderProduct in createOrder.OrderProducts)
            {
                Product productToOrder = this.GetProductById(createOrderProduct.ProductId);

                if(productToOrder == null)
                {
                    return BadRequest(this.GetError(Error.PRODUCT_NOT_FOUND));
                }
                if(createOrderProduct.Quantity == 0)
                {
                    return BadRequest(this.GetError(Error.MISSING_QUANTITY));
                }

                OrderProduct orderProduct = new OrderProduct();
                orderProduct.OrderId = orderId;
                orderProduct.OrderProductId = Guid.NewGuid().ToString();
                orderProduct.ProductId = createOrderProduct.ProductId;
                orderProduct.Quantity = createOrderProduct.Quantity;
                orderProduct.SubTotalPrice = decimal.Multiply(productToOrder.Price, new decimal(orderProduct.Quantity));
                orderProducts.Add(orderProduct);
                _context.OrderProducts.Add(orderProduct);
            }

            Order order = new Order();
            order.UserId = userId;
            order.OrderId = orderId;
            order.TotalPrice = orderProducts.Sum(orderProduct => orderProduct.SubTotalPrice);
            order.Status = "CREATED";
            _context.Orders.Add(order);

            await _context.SaveChangesAsync();

            OrderDTO orderDTO = new OrderDTO(order);
            return CreatedAtAction(nameof(GetOrder), new { id = orderId }, orderDTO);
        }


        // DELETE: api/Product/5
        [HttpDelete("{id}")]
        public async Task<ActionResult<OrderDTO>> DeleteOrder(string id, RemoveOrder removeOrder)
        {
            if (!this.ValidTokenUser(removeOrder.AccessToken))
            {
                return BadRequest(this.GetError(Error.INVALID_TOKEN));
            }

            if (id == null)
            {
                return BadRequest(this.GetError(Error.MISSING_ORDER_ID));
            }

            var currentUser = this.GetUserByToken(removeOrder.AccessToken);
            var orderToRemove = await _context.Orders.Include("OrderProducts").FirstOrDefaultAsync(order => order.OrderId == id);

            if (orderToRemove == null)
            {
                return BadRequest(this.GetError(Error.ORDER_NOT_FOUND));
            }
            if (!orderToRemove.UserId.Equals(currentUser.UserId))
            {
                if (!this.ValidTokenAdmin(removeOrder.AccessToken))
                {
                    return BadRequest(this.GetError(Error.INVALID_TOKEN));
                }
            }

            orderToRemove.Status = "CANCELLED";

            _context.Entry(orderToRemove).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                throw;
            }

            OrderDTO orderDTO = new OrderDTO(orderToRemove);
            return orderDTO;
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

        public Product GetProductById(string productId)
        {
            var product = _context.Products.Where(product => product.ProductId == productId).First();
            return product;
        }
    }
}
