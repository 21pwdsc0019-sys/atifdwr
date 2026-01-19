CREATE PROCEDURE spCreateCustomer
    @FullName NVARCHAR(150),
    @Mobile NVARCHAR(20),
    @CNIC NVARCHAR(30),
    @Address NVARCHAR(250),
    @Status BIT,
    @CreatedBy INT,
    @OpeningType NVARCHAR(10),
    @OpeningAmount DECIMAL(18,2),
    @OpeningDate DATETIME2,
    @OpeningRemarks NVARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CustomerCode INT = ISNULL((SELECT MAX(CustomerCode) FROM Customers), 0) + 1;

    INSERT INTO Customers (CustomerCode, FullName, Mobile, CNIC, Address, Status, CreatedBy)
    VALUES (@CustomerCode, @FullName, @Mobile, @CNIC, @Address, @Status, @CreatedBy);

    DECLARE @CustomerId INT = SCOPE_IDENTITY();

    INSERT INTO CustomerAccounts (CustomerId)
    VALUES (@CustomerId);

    IF @OpeningType IN ('Credit', 'Debit') AND @OpeningAmount > 0
    BEGIN
        DECLARE @AccountId INT = (SELECT AccountId FROM CustomerAccounts WHERE CustomerId = @CustomerId);
        INSERT INTO LedgerEntries (AccountId, TxnDate, Debit, Credit, Reference, Description, CreatedBy)
        VALUES (
            @AccountId,
            @OpeningDate,
            CASE WHEN @OpeningType = 'Debit' THEN @OpeningAmount ELSE 0 END,
            CASE WHEN @OpeningType = 'Credit' THEN @OpeningAmount ELSE 0 END,
            'Customer Opening Balance',
            @OpeningRemarks,
            @CreatedBy
        );
    END
END;

CREATE PROCEDURE spCustomerTopUp
    @CustomerId INT,
    @Amount DECIMAL(18,2),
    @Remarks NVARCHAR(250),
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AccountId INT = (SELECT AccountId FROM CustomerAccounts WHERE CustomerId = @CustomerId);

    INSERT INTO LedgerEntries (AccountId, Credit, Reference, Description, CreatedBy)
    VALUES (@AccountId, @Amount, 'Customer Top-up', @Remarks, @UserId);
END;

CREATE PROCEDURE spCreateOrder
    @CustomerId INT,
    @ReceiverName NVARCHAR(150),
    @ReceiverMobile NVARCHAR(20),
    @Amount DECIMAL(18,2),
    @Charges DECIMAL(18,2),
    @PaymentMode NVARCHAR(20),
    @ExternalBranchId INT,
    @InternalBranchId INT,
    @SubBranchId INT,
    @Remarks NVARCHAR(250),
    @UserId INT,
    @AllowNegativeBalance BIT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OrderCode NVARCHAR(20) = CONCAT('TW-', FORMAT(GETDATE(), 'yyyyMMddHHmmss'));

    IF @PaymentMode = 'FromAccount' AND @AllowNegativeBalance = 0
    BEGIN
        DECLARE @AccountId INT = (SELECT AccountId FROM CustomerAccounts WHERE CustomerId = @CustomerId);
        DECLARE @CurrentBalance DECIMAL(18,2) = (
            SELECT ISNULL(SUM(Credit) - SUM(Debit), 0) FROM LedgerEntries WHERE AccountId = @AccountId
        );
        DECLARE @Total DECIMAL(18,2) = @Amount + @Charges;

        IF @CurrentBalance < @Total
        BEGIN
            RAISERROR('Insufficient balance for From Account order.', 16, 1);
            RETURN;
        END
    END

    INSERT INTO Orders (
        OrderCode, CustomerId, ReceiverName, ReceiverMobile, Amount, Charges, PaymentMode,
        ExternalBranchId, InternalBranchId, SubBranchId, Remarks, CreatedBy
    )
    VALUES (
        @OrderCode, @CustomerId, @ReceiverName, @ReceiverMobile, @Amount, @Charges, @PaymentMode,
        @ExternalBranchId, @InternalBranchId, @SubBranchId, @Remarks, @UserId
    );

    IF @PaymentMode = 'FromAccount'
    BEGIN
        DECLARE @AccountId2 INT = (SELECT AccountId FROM CustomerAccounts WHERE CustomerId = @CustomerId);
        DECLARE @Total2 DECIMAL(18,2) = @Amount + @Charges;
        INSERT INTO LedgerEntries (AccountId, Debit, Reference, Description, CreatedBy)
        VALUES (@AccountId2, @Total2, CONCAT('Order ', @OrderCode), @Remarks, @UserId);
    END
END;

CREATE PROCEDURE spCancelOrder
    @OrderId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PaymentMode NVARCHAR(20);
    DECLARE @CustomerId INT;
    DECLARE @Total DECIMAL(18,2);
    DECLARE @OrderCode NVARCHAR(20);

    SELECT
        @PaymentMode = PaymentMode,
        @CustomerId = CustomerId,
        @Total = Amount + Charges,
        @OrderCode = OrderCode
    FROM Orders
    WHERE OrderId = @OrderId;

    UPDATE Orders SET Status = 'Cancelled' WHERE OrderId = @OrderId;

    IF @PaymentMode = 'FromAccount'
    BEGIN
        DECLARE @AccountId INT = (SELECT AccountId FROM CustomerAccounts WHERE CustomerId = @CustomerId);
        INSERT INTO LedgerEntries (AccountId, Credit, Reference, Description, CreatedBy)
        VALUES (@AccountId, @Total, CONCAT('Cancel Order ', @OrderCode), 'Reversal', @UserId);
    END
END;
