import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:illustra_ai/bloc/image_bloc.dart';
import 'package:illustra_ai/service/text_to_image_service.dart';

final GetIt locator = GetIt.instance;

void setUpLocator() {
  // Register services
  locator.registerLazySingleton<TextToImageService>(
    () => TextToImageService(
      apiUrl: dotenv.env['HUGGING_FACE_API_URL']! ,
      apiKey: dotenv.env['HUGGING_FACE_API_KEY']!,
    ),
  );

  // Register the bloc
  locator.registerFactory<ImageGenerationBloc>(
    () =>
        ImageGenerationBloc(textToImageService: locator<TextToImageService>()),
  );
}
