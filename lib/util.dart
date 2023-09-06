import 'package:flutter/foundation.dart';

final _isDesktop = <TargetPlatform>{
  TargetPlatform.linux,
  TargetPlatform.macOS,
  TargetPlatform.windows,
}.contains(defaultTargetPlatform);

bool isDesktop() => _isDesktop;
