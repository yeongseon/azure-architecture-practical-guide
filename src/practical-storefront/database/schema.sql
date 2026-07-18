IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
GO

CREATE TABLE dbo.Products
(
    Id          INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Products PRIMARY KEY,
    Name        NVARCHAR(200)     NOT NULL,
    Description NVARCHAR(1000)    NOT NULL CONSTRAINT DF_Products_Description DEFAULT (''),
    Price       DECIMAL(18,2)     NOT NULL
);
GO

CREATE TABLE dbo.Orders
(
    Id           INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerName NVARCHAR(200)     NOT NULL,
    ProductId    INT               NOT NULL,
    Quantity     INT               NOT NULL CONSTRAINT DF_Orders_Quantity DEFAULT (1),
    CreatedAt    DATETIME2         NOT NULL CONSTRAINT DF_Orders_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Orders_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products (Id)
);
GO

CREATE INDEX IX_Orders_CreatedAt ON dbo.Orders (CreatedAt DESC);
GO
