import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/common/widgets/app_bar/app_bar.dart';
import 'package:sporify/common/widgets/button/basic_button.dart';
import 'package:sporify/core/configs/assets/app_vectors.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/data/models/auth/change_password_request.dart';
import 'package:sporify/domain/usecases/auth/change_password.dart';
import 'package:sporify/service_locator.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(
        title: SvgPicture.asset(AppVectors.logo, height: 40, width: 40),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _changePasswordText(),
                const SizedBox(height: 10),
                _descriptionText(context),
                const SizedBox(height: 30),
                _currentPasswordField(context),
                const SizedBox(height: 20),
                _newPasswordField(context),
                const SizedBox(height: 20),
                _confirmPasswordField(context),
                const SizedBox(height: 30),
                BasicButton(
                  onPressed: _changePassword,
                  title: _isLoading ? 'Updating...' : 'Update Password',
                  height: 80,
                ),
                const SizedBox(height: 20),
                _passwordRequirements(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _changePasswordText() {
    return Text(
      'Change Password',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30,
        color: context.isDarkMode ? Colors.white : Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _descriptionText(BuildContext context) {
    return Text(
      'Please enter your current password and choose a new secure password',
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: context.isDarkMode ? Colors.white70 : Colors.black54,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _currentPasswordField(BuildContext context) {
    return TextFormField(
      controller: _currentPasswordController,
      obscureText: !_isCurrentPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your current password';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Current Password',
        suffixIcon: IconButton(
          icon: Icon(
            _isCurrentPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: context.isDarkMode ? Colors.white70 : Colors.black54,
          ),
          onPressed: () {
            setState(() {
              _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
            });
          },
        ),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _newPasswordField(BuildContext context) {
    return TextFormField(
      controller: _newPasswordController,
      obscureText: !_isNewPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a new password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'New Password',
        suffixIcon: IconButton(
          icon: Icon(
            _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: context.isDarkMode ? Colors.white70 : Colors.black54,
          ),
          onPressed: () {
            setState(() {
              _isNewPasswordVisible = !_isNewPasswordVisible;
            });
          },
        ),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _confirmPasswordField(BuildContext context) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your new password';
        }
        if (value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Confirm New Password',
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: context.isDarkMode ? Colors.white70 : Colors.black54,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
    );
  }

  Widget _passwordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: context.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _requirementItem('At least 6 characters long'),
          _requirementItem('Contains both letters and numbers'),
          _requirementItem('Different from your current password'),
        ],
      ),
    );
  }

  Widget _requirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: context.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await sl<ChangePasswordUseCase>().call(
        params: ChangePasswordRequest(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
      );

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
