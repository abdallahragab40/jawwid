import 'package:flutter/material.dart';

import 'app/bootstrap.dart';
import 'app/licenses.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerBundledLicenses();
  runApp(const AppBootstrap());
}
