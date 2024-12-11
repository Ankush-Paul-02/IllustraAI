class TextToImageException implements Exception {
  final String message;

  TextToImageException(this.message);

  @override
  String toString() => 'TextToImageException: $message';
}
