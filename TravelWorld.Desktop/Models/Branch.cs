namespace TravelWorld.Desktop.Models;

public sealed class Branch
{
    public int BranchId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public int? ParentBranchId { get; set; }
}
