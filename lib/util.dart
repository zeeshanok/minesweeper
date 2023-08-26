import 'dart:io';

import 'package:flutter/foundation.dart';

bool isDesktop() =>
    kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
