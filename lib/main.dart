import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/user_list_bloc.dart';
import 'models/auth_state.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'config/zego_config.dart';

@pragma('vm:entry-point')
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authService: AuthService(),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => UserListBloc(
            userService: UserService(),
          ),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) async {
          if (authState is AuthAuthenticated) {
            await ZegoUIKitPrebuiltCallInvitationService().init(
              appID: ZegoConfig.appId,
              appSign: ZegoConfig.appSign,
              userID: authState.user.id,
              userName: '${authState.user.firstName} ${authState.user.lastName}',
              plugins: [ZegoUIKitSignalingPlugin()],
            );
          } else if (authState is AuthUnauthenticated) {
            try {
              await ZegoUIKitPrebuiltCallInvitationService().uninit();
            } catch (_) {}
          }
        },
        child: MyAppState(navigatorKey: navigatorKey),
      ),
    );
  }
}

class MyAppState extends StatefulWidget {
  const MyAppState({super.key, required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<MyAppState> createState() => _MyAppStateState();
}

class _MyAppStateState extends State<MyAppState> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ZegoUIKit().initLog();
      await ZegoUIKit().init(
        appID: ZegoConfig.appId,
        appSign: ZegoConfig.appSign,
      );
      ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(widget.navigatorKey);
      ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
        [ZegoUIKitSignalingPlugin()],
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return MaterialApp(
          title: 'Hipster Video',
          debugShowCheckedModeBanner: false,
          navigatorKey: widget.navigatorKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1), // Modern indigo
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFEFEFEF),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.all(8),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              labelStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                height: 1.2,
              ),
              headlineMedium: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                height: 1.3,
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
              labelLarge: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
          },
          initialRoute: authState is AuthAuthenticated ? '/home' : '/login',
          builder: (BuildContext context, Widget? child) {
            return Stack(
              children: [
                child!,
                /// support minimizing
                ZegoUIKitPrebuiltCallMiniOverlayPage(
                  contextQuery: () {
                    return widget.navigatorKey.currentState!.context;
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}