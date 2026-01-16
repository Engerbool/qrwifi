import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/editor_screen.dart';
import '../screens/preview_screen.dart';
import '../screens/canvas_editor_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String editor = '/editor';
  static const String preview = '/preview';
  static const String canvasEditor = '/canvas-editor';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    editor: (context) => const EditorScreen(),
    preview: (context) => const PreviewScreen(),
    canvasEditor: (context) => const CanvasEditorScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    return null;
  }
}
