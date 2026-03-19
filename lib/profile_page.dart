import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'language_provider.dart';
import 'auth/auth_service.dart';
import 'widgets/app_drawer.dart';

class ProfilePage extends StatefulWidget {
  final AuthService auth;
  const ProfilePage({super.key, required this.auth});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _isEditing = false;

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _licenseController;
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _plateController;

  // User data
  Map<String, dynamic>? _userData;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.auth.currentUser;
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _licenseController = TextEditingController();
    _makeController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _plateController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
          _updateControllers();
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateControllers() {
    _nameController.text =
        _userData?['name'] ?? _currentUser?.displayName ?? '';
    _phoneController.text = _userData?['phone'] ?? '';
    _licenseController.text = _userData?['licenseNumber'] ?? '';
    _makeController.text = _userData?['vehicleMake'] ?? '';
    _modelController.text = _userData?['vehicleModel'] ?? '';
    _yearController.text = _userData?['vehicleYear']?.toString() ?? '';
    _plateController.text = _userData?['licensePlate'] ?? '';
  }

  Future<void> _saveProfile() async {
    final uid = _currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
        'vehicleMake': _makeController.text.trim(),
        'vehicleModel': _modelController.text.trim(),
        'vehicleYear': int.tryParse(_yearController.text.trim()) ?? 0,
        'licensePlate': _plateController.text.trim(),
        'email': _currentUser?.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update display name in Firebase Auth
      if (_nameController.text.trim().isNotEmpty) {
        await _currentUser?.updateDisplayName(_nameController.text.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageProvider>(
                context,
                listen: false,
              ).translate('profile_updated'),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _isEditing = false;
      });

      await _loadUserData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async => widget.auth.logout();

  Future<AppRole> _loadRole() async {
    final uid = widget.auth.currentUser?.uid;
    if (uid == null) return AppRole.driver;
    final role = (await widget.auth.getOrCreateUserRole(uid)).toLowerCase();
    return role == 'advertiser' ? AppRole.advertiser : AppRole.driver;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    const currentRoute = '/profile';

    return FutureBuilder<AppRole>(
      future: _loadRole(),
      builder: (context, snap) {
        final role = snap.data ?? AppRole.driver;

        return Scaffold(
          backgroundColor: const Color(0xfff5f6fa),
          drawer: AppDrawer(
            role: role,
            activeRoute: currentRoute,
            onLogout: _logout,
          ),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              lp.translate('profile'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => lp.toggleLanguage(),
                icon: const Icon(Icons.language),
              ),
              if (!_isEditing)
                IconButton(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                )
              else
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _updateControllers();
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        lp.translate('profile'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lp.translate('manage_profile_vehicle'),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),

                      // Personal Information Section
                      _buildSection(
                        title: lp.translate('personal_info'),
                        children: [
                          _buildInfoField(
                            label: lp.translate('name'),
                            controller: _nameController,
                            isEditing: _isEditing,
                            icon: Icons.person,
                          ),
                          _buildInfoField(
                            label: lp.translate('email'),
                            value: _currentUser?.email ?? '',
                            isEditing: false,
                            icon: Icons.email,
                            isReadOnly: true,
                          ),
                          _buildInfoField(
                            label: lp.translate('phone'),
                            controller: _phoneController,
                            isEditing: _isEditing,
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          _buildInfoField(
                            label: lp.translate('license_number'),
                            controller: _licenseController,
                            isEditing: _isEditing,
                            icon: Icons.badge,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Vehicle Information Section (only for drivers)
                      if (role == AppRole.driver)
                        _buildSection(
                          title: lp.translate('vehicle_info'),
                          children: [
                            _buildInfoField(
                              label: lp.translate('make'),
                              controller: _makeController,
                              isEditing: _isEditing,
                              icon: Icons.directions_car,
                            ),
                            _buildInfoField(
                              label: lp.translate('model'),
                              controller: _modelController,
                              isEditing: _isEditing,
                              icon: Icons.model_training,
                            ),
                            _buildInfoField(
                              label: lp.translate('year'),
                              controller: _yearController,
                              isEditing: _isEditing,
                              icon: Icons.calendar_today,
                              keyboardType: TextInputType.number,
                            ),
                            _buildInfoField(
                              label: lp.translate('license_plate'),
                              controller: _plateController,
                              isEditing: _isEditing,
                              icon: Icons.pin,
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),

                      // Save Button
                      if (_isEditing)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(lp.translate('save')),
                          ),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    String? value,
    TextEditingController? controller,
    required bool isEditing,
    required IconData icon,
    bool isReadOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          isEditing && !isReadOnly
              ? TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    prefixIcon: Icon(icon, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isReadOnly ? Colors.grey[100] : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        value ?? controller?.text ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: isReadOnly ? Colors.grey[600] : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
