using System.Threading.Tasks;

namespace TravelWorld.Desktop.Services;

public sealed class AuthService
{
    public Task<bool> LoginAsync(string userName, string password)
    {
        return Task.FromResult(false);
    }
}
