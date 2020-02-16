# ISAD251_Assignment

### Introduction Youtube Video
[![Application Introduction](https://img.youtube.com/vi/Sn5CHDlARus/0.jpg)](https://www.youtube.com/watch?v=Sn5CHDlARus)

## Application fact sheet
This applicatino is a drinks/snack ordering system that serves customers/administrators of a bar. Customers or administrators can trigger different kind of events at a bar with using their mobile device on the mobile application. The system consists of two major components -- frontend application and the backend application. 

# Frontend application:
It is a iOS mobile application that written by Swift programming language, and request all services by connecting RESTful API behind, that is, the backend application. On this frontend application, customer view consists of 3 categories that divides by tabs at the application bottom -- Menu, Shopping Cart and Orders, at the tab 'Menu', customer can view list of drinks and snacks that available at the bar and add to the shopping cart, then at the tab 'Shopping Cart', customer can add or remove quantity of products that have been choosen, or trigger checkout action, and finally the tab 'Order', customer can view all of his/her order that made on this system, and allows to edit or cancel any of these order further. For the administrator view, there are only two tab -- Product and Orders, the tab 'Product' actually is the same view as the customer's 'Menu', but this time, products in the page can be update any of the attributes or remove from sale, also, administrators can add more products on this page. The tab 'Orders' is also the same view of customer's 'Orders', of course, this time the view is consists all customers' orders rather than one particular customer, and for the administrator, the can also set the order to in progress, delivered or cancelled.

# Backend application:
It is a ASP.NET Web API application that written by C# programming lanugage, the backend application allows frontend application requests using RESTful API standards and to handle/process among Users, Products and Orders entity. The application use MSSQL as the system's persistant storage. In general, the application will encrypt any plaintext passwords by AES encryption before putting into the system database, and except for the login, all other API requests would only allows system generated access token to serves as the authentication and authorization. The backend application consists of 3 controllers -- User, Product and Order, and each of them consists of 4 HTTP methos -- GET, POST, PUT and DELETE. The following table shows the functionality among controllers, HTTP method and user roles.

| Controller | Method | Role | Behaviour |
| ------ | ------ | ------ | ------ |
| /api/User/id | GET | Customer | Get his/her own user information (Login)
| /api/User/id | GET | Administrator | Get his/her own user information (Login)
| /api/User | GET | Customer | Not allowed
| /api/User | GET | Administrator | Get all users' information of the system
| /api/User | POST | Customer | Create user account (Register)
| /api/User | POST | Administator | Create administrator user account (Register) (Parameter 'approvalCode' needed)
| /api/User/id | PUT | Customer | Update his/her user account information
| /api/User/id | PUT | Administrator | Update his/her user account information
| /api/User/id | DELETE | Customer | Set his/her account to inactive on the system
| /api/User/id | DELETE | Administrator | Set his/her account to inactive on the system

## Product Menu/Shopping Cart Page
![Alt text](readme-images/ios_menu.PNG?raw=true "Frontend Application Menu Page")
![Alt text](readme-images/ios_cart.PNG?raw=true "Frontend Application Shopping Cart Page")

## Order and Update Order Page
![Alt text](readme-images/ios_order.PNG?raw=true "Frontend Application Order Page")
![Alt text](readme-images/ios_edit_order.PNG?raw=true "Frontend Application Update Order Page")

## Edit Order Cart Page/Order Updated Page
![Alt text](readme-images/ios_edit_order_add.PNG?raw=true "Frontend Application Edit Order Cart Page")
![Alt text](readme-images/ios_order_updated.PNG?raw=true "Frontend Application Order Updated Page")

## Adminitrator Update Product Pages
![Alt text](readme-images/ios_admin_update_product.PNG?raw=true "Frontend Application Update Product Page A")
![Alt text](readme-images/ios_admin_update_price.PNG?raw=true "Frontend Application Update Product Page B")

## Administrator Create Product Page/Show Customers' Orders Page
![Alt text](readme-images/ios_admin_create_product.PNG?raw=true "Frontend Application Create Product Page")
![Alt text](readme-images/ios_admin_show_orders.PNG?raw=true "Frontend Application Show Customers Order Page")

## Administrator Update Customer Order Page
![Alt text](readme-images/ios_admin_update_order.PNG?raw=true "Frontend Application Update Customer Order Page A")
![Alt text](readme-images/ios_admin_update_delivered.PNG?raw=true "Frontend Application Update Customer Order Page B")
