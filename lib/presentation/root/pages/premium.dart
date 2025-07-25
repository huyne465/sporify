import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pay/pay.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/base_widgets/app_bar/app_bar.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/core/navigation/getx_navigator.dart';
import 'package:sporify/data/models/subscription/subscription_plan.dart';
import 'package:sporify/domain/usecases/user/user_premium.dart';
import 'package:sporify/core/di/service_locator.dart';
import 'package:sporify/presentation/music_player/widgets/mini_player.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  SubscriptionPlan? selectedPlan;
  String? defaultGooglePayConfigString;

  @override
  void initState() {
    super.initState();
    _loadGooglePayConfig();
    selectedPlan =
        SubscriptionPlan.getPlans()[1]; // Default to 1 months (popular)
  }

  Future<void> _loadGooglePayConfig() async {
    try {
      final config = await rootBundle.loadString(
        'assets/json/google_pay_default_payment_profile.json',
      );
      setState(() {
        defaultGooglePayConfigString = config;
      });
    } catch (e) {
      print('Error loading Google Pay config: $e');
    }
  }

  List<PaymentItem> get _paymentItems {
    return [
      PaymentItem(
        label: selectedPlan?.name ?? 'Premium Plan',
        amount: selectedPlan?.price.toStringAsFixed(2) ?? '0.00',
        status: PaymentItemStatus.final_price,
      ),
    ];
  }

  void onGooglePayResult(paymentResult) async {
    // Handle successful payment
    print('Google Pay payment result: $paymentResult');

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Update user to premium in Firestore
      final result = await sl<UpdateUserToPremiumUseCase>().call(
        params: selectedPlan?.id ?? '1_month',
      );

      // Close loading dialog
      Navigator.of(context).pop();

      result.fold(
        (failure) {
          // Show error message
          _showPaymentError(failure);
        },
        (success) {
          // Show success and navigate to home
          _showPaymentSuccess();
        },
      );
    } catch (e) {
      // Close loading dialog if still open
      Navigator.of(context).pop();
      _showPaymentError('Failed to process payment: ${e.toString()}');
    }
  }

  void _showPaymentError(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.isDarkMode ? Colors.grey[800] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Text(
              'Payment Error',
              style: TextStyle(
                color: context.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          error,
          style: TextStyle(
            color: context.isDarkMode ? Colors.white70 : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.isDarkMode ? Colors.grey[800] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Text(
              'Payment Successful!',
              style: TextStyle(
                color: context.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'You have successfully subscribed to the ${selectedPlan?.name} Premium plan.\n\nEnjoy unlimited music streaming with no ads and exclusive features including lyrics access!',
          style: TextStyle(
            color: context.isDarkMode ? Colors.white70 : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              AppNavigator.toMainNavigation(); // Navigate to home using GetX
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('Continue to Home'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = SubscriptionPlan.getPlans();

    return Scaffold(
      appBar: BasicAppBar(
        hideback: true,
        title: Text(
          'Premium Plans',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header section
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            AppColors.primary.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Unlock Premium',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: context.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Choose your subscription plan and enjoy unlimited music with no ads',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.isDarkMode
                            ? Colors.white70
                            : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Subscription plans
                    ...plans.map((plan) => _buildPlanCard(plan)),

                    const SizedBox(height: 20),

                    // Selected plan summary
                    if (selectedPlan != null) ...[
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected Plan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  selectedPlan!.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: context.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '\$${selectedPlan!.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Google Pay button
                    if (defaultGooglePayConfigString != null &&
                        selectedPlan != null)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: GooglePayButton(
                          paymentConfiguration:
                              PaymentConfiguration.fromJsonString(
                                defaultGooglePayConfigString!,
                              ),
                          paymentItems: _paymentItems,
                          type: GooglePayButtonType.buy,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          onPaymentResult: onGooglePayResult,
                          loadingIndicator: const Center(
                            child: CircularProgressIndicator(),
                          ),
                          width: double.infinity,
                          height: 55,
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),

                    const SizedBox(height: 20),

                    // Terms and conditions
                    Text(
                      'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscription will auto-renew unless canceled.',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.isDarkMode
                            ? Colors.white60
                            : Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80), // Space for mini player
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isSelected = selectedPlan?.id == plan.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPlan = plan;
          });
        },
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : (context.isDarkMode ? Colors.grey[850] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (context.isDarkMode
                        ? Colors.grey[700]!
                        : Colors.grey[300]!),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primary
                                    : (context.isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                              ),
                            ),
                            if (plan.isPopular) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'POPULAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          plan.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.isDarkMode
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${plan.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (plan.durationInMonths > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Save ${_calculateSavings(plan)}%',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: plan.features
                    .map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.isDarkMode
                                      ? Colors.white70
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (isSelected) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'SELECTED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _calculateSavings(SubscriptionPlan plan) {
    final monthlyPrice = 9.99;
    final totalMonthlyPrice = monthlyPrice * plan.durationInMonths;
    final savings =
        ((totalMonthlyPrice - plan.price) / totalMonthlyPrice) * 100;
    return savings.round();
  }
}
