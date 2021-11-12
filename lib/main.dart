import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:reaxit/blocs/album_list_cubit.dart';
import 'package:reaxit/blocs/auth_bloc.dart';
import 'package:reaxit/blocs/calendar_cubit.dart';
import 'package:reaxit/blocs/full_member_cubit.dart';
import 'package:reaxit/blocs/member_list_cubit.dart';
import 'package:reaxit/blocs/payment_user_cubit.dart';
import 'package:reaxit/blocs/setting_cubit.dart';
import 'package:reaxit/blocs/theme_bloc.dart';
import 'package:reaxit/blocs/welcome_cubit.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/push_notifications.dart';
import 'package:reaxit/routes.dart';
import 'package:reaxit/theme.dart';
import 'package:reaxit/ui/widgets/error_center.dart';
import 'package:reaxit/ui/widgets/push_notification_dialog.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SentryFlutter.init(
    (options) {
      options.dsn = config.sentryDSN;
    },
    appRunner: () async {
      runApp(BlocProvider(
        create: (_) => ThemeBloc()..add(ThemeLoadEvent()),
        lazy: false,
        child: BlocProvider(
          create: (context) => AuthBloc()..add(LoadAuthEvent()),
          lazy: false,
          child: ThaliApp(),
        ),
      ));
    },
  );
}

class ThaliApp extends StatefulWidget {
  @override
  _ThaliAppState createState() => _ThaliAppState();
}

class _ThaliAppState extends State<ThaliApp> {
  final _firebaseInitialization = Firebase.initializeApp();

  late final AuthBloc _authBloc;
  late final GoRouter _router;

  /// Setup push notification handlers.
  Future<void> _setupFirebaseMessaging() async {
    // Make sure firebase has been initialized.
    await _firebaseInitialization;

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Channel for in-app notifications.
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'in-app-notifications',
      'In-App Notifications',
      importance: Importance.max,
    );

    // Create a channel for push notifications. Notifications on this
    // channel will be displayed even when the app is in the foreground.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // User got a push notification while the app is running.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Create a notification for the max priority channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
            ),
          ),
        );
      }
    });

    // User clicked on push notification with the app in the background.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.data.containsKey('url') && message.data['url'] is String) {
        final uri = Uri.tryParse(message.data['url'] as String);
        if (uri != null && await canLaunch(uri.toString())) {
          await launch(uri.toString(), forceSafariVC: false);
        }
      } else {
        // Show a dialog if the notification doesn't have a url.
        final navContext = _router.routerDelegate.navigatorKey.currentContext;
        if (navContext != null) {
          showDialog(
            context: navContext,
            builder: (_) => PushNotificationDialog(message),
          );
        }
      }
    });

    // User clicked notification while the app was terminated.
    if (initialMessage != null) {
      final message = initialMessage;
      if (message.data.containsKey('url') && message.data['url'] is String) {
        final uri = Uri.tryParse(message.data['url'] as String);
        if (uri != null && await canLaunch(uri.toString())) {
          await launch(uri.toString(), forceSafariVC: false);
        }
      } else {
        // Show a dialog if the notification doesn't have a url.
        final navContext = _router.routerDelegate.navigatorKey.currentContext;
        if (navContext != null) {
          showDialog(
            context: navContext,
            builder: (_) => PushNotificationDialog(message),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _router = GoRouter(
      routes: routes,
      errorPageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: Scaffold(body: ErrorCenter(state.error.toString())),
      ),
      redirect: (GoRouterState state) {
        final loggedIn = _authBloc.state is LoggedInAuthState;
        final goingToLogin = state.location.startsWith('/login');

        if (!loggedIn && !goingToLogin) {
          return Uri(path: '/login', queryParameters: {
            'from': state.location,
          }).toString();
        } else if (loggedIn && goingToLogin) {
          return Uri.parse(state.location).queryParameters['from'] ?? '/';
        } else {
          return null;
        }
      },
      observers: [SentryNavigatorObserver()],
      refreshListenable: _authBloc,
      navigatorBuilder: (context, navigator) {
        return BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (previous, current) {
            if (previous is LoggedInAuthState &&
                current is LoggedOutAuthState) {
              return true;
            } else if (previous is LoggingInAuthState &&
                current is LoggedInAuthState) {
              return true;
            } else if (current is FailureAuthState) {
              return true;
            }
            return false;
          },

          // Listen to display snackbars with login status.
          listener: (context, state) {
            if (state is LoggedOutAuthState) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Logged out.'),
              ));
            } else if (state is LoggedInAuthState) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Logged in.'),
              ));
            } else if (state is FailureAuthState) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(state.message ?? 'Logging in failed.'),
              ));
            }
          },

          // Build with Blocs provided when logged in.
          builder: (context, authState) {
            if (authState is LoggedInAuthState) {
              return RepositoryProvider.value(
                value: authState.apiRepository,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) => PaymentUserCubit(
                        authState.apiRepository,
                      )..load(),
                      lazy: false,
                    ),
                    BlocProvider(
                      create: (_) => FullMemberCubit(
                        authState.apiRepository,
                      )..load(),
                      lazy: false,
                    ),
                    BlocProvider(
                      create: (_) => WelcomeCubit(
                        authState.apiRepository,
                      )..load(),
                      lazy: false,
                    ),
                    BlocProvider(
                      create: (_) => CalendarCubit(
                        authState.apiRepository,
                      )..load(),
                      lazy: false,
                    ),
                    BlocProvider(
                      create: (_) => MemberListCubit(
                        authState.apiRepository,
                      )..load(),
                      lazy: false,
                    ),
                    BlocProvider(
                      create: (_) => AlbumListCubit(
                        authState.apiRepository,
                      )..load(),
                      lazy: false,
                    ),
                    BlocProvider(
                      create: (_) => SettingsCubit(
                        authState.apiRepository,
                        _firebaseInitialization,
                      )..load(),
                      lazy: false,
                    ),
                  ],
                  child: BlocListener<AuthBloc, AuthState>(
                    // Listen for setting up pushnotifications.
                    listener: (context, authState) async {
                      if (authState is LoggedInAuthState) {
                        // Make sure firebase has been initialized.
                        await _firebaseInitialization;

                        // Setup push notifications with the api.
                        await registerPushNotifications(
                          authState.apiRepository,
                        );

                        // Update tokens to the api when they are refreshed.
                        FirebaseMessaging.instance.onTokenRefresh.listen(
                          (String token) => registerPushNotificationsToken(
                            authState.apiRepository,
                            token,
                          ),
                        );
                      }
                    },
                    child: navigator!,
                  ),
                ),
              );
            } else {
              return navigator!;
            }
          },
        );
      },
    );
    _setupFirebaseMessaging();
  }

  /// This key prevents initializing a new [MaterialApp] state and, through
  /// that, a new [Router] state, that would otherwise unintentionally make
  /// an additional call to [ThaliaRouterDelegate.setInitialRoutePath] on
  /// authentication events.
  final _materialAppKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          key: _materialAppKey,
          title: 'ThaliApp',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          routerDelegate: _router.routerDelegate,
          routeInformationParser: _router.routeInformationParser,
        );
      },
    );
  }
}
