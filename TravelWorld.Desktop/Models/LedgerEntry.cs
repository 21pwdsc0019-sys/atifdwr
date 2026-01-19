using System;

namespace TravelWorld.Desktop.Models;

public sealed class LedgerEntry
{
    public long LedgerId { get; set; }
    public int AccountId { get; set; }
    public DateTime TxnDate { get; set; }
    public decimal Debit { get; set; }
    public decimal Credit { get; set; }
    public string CurrencyCode { get; set; } = "SAR";
    public string? Reference { get; set; }
    public string? Description { get; set; }
    public int CreatedBy { get; set; }
}
