import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/platform/file_transfer.dart';

/// Signature of [saveTextFile], lifted into a type so it can be substituted.
typedef TextFileSaver = Future<String?> Function(
  String fileName,
  String contents,
);

/// Indirection over [saveTextFile].
///
/// This exists so the destructive-restore safety net in the import screen can
/// be tested: a widget test runs on the VM, where `file_transfer.dart` resolves
/// to the *native* implementation and `getApplicationDocumentsDirectory()` has
/// no platform channel to answer it, so every save would fail there.
///
/// Overriding this never changes production behaviour — it just makes the save
/// observable, failable, and therefore testable.
final textFileSaverProvider = Provider<TextFileSaver>((ref) => saveTextFile);
