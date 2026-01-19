namespace TravelWorld.Desktop.Models;

public sealed class User
{
    public int UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}
