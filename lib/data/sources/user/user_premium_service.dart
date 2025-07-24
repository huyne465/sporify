import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';

abstract class UserPremiumService {
  Future<Either<String, bool>> updateUserToPremium(String subscriptionPlanId);
  Future<Either<String, bool>> checkUserPremiumStatus();
  Future<Either<String, Map<String, dynamic>?>> getUserPremiumInfo();
}

class UserPremiumServiceImpl extends UserPremiumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<Either<String, bool>> updateUserToPremium(
    String subscriptionPlanId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left('User not authenticated');
      }

      // Get subscription plan details based on ID
      Map<String, dynamic> planDetails = _getPlanDetails(subscriptionPlanId);

      // Calculate subscription end date
      final now = DateTime.now();
      final subscriptionEndDate = now.add(
        Duration(days: planDetails['durationInDays']),
      );

      // Update user document with premium status
      await _firestore.collection('Users').doc(user.uid).update({
        'accountStatus': 'premium',
        'subscriptionPlan': subscriptionPlanId,
        'subscriptionStartDate': Timestamp.fromDate(now),
        'subscriptionEndDate': Timestamp.fromDate(subscriptionEndDate),
        'premiumFeatures': {
          'unlimitedSkips': true,
          'noAds': true,
          'highQualityAudio': true,
          'offlineDownloads': true,
          'lyricsAccess': true,
        },
        'lastUpdated': Timestamp.now(),
      });

      return const Right(true);
    } catch (e) {
      return Left('Failed to update user to premium: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> checkUserPremiumStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left('User not authenticated');
      }

      final userDoc = await _firestore.collection('Users').doc(user.uid).get();

      if (!userDoc.exists) {
        return const Right(false);
      }

      final userData = userDoc.data()!;
      final accountStatus = userData['accountStatus'] as String?;

      if (accountStatus != 'premium') {
        return const Right(false);
      }

      // Check if subscription is still valid
      final subscriptionEndDate = userData['subscriptionEndDate'] as Timestamp?;
      if (subscriptionEndDate == null) {
        return const Right(false);
      }

      final now = DateTime.now();
      final isActive = subscriptionEndDate.toDate().isAfter(now);

      // If subscription expired, update status to free
      if (!isActive) {
        await _firestore.collection('Users').doc(user.uid).update({
          'accountStatus': 'free',
          'premiumFeatures': {
            'unlimitedSkips': false,
            'noAds': false,
            'highQualityAudio': false,
            'offlineDownloads': false,
            'lyricsAccess': false,
          },
          'lastUpdated': Timestamp.now(),
        });
        return const Right(false);
      }

      return const Right(true);
    } catch (e) {
      return Left('Failed to check premium status: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>?>> getUserPremiumInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left('User not authenticated');
      }

      final userDoc = await _firestore.collection('Users').doc(user.uid).get();

      if (!userDoc.exists) {
        return const Right(null);
      }

      final userData = userDoc.data()!;

      return Right({
        'accountStatus': userData['accountStatus'] ?? 'free',
        'subscriptionPlan': userData['subscriptionPlan'],
        'subscriptionStartDate': userData['subscriptionStartDate'],
        'subscriptionEndDate': userData['subscriptionEndDate'],
        'premiumFeatures': userData['premiumFeatures'] ?? {},
      });
    } catch (e) {
      return Left('Failed to get user premium info: ${e.toString()}');
    }
  }

  Map<String, dynamic> _getPlanDetails(String planId) {
    switch (planId) {
      case '1_month':
        return {'durationInDays': 30, 'name': '1 Month'};
      case '3_months':
        return {'durationInDays': 90, 'name': '3 Months'};
      case '6_months':
        return {'durationInDays': 180, 'name': '6 Months'};
      default:
        return {'durationInDays': 30, 'name': '1 Month'};
    }
  }
}
