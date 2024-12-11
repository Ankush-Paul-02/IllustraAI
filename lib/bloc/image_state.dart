part of 'image_bloc.dart';

abstract class ImageGenerationState extends Equatable {
  const ImageGenerationState();

  @override
  List<Object?> get props => [];
}

class ImageGenerationInitial extends ImageGenerationState {}

class ImageGenerationLoading extends ImageGenerationState {}

class ImageGenerationSuccess extends ImageGenerationState {
  final Uint8List imageBytes;

  const ImageGenerationSuccess(this.imageBytes);

  @override
  List<Object?> get props => [imageBytes];
}

class ImageGenerationFailure extends ImageGenerationState {
  final String error;

  const ImageGenerationFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ImageGenerationDownloadSuccess extends ImageGenerationState {
  final String filePath;

  const ImageGenerationDownloadSuccess(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class ImageGenerationShareSuccess extends ImageGenerationState {
  final String message;

  const ImageGenerationShareSuccess(this.message);

  @override
  List<Object?> get props => [message];
}