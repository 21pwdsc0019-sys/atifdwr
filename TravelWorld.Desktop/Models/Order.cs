using System;

namespace TravelWorld.Desktop.Models;

public sealed class Order
{
    public int OrderId { get; set; }
    public string OrderCode { get; set; } = string.Empty;
    public DateTime OrderDate { get; set; }
    public int CustomerId { get; set; }
    public string ReceiverName { get; set; } = string.Empty;
    public string ReceiverMobile { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public decimal Charges { get; set; }
    public string PaymentMode { get; set; } = string.Empty;
    public string Status { get; set; } = "Open";
    public int ExternalBranchId { get; set; }
    public int InternalBranchId { get; set; }
    public int SubBranchId { get; set; }
    public string? Remarks { get; set; }
    public int CreatedBy { get; set; }
}
