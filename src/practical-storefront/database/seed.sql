IF NOT EXISTS (SELECT 1 FROM dbo.Products)
BEGIN
    INSERT INTO dbo.Products (Name, Description, Price) VALUES
        (N'Practical Notebook', N'A5 dotted notebook for architects.', 12.50),
        (N'Cloud Sticker Pack', N'Set of 10 Azure service stickers.', 6.00),
        (N'Bicep T-Shirt',      N'Infrastructure-as-code themed tee.', 24.99),
        (N'Container Mug',      N'350ml ceramic mug with a whale.', 14.00);
END
GO
