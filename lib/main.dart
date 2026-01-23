import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:railzo/core/theme/app_theme.dart';
import 'package:railzo/core/firebase/firebase_config.dart';
import 'package:railzo/presentation/auth/screens/login_screen.dart';
import 'package:railzo/presentation/auth/screens/signup_screen.dart';
import 'package:railzo/data/repositories/auth_repository.dart';
import 'package:railzo/presentation/user/screens/user_navigation_screen.dart';
import 'package:railzo/presentation/user/screens/my_tickets_screen.dart';
import 'package:railzo/presentation/user/screens/train_list_screen.dart';
import 'package:railzo/presentation/user/screens/train_details_screen.dart';
import 'package:railzo/presentation/user/screens/seat_selection_screen.dart';
import 'package:railzo/presentation/user/screens/passenger_details_screen.dart';
import 'package:railzo/presentation/user/screens/review_payment_screen.dart';
import 'package:railzo/presentation/user/screens/booking_success_screen.dart';
import 'package:railzo/presentation/user/screens/ticket_details_screen.dart';
import 'package:railzo/presentation/admin/screens/admin_navigation_screen.dart';
import 'package:railzo/presentation/admin/screens/manage_trains_screen.dart';
import 'package:railzo/presentation/admin/screens/manage_routes_screen.dart';
import 'package:railzo/presentation/admin/screens/manage_schedules_screen.dart';
import 'package:railzo/presentation/admin/screens/pricing_management_screen.dart';
import 'package:railzo/core/services/stripe_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();

  // Initialize Stripe
  // 1. Get your keys from Stripe Dashboard (https://dashboard.stripe.com/test/apikeys)
  // 2. In Production, ALWAYS use a backend server to create Payment Intents.
  StripeService.instance.init(
    publishableKey: 'YOUR_PUBLISHABLE_KEY',
    secretKey: 'YOUR_SECRET_KEY', // Only for demo/testing!
    // backendUrl: 'https://your-api.com/create-payment-intent',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Railzo - Railway Booking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/user/home': (context) => const UserNavigationScreen(),
        '/user/trains': (context) => const TrainListScreen(),
        '/user/train-details': (context) => const TrainDetailsScreen(),
        '/user/seat-selection': (context) => const SeatSelectionScreen(),
        '/user/passenger-details': (context) => const PassengerDetailsScreen(),
        '/user/my-tickets': (context) => const MyTicketsScreen(),
        '/user/review-payment': (context) => const ReviewPaymentScreen(),
        '/user/booking-success': (context) => const BookingSuccessScreen(),
        '/user/ticket-details': (context) => const TicketDetailsScreen(),
        '/admin/home': (context) => const AdminNavigationScreen(),
        '/admin/trains': (context) => const ManageTrainsScreen(),
        '/admin/routes': (context) => const ManageRoutesScreen(),
        '/admin/schedules': (context) => const ManageSchedulesScreen(),
        '/admin/pricing': (context) => const PricingManagementScreen(),
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          final authRepo = ref.read(authRepositoryProvider);
          if (authRepo.isAdmin(user.email)) {
            return const AdminNavigationScreen();
          }
          return const UserNavigationScreen();
        }
        return const LoginScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, stack) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
