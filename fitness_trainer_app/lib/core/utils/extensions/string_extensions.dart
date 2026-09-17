extension StringExt on String {
  bool get isValidInt => int.tryParse(this) != null;
  bool get isBlank => trim().isEmpty;
}
