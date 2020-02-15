-- Drop table

-- DROP TABLE isad251_2019_db_stud_19.dbo.Products GO

CREATE TABLE isad251_2019_db_stud_19.dbo.Products (
	ProductId varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Name varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Type] varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Description varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	ImagePath varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Status varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Price decimal(10,2) NULL,
	CreateDatetime datetime2(7) NULL,
	UpdateDatetime datetime2(7) NULL,
	CONSTRAINT PK__Products__B40CC6CDF8788A65 PRIMARY KEY (ProductId)
) GO;

-- Drop table

-- DROP TABLE isad251_2019_db_stud_19.dbo.Users GO

CREATE TABLE isad251_2019_db_stud_19.dbo.Users (
	UserId varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Name varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Role] varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	AccessToken varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Email varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Password varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	TokenExpires varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Status varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CreateDatetime datetime2(7) NULL,
	UpdateDatetime datetime2(7) NULL,
	CONSTRAINT PK__Users__1788CC4CF4DD8A71 PRIMARY KEY (UserId)
) GO;

-- Drop table

-- DROP TABLE isad251_2019_db_stud_19.dbo.Orders GO

CREATE TABLE isad251_2019_db_stud_19.dbo.Orders (
	OrderId varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	UserId varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	TotalPrice decimal(10,2) NULL,
	CreateDatetime datetime2(7) NULL,
	UpdateDatetime datetime2(7) NULL,
	Remarks varchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Status varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT PK__Orders__3214EC07A2456472 PRIMARY KEY (OrderId),
	CONSTRAINT FK__Orders__UserId__7D439ABD FOREIGN KEY (UserId) REFERENCES isad251_2019_db_stud_19.dbo.Users(UserId)
) GO;

-- Drop table

-- DROP TABLE isad251_2019_db_stud_19.dbo.OrderProducts GO

CREATE TABLE isad251_2019_db_stud_19.dbo.OrderProducts (
	OrderProductId varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	OrderId varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	ProductId varchar(64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	Quantity int NULL,
	SubTotalPrice decimal(10,2) NULL,
	CONSTRAINT PK__OrderPro__3214EC07CA878798 PRIMARY KEY (OrderProductId),
	CONSTRAINT FK__OrderProd__Order__7E37BEF6 FOREIGN KEY (OrderId) REFERENCES isad251_2019_db_stud_19.dbo.Orders(OrderId),
	CONSTRAINT FK__OrderProd__Produ__7F2BE32F FOREIGN KEY (ProductId) REFERENCES isad251_2019_db_stud_19.dbo.Products(ProductId)
) GO;

CREATE TRIGGER tgr_updatedatetime
ON Users
AFTER UPDATE AS
  UPDATE Users
  SET UpdateDatetime = GETDATE()
  WHERE UserId IN (SELECT DISTINCT UserId FROM Inserted);

CREATE TRIGGER tgr_updatedatetime2
ON Products
AFTER UPDATE AS
  UPDATE Products
  SET UpdateDatetime = GETDATE()
  WHERE ProductId IN (SELECT DISTINCT ProductId FROM Inserted);

CREATE TRIGGER tgr_updatedatetime3
ON Orders
AFTER UPDATE AS
  UPDATE Orders
  SET UpdateDatetime = GETDATE()
  WHERE OrderId IN (SELECT DISTINCT OrderId FROM Inserted);
