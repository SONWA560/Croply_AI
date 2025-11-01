import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool alertsEnabled = true;
  bool dailySummariesEnabled = false;

  static const Color primaryGreen = Color(0xFF33CC00);
  static const Color backgroundLight = Color(0xFFF7F9F6);
  static const Color textBlack = Colors.black;
  static const Color textGrey = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionTitle('Notifications'),
          _buildSwitchTile(
            title: 'Alerts',
            subtitle: 'Receive alerts for crop health issues.',
            value: alertsEnabled,
            onChanged: (val) => setState(() => alertsEnabled = val),
          ),
          _buildSwitchTile(
            title: 'Daily Summaries',
            subtitle: 'Get a daily summary of your crop progress.',
            value: dailySummariesEnabled,
            onChanged: (val) => setState(() => dailySummariesEnabled = val),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('Preferences'),
          _buildListTile(
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              // Add your language setting logic here
            },
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('Account'),
          _buildListTile(title: 'Change Password', onTap: () {
            // Add navigation to Change Password screen
          }),
          _buildListTile(title: 'Update Profile', onTap: () {
            // Add navigation to Update Profile screen
          }),
          const SizedBox(height: 20),

          _buildSectionTitle('Data'),
          _buildListTile(title: 'Clear Cached Data', onTap: () {
            // Add cache clearing logic
          }),
          const SizedBox(height: 20),

          _buildSectionTitle('Legal'),
          _buildListTile(title: 'Privacy Policy', onTap: () {
            // Add navigation to Privacy Policy screen
          }),
          _buildListTile(title: 'Terms of Service', onTap: () {
            // Add navigation to Terms of Service screen
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      value: value,
      activeThumbColor: primaryGreen,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
