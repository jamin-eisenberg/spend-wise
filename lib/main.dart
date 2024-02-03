import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'buckets_page.dart';
import 'expenses_page.dart';
import 'home_page.dart';

import 'months_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const SpendWise()),
  ));
}

_router() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            Consumer<ApplicationState>(builder: (context, appState, _) {
          if (appState.loggedIn) {
            return HomePage([
              ExpensesPage(
                  buckets: appState.buckets, expenses: appState.expenses),
              BucketsPage(buckets: appState.buckets),
              MonthsPage(
                expenses: appState.expenses,
                months: appState.months,
                buckets: appState.buckets,
              ),
            ]);
          } else {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                    onPressed: () => context.push("/sign-in"),
                    child: const Text("Sign in")),
              ),
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
  const SpendWise({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SpendWise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router(),
    );
  }
}
