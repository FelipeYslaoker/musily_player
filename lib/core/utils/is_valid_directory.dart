bool isValidDirectory(String input) {
  const directoryPattern = r'^(/[^/ ]*)+/?$';
  final directoryRegex = RegExp(directoryPattern);
  return directoryRegex.hasMatch(input);
}
