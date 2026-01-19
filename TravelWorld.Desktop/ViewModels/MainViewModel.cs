using System.Windows.Controls;
using TravelWorld.Desktop.Views;

namespace TravelWorld.Desktop.ViewModels;

public sealed class MainViewModel : ViewModelBase
{
    private UserControl _currentView;

    public MainViewModel()
    {
        ShowDashboardCommand = new RelayCommand(() => CurrentView = new DashboardView());
        ShowCustomersCommand = new RelayCommand(() => CurrentView = new CustomersView());
        ShowOrdersCommand = new RelayCommand(() => CurrentView = new OrdersView());
        ShowLedgerCommand = new RelayCommand(() => CurrentView = new LedgerView());
        ShowReportsCommand = new RelayCommand(() => CurrentView = new ReportsView());
        ShowSettingsCommand = new RelayCommand(() => CurrentView = new SettingsView());

        _currentView = new DashboardView();
    }

    public UserControl CurrentView
    {
        get => _currentView;
        set
        {
            _currentView = value;
            OnPropertyChanged();
        }
    }

    public RelayCommand ShowDashboardCommand { get; }
    public RelayCommand ShowCustomersCommand { get; }
    public RelayCommand ShowOrdersCommand { get; }
    public RelayCommand ShowLedgerCommand { get; }
    public RelayCommand ShowReportsCommand { get; }
    public RelayCommand ShowSettingsCommand { get; }
}
