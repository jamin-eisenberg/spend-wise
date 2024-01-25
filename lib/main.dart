import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'bucket.dart';
import 'buckets_page.dart';
import 'expenses_page.dart';
import 'home_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => SpendWise()),
  ));
}

_router(buckets) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            Consumer<ApplicationState>(builder: (context, appState, _) {
          if (appState.loggedIn) {
            return HomePage([
              ExpensesPage(possibleBuckets: buckets),
              BucketsPage(buckets: buckets)
            ]);
          } else {
            return Scaffold(
              body: ElevatedButton(onPressed: () => context.push("/sign-in"), child: const Text("Sign in")),
            );
          }
        }),
        routes: [
          GoRoute(
            path: 'sign-in',
            builder: (context, state) {
              return SignInScreen(
                actions: [
                  ForgotPasswordAction(((context, email) {
                    final uri = Uri(
                      path: '/sign-in/forgot-password',
                      queryParameters: <String, String?>{
                        'email': email,
                      },
                    );
                    context.push(uri.toString());
                  })),
                  AuthStateChangeAction(((context, state) {
                    final user = switch (state) {
                      SignedIn state => state.user,
                      UserCreated state => state.credential.user,
                      _ => null
                    };
                    if (user == null) {
                      return;
                    }
                    if (state is UserCreated) {
                      user.updateDisplayName(user.email!.split('@')[0]);
                    }
                    if (!user.emailVerified) {
                      user.sendEmailVerification();
                      const snackBar = SnackBar(
                          content: Text(
                              'Please check your email to verify your email address'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    context.pushReplacement('/');
                  })),
                ],
              );
            },
            routes: [
              GoRoute(
                path: 'forgot-password',
                builder: (context, state) {
                  final arguments = state.uri.queryParameters;
                  return ForgotPasswordScreen(
                    email: arguments['email'],
                    headerMaxExtent: 200,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) {
              return ProfileScreen(
                providers: const [],
                actions: [
                  SignedOutAction((context) {
                    context.pushReplacement('/');
                  }),
                ],
              );
            },
          ),
        ],
      ),
    ],
  );
}

class SpendWise extends StatelessWidget {
  final buckets = [
    Bucket(bucketName: "House", iconData: Icons.house),
    Bucket(bucketName: "Wedding", iconData: Icons.favorite),
    Bucket(bucketName: "Vacation", iconData: Icons.flight_takeoff),
    Bucket(bucketName: "Car Savings/Repairs", iconData: Icons.car_repair),
    Bucket(bucketName: "Car Insurance", iconData: Icons.health_and_safety),
    Bucket(bucketName: "Car Taxes", iconData: Icons.gavel),
    Bucket(bucketName: "Invisalign", iconData: Icons.bluetooth_disabled),
    Bucket(bucketName: "Emergency Fund", iconData: Icons.emergency),
    Bucket(bucketName: "Retirement (Roth IRA)", iconData: Icons.elderly),
    Bucket(bucketName: "Charity", iconData: Icons.volunteer_activism),
  ];

  SpendWise({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SpendWise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router(buckets),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }
}
