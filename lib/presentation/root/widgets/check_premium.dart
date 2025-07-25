import 'package:flutter/material.dart';
import 'package:sporify/core/di/service_locator.dart';
import 'package:sporify/domain/usecases/user/user_premium.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/core/services/network_connectivity.dart';
import 'package:sporify/core/services/connection_error_handler.dart';

class CheckPremium extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPremiumAccess;

  const CheckPremium({super.key, required this.child, this.onPremiumAccess});

  @override
  State<CheckPremium> createState() => _CheckPremiumState();

  // Static method để gọi check premium từ bên ngoài
  static Future<void> checkPremiumAccess(
    BuildContext context, {
    VoidCallback? onPremiumAccess,
  }) async {
    final checkPremium = _CheckPremiumHelper(context, onPremiumAccess);
    await checkPremium._checkPremium();
  }
}

class _CheckPremiumState extends State<CheckPremium> {
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> checkPremium() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      // Check network connection first
      final networkConnectivity = sl<NetworkConnectivity>();
      if (!networkConnectivity.hasInternetAccess) {
        _showNetworkErrorDialog();
        return;
      }

      // Check if user has premium access
      final result = await sl<CheckUserPremiumStatusUseCase>().call();

      result.fold(
        (failure) {
          // Check if it's a network-related failure
          if (failure.toString().contains('network') ||
              failure.toString().contains('connection') ||
              failure.toString().contains('timeout')) {
            _showNetworkErrorDialog();
          } else {
            showPremiumRequiredDialog();
          }
        },
        (hasPremium) {
          if (hasPremium) {
            setState(() {
              // Bạn có thể thêm navigator push ở đây
              widget.onPremiumAccess?.call();
            });
          } else {
            showPremiumRequiredDialog();
          }
        },
      );
    } catch (e) {
      // Check if it's a network-related error
      if (e.toString().contains('network') ||
          e.toString().contains('connection') ||
          e.toString().contains('timeout') ||
          e.toString().contains('SocketException')) {
        _showNetworkErrorDialog();
      } else {
        showPremiumRequiredDialog();
      }
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _showNetworkErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Text(
              'Connection Error',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.red.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              'Please check your internet connection and try again.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Add to retry queue
              final connectionHandler = sl<ConnectionErrorHandler>();
              connectionHandler.addToRetryQueue(() => checkPremium());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void showPremiumRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Text(
              'Premium Feature',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lyrics,
              size: 48,
              color: AppColors.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Lyrics are available for Premium subscribers only.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to Premium to enjoy lyrics and many other features!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Maybe Later',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/premium');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}

// Helper class để xử lý premium check từ bên ngoài widget tree
class _CheckPremiumHelper {
  final BuildContext context;
  final VoidCallback? onPremiumAccess;
  bool _isChecking = false;

  _CheckPremiumHelper(this.context, this.onPremiumAccess);

  Future<void> _checkPremium() async {
    if (_isChecking) return;

    _isChecking = true;

    try {
      // Check network connection first
      final networkConnectivity = sl<NetworkConnectivity>();
      if (!networkConnectivity.hasInternetAccess) {
        _showNetworkErrorDialog();
        return;
      }

      // Check if user has premium access
      final result = await sl<CheckUserPremiumStatusUseCase>().call();

      result.fold(
        (failure) {
          // Check if it's a network-related failure
          if (failure.toString().contains('network') ||
              failure.toString().contains('connection') ||
              failure.toString().contains('timeout')) {
            _showNetworkErrorDialog();
          } else {
            _showPremiumRequiredDialog();
          }
        },
        (hasPremium) {
          if (hasPremium) {
            onPremiumAccess?.call();
          } else {
            _showPremiumRequiredDialog();
          }
        },
      );
    } catch (e) {
      // Check if it's a network-related error
      if (e.toString().contains('network') ||
          e.toString().contains('connection') ||
          e.toString().contains('timeout') ||
          e.toString().contains('SocketException')) {
        _showNetworkErrorDialog();
      } else {
        _showPremiumRequiredDialog();
      }
    } finally {
      _isChecking = false;
    }
  }

  void _showNetworkErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Text(
              'Connection Error',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.red.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              'Please check your internet connection and try again.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Add to retry queue
              final connectionHandler = sl<ConnectionErrorHandler>();
              connectionHandler.addToRetryQueue(() => _checkPremium());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showPremiumRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Text(
              'Premium Feature',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lyrics,
              size: 48,
              color: AppColors.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Lyrics are available for Premium subscribers only.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to Premium to enjoy lyrics and many other features!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Maybe Later',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/premium');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}
