namespace TravelWorld.Desktop.Models;

public sealed class Permission
{
    public int PermissionId { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
}
