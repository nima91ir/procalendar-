import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:fitness_trainer_app/core/database/database_open_failure.dart';

/// Opens the browser database, and refuses to run without anywhere to keep it.
///
/// drift probes the browser and, when it cannot reach IndexedDB or the drift
/// worker, silently hands back a database that lives in memory only. It reports
/// that in [WasmDatabaseResult.chosenImplementation] and `.missingFeatures` —
/// both of which this file used to discard, returning an executor that looked
/// perfectly healthy. A live user hit exactly that: they backgrounded the app
/// while it was still opening, came back to a normal-looking app with zero
/// data, and their real database was in IndexedDB the whole time. Everything
/// they typed in that session existed only in memory. drift's own docs say to
/// warn the user when persistence matters, which is what this does.
///
/// The failure is normally transient — a worker that did not come up during a
/// slow or backgrounded boot — so this retries once. That case recovers
/// silently: no error screen, no lost work. Only a persistent failure reaches
/// the user, as an explanation instead of an empty calendar.
Future<QueryExecutor> createExecutor() async {
  var result = await _open();

  if (_storesNothing(result)) {
    result = await _open();
  }

  if (_storesNothing(result)) {
    throw PersistentStorageUnavailable(
      result.missingFeatures.map((feature) => feature.name).join(', '),
    );
  }

  return result.resolvedExecutor;
}

Future<WasmDatabaseResult> _open() {
  return WasmDatabase.open(
    databaseName: 'fitness_trainer',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  );
}

/// Whether the chosen implementation forgets everything when the tab closes.
///
/// Only [WasmStorageImplementation.inMemory] counts. `unsafeIndexedDb` is the
/// other one drift flags as unreliable, but it only risks races between
/// multiple open tabs and does persist — refusing to start on it would break
/// users whose browser legitimately picks it.
bool _storesNothing(WasmDatabaseResult result) =>
    result.chosenImplementation == WasmStorageImplementation.inMemory;
