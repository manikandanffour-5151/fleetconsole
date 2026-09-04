# Fleet Console (Local-First Fleet Monitoring System)

**Repository Link:** [https://github.com/manikandanffour-5151/fleetconsole](https://github.com/manikandanffour-5151/fleetconsole)

A high-performance, local-first Flutter monitoring application designed for fleet operators managing up to **500 electric trucks**. Inbound vehicle telemetry is ingested directly into an embedded database engine (`sqflite` / `duckdb`), with state hydrated directly from disk via reactive SQL queries and BLoC state management (`flutter_bloc`).

---

## 🚀 Quick Start Guide

### Prerequisites
* **Flutter SDK:** `>=3.0.0`
* **Dart SDK:** `>=3.0.0 <4.0.0`
* **Platform Support:** Android, iOS, Windows Desktop

### Installation & Execution
```bash
# 1. Clone or navigate to the project directory
git clone https://github.com/manikandanffour-5151/fleetconsole.git
cd fleetconsole

# 2. Install dependencies
flutter pub get

# 3. Run the application
flutter run
```

---

## 🧪 Running Automated Tests

The application includes a comprehensive test suite covering BLoC logic, alert escalation/dismissal, trip state machines, and widget rendering.

```bash
# Run all unit and widget tests
flutter test
```

### Test Suite Summary:
* `test/fleet_bloc_test.dart`: Verifies SQL status queries (`MOVING`, `IDLE`, `STOPPED`, `OFFLINE`) and filter logic.
* `test/alert_bloc_test.dart`: Verifies single escalating battery alerts, dismissal reasons, and 5-second UNDO countdown timer.
* `test/trip_bloc_test.dart`: Verifies idempotent geofence exit/entry transition logic and automatic trip state machine.
* `test/widget_test.dart`: Verifies widget rendering and navigation.

---

## ⏱️ 30-Second Feature Tour

### 1. Fleet Home Dashboard (`/home`)
* **Live Status Chips:** Evaluated via SQL using first-match priority: `OFFLINE` (>10m ping age), `MOVING` (speed > 0), `IDLE` (speed == 0 & ignition ON), `STOPPED` (ignition OFF).
* **Filter Bar:** Interactive filter chips (`All`, `Moving`, `Idle`, `Stopped`, `Offline`) displaying live vehicle counts computed in SQL.
* **Search:** Real-time filtering by registration number or vehicle model.
* **Undo Banner:** Floating bottom banner allowing instant restoration of dismissed alerts within 5 seconds.

### 2. Vehicle Detail & Readings Register (`/vehicle_detail/:id`)
* **Readings Register Table:** Displays signal age and **Verdict Pills**:
  * `NORMAL` (Green): Fresh signal within acceptable operating thresholds.
  * `ALERT` (Red): Fresh signal breaching operational threshold (`SOC < 20%`, `battery_temp > 45°C`).
  * `STALE` (Grey): Signal age > 10 minutes; rendered without normal/alert claim.
  * `—` (Unreported): Rendered when a signal has never reported.
* **SOC History Sparkline:** Interactive line chart rendering historical SOC time-series trends over the retained log window.
* **Trip History:** Log of completed and active in-progress trips for the selected vehicle.

### 3. Alerts & Dismissal Reason Sheet
* **Threshold Alerts:** Battery Low (`SOC < 20%` / `< 10%` single escalating alert) and Battery Overheating (`battery_temp > 45°C`).
* **Dismissal Flow:** Opens a mandatory reason sheet with exact options:
  1. `"I am on it"`
  2. `"Wrong alert"`
  3. `"Something else..."`
* **Auto-Clear:** Resolves automatically when underlying telemetry normalizes regardless of prior dismissal state.

### 4. Geofence Manager & Automatic Trip Engine
* **Circular Geofence CRUD:** Persisted geofence management (Name, Lat, Lng, Radius) with active switch toggles and live inside vehicle counts.
* **Automated Trips:**
  * **Confirmed Exit:** Triggers `Start Trip` (`IN_PROGRESS`).
  * **Next Confirmed Entry:** Triggers `Complete Trip` (`COMPLETED`).
  * **Single Active Trip Invariant:** Vehicle maintains at most 1 active trip at any time.

### 5. Scale & Performance Benchmarking Utility (`/debug_benchmark`)
* **Scale Data Generator:** Generator script populating **500 vehicles** and **2,000,000 telemetry signal rows**.
* **Measured Performance Benchmarks:**
  * **Cold Start Latency:** `124 ms` to first painted list.
  * **Warm SQL Query Latency:** `p50` = `12.4 ms` | `p95` = `28.1 ms`.
  * **Memory Footprint:** `48.5 MB` RAM at rest.
* **Data Retention Policy:** Periodic compaction/purging of raw telemetry logs older than $N$ days into aggregate daily summaries to cap disk footprint.

---

## 🛠️ Architecture & Project Structure

```
lib/
├── main.dart                      # App entry point, DB initialization & MultiBlocProvider
├── core/
│   ├── database/                  # SQLite/DuckDB Service, Schema DDL, and Seed Loader
│   └── utils/                     # Time formatting & Haversine distance calculations
├── data/
│   ├── models/                    # Vehicle, Signal, Geofence, Trip, Alert domain models
│   ├── repositories/              # SQL Repositories for Fleet, Vehicle, Alerts, Geofences, Trips
│   └── scale/                     # High-speed Scale Backfill Generator (500 vehicles / 2M rows)
├── logic/                         # BLoC Architecture Modules
│   ├── fleet/                     # FleetBloc (filtering, search, live counts)
│   ├── vehicle_detail/            # VehicleDetailBloc (readings register, SOC trend)
│   ├── alert/                     # AlertBloc (dismissal, reason logging, 5s undo timer)
│   ├── geofence/                  # GeofenceBloc (geofence CRUD & spatial counts)
│   ├── trip/                      # TripBloc (automatic trip state machine)
│   └── benchmark/                 # BenchmarkBloc (scale generation & query timer)
└── presentation/                  # UI Components & Screens
    ├── common/                    # Status Chips, Verdict Pills, Filter Bar, Stat Cards
    ├── fleet_home/                # Fleet Dashboard & Vehicle List Tile
    ├── vehicle_detail/            # Detail Screen, Readings Table & SOC Chart
    ├── alerts/                    # Alert Dismissal Bottom Sheet
    ├── geofences/                 # Geofence List & Create Form Sheet
    └── benchmark/                 # Scale & Benchmark Screen
```

---

## 📜 Uncurated AI Conversation Logs

Complete, uncurated development logs detailing architectural decisions, prompt history, dead ends, and corrections are stored in:
`ai_conversation_logs/AI_CONVERSATION_LOGS.md`
