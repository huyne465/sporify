import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sporify/core/services/event_bus_service.dart';
import 'package:sporify/core/services/network_connectivity.dart';
import 'package:sporify/core/events/network_events.dart';
import 'package:sporify/core/di/service_locator.dart';

class NetworkStatusBanner extends StatefulWidget {
  final Widget child;

  const NetworkStatusBanner({super.key, required this.child});

  @override
  State<NetworkStatusBanner> createState() => _NetworkStatusBannerState();
}

class _NetworkStatusBannerState extends State<NetworkStatusBanner>
    with TickerProviderStateMixin {
  bool _isOffline = false;
  StreamSubscription? _networkConnectedSubscription;
  StreamSubscription? _networkDisconnectedSubscription;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeNetworkListeners();
    _checkInitialNetworkStatus();
  }

  void _initializeNetworkListeners() {
    final eventBusService = sl<EventBusService>();

    _networkDisconnectedSubscription = eventBusService.eventBus
        .on<NetworkDisconnectedEvent>()
        .listen((_) {
          if (mounted) {
            setState(() {
              _isOffline = true;
            });
            _animationController.forward();
          }
        });

    _networkConnectedSubscription = eventBusService.eventBus
        .on<NetworkConnectedEvent>()
        .listen((_) {
          if (mounted) {
            _animationController.reverse().then((_) {
              if (mounted) {
                setState(() {
                  _isOffline = false;
                });
              }
            });
          }
        });
  }

  void _checkInitialNetworkStatus() {
    final networkConnectivity = sl<NetworkConnectivity>();
    if (!networkConnectivity.hasInternetAccess) {
      setState(() {
        _isOffline = true;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _networkConnectedSubscription?.cancel();
    _networkDisconnectedSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value * 60),
                child: Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.wifi_off,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'No internet connection',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                sl<NetworkConnectivity>().checkConnectivity();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
