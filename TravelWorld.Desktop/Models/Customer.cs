namespace TravelWorld.Desktop.Models;

public sealed class Customer
{
    public int CustomerId { get; set; }
    public int CustomerCode { get; set; }
    public string CustomerPublicId { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Mobile { get; set; } = string.Empty;
    public string? CnicOrPassport { get; set; }
    public string? Address { get; set; }
    public bool IsActive { get; set; }
}
