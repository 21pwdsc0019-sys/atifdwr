namespace TravelWorld.Desktop.Models;

public sealed class CustomerAccount
{
    public int AccountId { get; set; }
    public int CustomerId { get; set; }
    public string CurrencyCode { get; set; } = "SAR";
    public bool IsActive { get; set; }
}
