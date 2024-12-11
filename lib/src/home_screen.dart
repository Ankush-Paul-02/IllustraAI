import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:illustra_ai/bloc/image_bloc.dart';

import '../core/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final promptController = TextEditingController();
    final focusNode = FocusNode();

    return GestureDetector(
      onTap: () => focusNode.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.darkBackgroundColor,
          elevation: 0,
          title: Text(
            'IllustraAI',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 26,
            ),
          ),
          actions: [
            InkWell(
              onTap: () {
                context.read<ImageGenerationBloc>().add(ImageResetEvent());
                promptController.clear();
              },
              child: FaIcon(
                FontAwesomeIcons.refresh,
                color: AppColors.primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () {
                final state = context.read<ImageGenerationBloc>().state;
                if (state is ImageGenerationSuccess) {
                  context.read<ImageGenerationBloc>().add(
                    ImageShareEvent(imageBytes: state.imageBytes)
                  );
                } else {
                  // Show a message if no image has been generated
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No image found to share. Please generate an image first!',
                      ),
                    ),
                  );
                }
              },
              child: FaIcon(
                FontAwesomeIcons.share,
                color: AppColors.primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () {
                final state = context.read<ImageGenerationBloc>().state;
                if (state is ImageGenerationSuccess) {
                  context.read<ImageGenerationBloc>().add(
                        ImageDownloadEvent(state.imageBytes),
                      );
                } else {
                  // Show a message if no image has been generated
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No image found to download. Please generate an image first!',
                      ),
                    ),
                  );
                }
              },
              child: FaIcon(
                FontAwesomeIcons.download,
                color: AppColors.primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 20)
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your prompt',
                  style: TextStyle(color: AppColors.white, fontSize: 26),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greyColor.withOpacity(0.2),
                        offset: const Offset(2, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: promptController,
                    focusNode: focusNode,
                    maxLines: 7,
                    style: TextStyle(
                      color: AppColors.lightGreyColor,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.greyColor,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.greyColor,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                          width: 2.0,
                        ),
                      ),
                      hintText: 'Prompt...',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<ImageGenerationBloc, ImageGenerationState>(
                  builder: (context, state) {
                    if (state is ImageGenerationLoading) {
                      return Center(
                        child: SpinKitChasingDots(
                          color: AppColors.primaryColor,
                          size: 50.0,
                        ),
                      );
                    } else {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            final prompt = promptController.text.trim();
                            if (prompt.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid prompt!'),
                                ),
                              );
                              return;
                            }
                            context
                                .read<ImageGenerationBloc>()
                                .add(GenerateImageEvent(prompt));
                          },
                          child: Text(
                            state is ImageGenerationSuccess
                                ? 'Generated'
                                : 'Generate',
                            style: TextStyle(
                              fontSize: 20,
                              color: AppColors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<ImageGenerationBloc, ImageGenerationState>(
                  builder: (context, state) {
                    if (state is ImageGenerationSuccess) {
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.lightGreyColor.withOpacity(0.2),
                                offset: const Offset(2, 2),
                                blurRadius: 8,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              state.imageBytes,
                              height: 350,
                              width: 500,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    } else if (state is ImageGenerationFailure) {
                      return Center(
                        child: Text(
                          state.error,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
