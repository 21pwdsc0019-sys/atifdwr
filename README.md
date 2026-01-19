# Travel World – Remittance & Ledger Desktop System

This repository contains a WPF (C#) desktop application scaffold plus SQL Server schema and stored procedures for the Travel World remittance system.

## Solution layout
- `TravelWorld.Desktop/` – WPF application (MVVM scaffolding).
- `TravelWorld.Desktop/Sql/` – SQL Server schema + stored procedures.

## Database setup
1. Create a SQL Server database.
2. Run `TravelWorld.Desktop/Sql/schema.sql`.
3. Run `TravelWorld.Desktop/Sql/procedures.sql`.

## WPF app setup
1. Ensure .NET 6 SDK (Windows) is installed.
2. Open the solution in Visual Studio.
3. Update the connection string in the app settings (to be added in your environment).
4. Run the app.

## CI build
This repository includes a GitHub Actions workflow that restores and builds the WPF app on Windows runners.

## Next implementation steps
- Implement repositories and data services for each module.
- Wire WPF views to real ViewModels and services.
- Add login screen and role-based navigation.
- Build receipt template with RDLC.
