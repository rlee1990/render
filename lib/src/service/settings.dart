abstract class RenderSettings {
  /// The pixelRatio describes the scale between the logical pixels and the size
  /// of images or video frames captured. Specifying 1.0 will give you a 1:1
  /// mapping between logical pixels and the output pixels in the image.
  ///
  /// See [RenderRepaintBoundary](https://api.flutter.dev/flutter/rendering/RenderRepaintBoundary/toImage.html)
  /// for the underlying implementation.
  final double pixelRatio;

  /// The time out for processing captures. Note that the process timeout is not
  /// related to the whole process, but rather to each FFmpeg execution.
  /// Meaning that if there are many sub calculations in the format
  /// the timeout will only trigger for each operation.
  final Duration processTimeout;

  /// A data class for storing render related settings.
  const RenderSettings({
    this.pixelRatio = 3,
    this.processTimeout = const Duration(minutes: 3),
  });

  bool get isImage => this is ImageSettings;

  bool get isMotion => this is MotionSettings;

  MotionSettings? get asMotion => isMotion ? this as MotionSettings : null;

  ImageSettings? get asImage => isImage ? this as ImageSettings : null;
}

class ImageSettings extends RenderSettings {
  ///Settings for rendering an image.
  const ImageSettings({
    super.pixelRatio,
    super.processTimeout,
  });
}

class MotionSettings extends RenderSettings {
  /// Frames per second
  /// The amount of frames that should be captured in capturing process.
  /// This frame rate is subject to slightly adjust according duration of
  /// rendering and is limited by the frame rate of the application (normal frame
  /// rate should be at about 60 FPS). Any higher frame rate than the
  /// application itself is not possible and will be capped to the application
  /// one.
  ///
  /// ! This frame rate therefore does not necessary equal to output file frame rate
  final int frameRate;

  /// The max amount of capture handlers that should process captures at once.
  ///
  /// Handlers process and write frames from the RAM to a local directory.
  /// Having multiple handlers at the same time heavily influences the
  /// performance of the application during rendering.
  ///
  /// The more handlers are running simultaneously the worse gets the framerate
  /// and might result in a "laggy" behavior. Less simultaneously handlers result
  /// in longer loading phases.
  ///
  /// Note, that if there a lot of unhandled frames it might still result in
  /// laggy behavior, as the application's RAM gets filled with UI images,
  /// instead of many handler operations.
  ///
  /// To get a good sweet spot you can follow the following introduction for
  /// your specific situation:
  ///
  /// Low pixelRatio - high frameRate - many handlers
  /// high pixelRatio - low frameRate - many handlers
  /// high pixelRatio - high frameRate - few handlers
  final int simultaneousCaptureHandlers;

  /// Data class for storing render related settings.
  /// Setting the optimal settings is critical for a successfully capturing.
  /// Depending on the device different frame rate and capturing quality might
  /// result in a laggy application and render results. To prevent this
  /// it is important find leveled values and optionally computational scaling
  /// of the output format.
  const MotionSettings({
    this.simultaneousCaptureHandlers = 10,
    this.frameRate = 20,
    super.pixelRatio,
    super.processTimeout,
  }) : assert(frameRate < 100, "Frame rate unrealistic high.");
}

class RealRenderSettings extends RenderSettings {
  /// The duration of the capturing.
  final Duration capturingDuration;

  /// The amount of frames that are captured.
  final int frameAmount;

  /// The settings after capturing. This class hold the actual frame rate and and
  /// duration and might vary slightly from targeted settings.
  const RealRenderSettings({
    required super.pixelRatio,
    required super.processTimeout,
    required this.capturingDuration,
    required this.frameAmount,
  });

  /// In frames per second
  double get realFrameRate =>
      frameAmount / (capturingDuration.inMilliseconds / 1000);
}
