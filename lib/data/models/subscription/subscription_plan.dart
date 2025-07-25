class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationInMonths;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInMonths,
    required this.features,
    this.isPopular = false,
  });

  static List<SubscriptionPlan> getPlans() {
    return [
      SubscriptionPlan(
        id: '1_month',
        name: '1 Month',
        description: 'Perfect for trying out',
        price: 9.99,
        durationInMonths: 1,
        features: [
          'Unlimited music streaming',
          'No ads',
          'High quality audio',
          'Offline downloads',
          'Upload your music to Sporify',
          'Manage your upload songs',
        ],
      ),
      SubscriptionPlan(
        id: '3_months',
        name: '3 Months',
        description: 'Most popular choice',
        price: 24.99,
        durationInMonths: 3,
        features: [
          'Unlimited music streaming',
          'No ads',
          'High quality audio',
          'Offline downloads',
          'Upload your music to Sporify',
          'Manage your upload songs',
          'Save 17% vs monthly',
        ],
        isPopular: true,
      ),
      SubscriptionPlan(
        id: '6_months',
        name: '6 Months',
        description: 'Best value for money',
        price: 44.99,
        durationInMonths: 6,
        features: [
          'Unlimited music streaming',
          'No ads',
          'High quality audio',
          'Offline downloads',
          'Upload your music to Sporify',
          'Manage your upload songs',
          'Save 25% vs monthly',
          'Priority customer support',
        ],
      ),
    ];
  }
}
