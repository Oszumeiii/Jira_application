/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/JiraLogo.png
  AssetGenImage get jiraLogo =>
      const AssetGenImage('assets/images/JiraLogo.png');

  /// File path: assets/images/Logo.png
  AssetGenImage get logo => const AssetGenImage('assets/images/Logo.png');

  /// File path: assets/images/Logo2.png
  AssetGenImage get logo2 => const AssetGenImage('assets/images/Logo2.png');

  /// File path: assets/images/Vector.png
  AssetGenImage get vector => const AssetGenImage('assets/images/Vector.png');

  /// File path: assets/images/bell.png
  AssetGenImage get bell => const AssetGenImage('assets/images/bell.png');

  /// File path: assets/images/eyehide.png
  AssetGenImage get eyehide => const AssetGenImage('assets/images/eyehide.png');

  /// File path: assets/images/groupworking_img.jpg
  AssetGenImage get groupworkingImg =>
      const AssetGenImage('assets/images/groupworking_img.jpg');

  /// File path: assets/images/image.png
  AssetGenImage get image => const AssetGenImage('assets/images/image.png');

  /// File path: assets/images/onboard1.png
  AssetGenImage get onboard1 =>
      const AssetGenImage('assets/images/onboard1.png');

  /// File path: assets/images/onboard2.png
  AssetGenImage get onboard2 =>
      const AssetGenImage('assets/images/onboard2.png');

  /// File path: assets/images/onboard3.png
  AssetGenImage get onboard3 =>
      const AssetGenImage('assets/images/onboard3.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        jiraLogo,
        logo,
        logo2,
        vector,
        bell,
        eyehide,
        groupworkingImg,
        image,
        onboard1,
        onboard2,
        onboard3
      ];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
