import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illustra_ai/service/exception/text_to_image_exception.dart';
import 'package:illustra_ai/service/text_to_image_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

part 'image_event.dart';

part 'image_state.dart';

class ImageGenerationBloc
    extends Bloc<ImageGenerationEvent, ImageGenerationState> {
  final TextToImageService textToImageService;

  ImageGenerationBloc({required this.textToImageService})
      : super(ImageGenerationInitial()) {
    on<GenerateImageEvent>(_onGenerateImage);
    on<ImageResetEvent>(_onImageReset);
    on<ImageDownloadEvent>(_onImageDownload);
    on<ImageShareEvent>(_shareImage);
  }

  FutureOr<void> _onGenerateImage(
    GenerateImageEvent event,
    Emitter<ImageGenerationState> emit,
  ) async {
    if (event.prompt.trim().isEmpty) {
      emit(const ImageGenerationFailure('Please enter a valid prompt!'));
      return;
    }

    emit(ImageGenerationLoading());

    try {
      final imageBytes =
          await textToImageService.generateImage(event.prompt.trim());
      emit(ImageGenerationSuccess(imageBytes));
    } catch (e) {
      String errorMessage = "An unexpected error occurred!";

      if (e is TextToImageException) {
        errorMessage = "Network error, please check your connection.";
      } else if (e is TimeoutException) {
        errorMessage = "The request timed out, please try again later.";
      } else if (e is Exception) {
        errorMessage = "Failed to generate image. Please try again.";
      }

      emit(ImageGenerationFailure(errorMessage));
    }
  }

  FutureOr<void> _onImageReset(
    ImageResetEvent event,
    Emitter<ImageGenerationState> emit,
  ) {
    emit(ImageGenerationInitial());
  }

  FutureOr<void> _onImageDownload(
    ImageDownloadEvent event,
    Emitter<ImageGenerationState> emit,
  ) async {
    try {
      // Check permissions for saving images
      bool hasPermission = await _checkPermissions();
      if (!hasPermission) {
        emit(const ImageGenerationFailure("Permission denied to save image."));
        return;
      }

      // Retrieve the generated image bytes
      final imageBytes =
          event.imageBytes; // Assuming imageBytes are passed in the event
      const imageName = "generated_image.png"; // Customize as needed

      // Save the image to the gallery
      var saveResult = await SaverGallery.saveImage(
        imageBytes,
        quality: 80, // Adjust quality if necessary
        fileName: imageName,
        androidRelativePath: "Pictures/GeneratedImages", // Path on Android
        skipIfExists: true, // Skip if the image already exists
      );

      // Check if the save operation was successful
      // If the image is saved successfully, pass success state
      emit(const ImageGenerationDownloadSuccess("Image saved successfully!"));
    } catch (e) {
      // Handle any unexpected errors
      emit(ImageGenerationFailure("Failed to download image: $e"));
    }
  }

  Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      final permissionStatus = await Permission.photos.request();
      return permissionStatus.isGranted;
    } else if (Platform.isIOS) {
      final permissionStatus = await Permission.photosAddOnly.request();
      return permissionStatus.isGranted;
    }
    return false;
  }

  Future<void> _shareImage(
      ImageShareEvent event,
      Emitter<ImageGenerationState> emit,
      ) async {
    try {
      // Save the image to a temporary file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/generated_image.png';
      final file = File(filePath);

      // Write the image bytes to the file
      await file.writeAsBytes(event.imageBytes);

      // Create an XFile from the file path
      final xFile = XFile(file.path);

      // Share the image using the shareXFiles method
      await Share.shareXFiles([xFile], text: 'Check out this generated image!');

      // Emit a success state
      emit(const ImageGenerationShareSuccess("Image shared successfully!"));
    } catch (e) {
      emit(ImageGenerationFailure("Failed to share image: $e"));
    }
  }
}
