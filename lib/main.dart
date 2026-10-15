import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import 'theme/app_theme.dart';
import 'providers/erp_provider.dart';
import 'screens/auth/login_screen.dart';
import 'services/native_home_widget_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style to match minimalist theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF5F6F7),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ErpProvider()),
      ],
      child: const DigitalInertiaErpApp(),
    ),
  );
}

/// Root Application Widget for Digital Inertia CEO Mobile ERP
class DigitalInertiaErpApp extends StatefulWidget {
  const DigitalInertiaErpApp({super.key});

  @override
  State<DigitalInertiaErpApp> createState() => _DigitalInertiaErpAppState();
}

class _DigitalInertiaErpAppState extends State<DigitalInertiaErpApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // 1. Prime the native home screen widget with live ERP data on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final erp = Provider.of<ErpProvider>(context, listen: false);
          NativeHomeWidgetService.syncToNativeWidgets(erp);
        } catch (_) {}
      }
    });

    // 2. Listen for home widget clicks while app is warm/resumed
    HomeWidget.widgetClicked.listen((Uri? uri) {
      if (uri != null) {
        _handleWidgetUri(uri);
      }
    });

    // 3. Check if app was cold-launched from home widget
    HomeWidget.initiallyLaunchedFromHomeWidget().then((Uri? uri) {
      if (uri != null) {
        _handleWidgetUri(uri);
      }
    });
  }

  void _handleWidgetUri(Uri uri) {
    debugPrint('[HomeWidget] Launch request received: $uri');
    final erp = Provider.of<ErpProvider>(context, listen: false);

    if (uri.host == 'sync' || uri.path.contains('sync')) {
      NativeHomeWidgetService.syncToNativeWidgets(erp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Digital Inertia CEO ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const LoginScreen(),
    );
  }
}

