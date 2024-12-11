part of 'image_bloc.dart';

abstract class ImageGenerationEvent extends Equatable {
  const ImageGenerationEvent();

  @override
  List<Object?> get props => [];
}

class GenerateImageEvent extends ImageGenerationEvent {
  final String prompt;

  const GenerateImageEvent(this.prompt);

  @override
  List<Object?> get props => [prompt];
}

class ImageResetEvent extends ImageGenerationEvent {}

class ImageDownloadEvent extends ImageGenerationEvent {
  final Uint8List imageBytes;

  const ImageDownloadEvent(this.imageBytes);

  @override
  List<Object> get props => [imageBytes];
}

class ImageShareEvent extends ImageGenerationEvent {
  final Uint8List imageBytes;

  const ImageShareEvent({required this.imageBytes});
}