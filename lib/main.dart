// import 'package:doona/screens/homescreen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
//
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HomeScreen(),
//     );
//   }
// }
//


//
// import 'package:doona/screens/homescreen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'blocs/auth_bloc.dart';
// import 'blocs/task_bloc.dart';
// import 'services/auth_service.dart';
// import 'services/task_service.dart';
// import 'screens/auth/login_screen.dart';
// import 'constants/app_constants.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => AuthBloc(AuthService())..add(AuthCheckRequested()),
//         ),
//         BlocProvider(
//           create: (context) => TaskBloc(TaskService()),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'TaskFlow',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primarySwatch: Colors.indigo,
//           useMaterial3: true,
//           colorScheme: ColorScheme.fromSeed(
//             seedColor: AppColors.primary,
//             brightness: Brightness.light,
//           ),
//         ),
//         home: BlocBuilder<AuthBloc, AuthState>(
//           builder: (context, state) {
//             if (state is AuthAuthenticated) {
//               return const HomeScreen();
//             }
//             return const LoginScreen();
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/task_bloc.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';

import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(AuthService())..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => TaskBloc(TaskService()),
        ),
      ],
      child: MaterialApp(
        title: 'TaskFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
        ),
        home: const SplashWrapper(),
      ),
    );
  }
}
