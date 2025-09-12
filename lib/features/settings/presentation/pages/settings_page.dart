import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // App Settings
            _buildSectionTitle('App Settings'),
            _buildSettingsGroup([
              _buildSwitchTile(
                'Notifications',
                'Receive push notifications',
                Icons.notifications_outlined,
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
              ),
              _buildSwitchTile(
                'Biometric Authentication',
                'Use fingerprint or face ID',
                Icons.fingerprint,
                _biometricEnabled,
                (value) => setState(() => _biometricEnabled = value),
              ),
              _buildSwitchTile(
                'Dark Mode',
                'Use dark theme',
                Icons.dark_mode_outlined,
                _darkModeEnabled,
                (value) => setState(() => _darkModeEnabled = value),
              ),
            ]),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Preferences
            _buildSectionTitle('Preferences'),
            _buildSettingsGroup([
              _buildDropdownTile(
                'Language',
                'Select app language',
                Icons.language,
                _selectedLanguage,
                ['English', 'Spanish', 'French', 'German'],
                (value) => setState(() => _selectedLanguage = value!),
              ),
              _buildDropdownTile(
                'Currency',
                'Select default currency',
                Icons.attach_money,
                _selectedCurrency,
                ['USD', 'EUR', 'GBP', 'JPY'],
                (value) => setState(() => _selectedCurrency = value!),
              ),
            ]),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Security
            _buildSectionTitle('Security'),
            _buildSettingsGroup([
              _buildNavigationTile(
                'Change Password',
                'Update your password',
                Icons.lock_outline,
                () => _changePassword(),
              ),
              _buildNavigationTile(
                'Two-Factor Authentication',
                'Add extra security',
                Icons.security,
                () => _setupTwoFactor(),
              ),
              _buildNavigationTile(
                'Privacy Settings',
                'Manage your privacy',
                Icons.privacy_tip_outlined,
                () => _privacySettings(),
              ),
            ]),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Support
            _buildSectionTitle('Support & About'),
            _buildSettingsGroup([
              _buildNavigationTile(
                'Help Center',
                'Get help and support',
                Icons.help_outline,
                () => _openHelpCenter(),
              ),
              _buildNavigationTile(
                'Contact Us',
                'Send us a message',
                Icons.contact_support_outlined,
                () => _contactSupport(),
              ),
              _buildNavigationTile(
                'Terms of Service',
                'Read our terms',
                Icons.description_outlined,
                () => _openTerms(),
              ),
              _buildNavigationTile(
                'Privacy Policy',
                'Read our privacy policy',
                Icons.policy_outlined,
                () => _openPrivacyPolicy(),
              ),
              _buildNavigationTile(
                'About',
                'App version and info',
                Icons.info_outline,
                () => _showAbout(),
              ),
            ]),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Logout Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 30,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall / 2),
                Text(
                  'john.doe@example.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall / 2),
                Text(
                  'Premium Member',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
            onPressed: () => _editProfile(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: tiles
            .asMap()
            .entries
            .map((entry) => Column(
                  children: [
                    entry.value,
                    if (entry.key < tiles.length - 1)
                      const Divider(height: 1, color: AppColors.grey300),
                  ],
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey500),
      onTap: onTap,
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit Profile feature'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Change Password feature'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _setupTwoFactor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Two-Factor Authentication setup'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _privacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy Settings'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help Center'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact Support'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _openTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms of Service'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy Policy'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: AppStrings.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.shopping_bag,
          color: AppColors.white,
          size: 32,
        ),
      ),
      children: [
        Text('${AppStrings.appName} is a modern ecommerce app with wallet functionality.'),
      ],
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle logout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}