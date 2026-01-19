using System.Threading.Tasks;

namespace TravelWorld.Desktop.Services;

public sealed class LedgerService
{
    public Task<decimal> GetCustomerBalanceAsync(int customerId)
    {
        return Task.FromResult(0m);
    }
}
