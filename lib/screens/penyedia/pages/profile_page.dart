import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/image_picker_service.dart';
import '../../../database/database_helper.dart';
import '../../../models/user.dart';
import '../../../utils/app_theme.dart';
import '../../auth/login_screen.dart';

class PenyediaProfilePage extends StatefulWidget {
  const PenyediaProfilePage({Key? key}) : super(key: key);

  @override
  State<PenyediaProfilePage> createState() => _PenyediaProfilePageState();
}

class _PenyediaProfilePageState extends State<PenyediaProfilePage> {
  late DatabaseHelper _dbHelper;
  late User _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;
  File? _selectedImage;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _dbHelper.getUserById(AuthService().userId);
      if (mounted && user != null) {
        setState(() {
          _currentUser = user;
          _nameController = TextEditingController(text: user.name);
          _phoneController = TextEditingController(text: user.phone);
          _addressController = TextEditingController(text: user.address);
          _bioController = TextEditingController(text: user.bio ?? '');
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    try {
      var imagePath = _currentUser.profileImage;

      // Save selected image if exists
      if (_selectedImage != null) {
        imagePath = _selectedImage!.path;
      }

      final updated = _currentUser.copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        bio: _bioController.text,
        profileImage: imagePath,
      );
      await _dbHelper.updateUser(updated);

      // Update profile image in database if changed
      if (_selectedImage != null) {
        await _dbHelper.updateUserProfileImage(
          _currentUser.id,
          _selectedImage!.path,
        );
      }

      if (mounted) {
        setState(() {
          _currentUser = updated;
          _selectedImage = null;
          _isEditing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Apakah Anda yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              AuthService().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (c) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final File? image = await ImagePickerService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  void dispose() {
    if (_isEditing) {
      _nameController.dispose();
      _phoneController.dispose();
      _addressController.dispose();
      _bioController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (_currentUser.profileImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      _currentUser.profileImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, st) => Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppTheme.primaryColor,
                                  )),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _currentUser.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Penyedia',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _isEditing ? _buildEditForm() : _buildViewProfile(),
        ),
      ],
    );
  }

  Widget _buildViewProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoSection('Email', _currentUser.email),
        _infoSection('Nomor Telepon', _currentUser.phone),
        _infoSection('Alamat', _currentUser.address),
        if (_currentUser.bio != null && _currentUser.bio!.isNotEmpty)
          _infoSection('Bio', _currentUser.bio!),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textInput('Nama', _nameController),
        const SizedBox(height: 16),
        _textInput('Nomor Telepon', _phoneController),
        const SizedBox(height: 16),
        _textInput('Alamat', _addressController, maxLines: 2),
        const SizedBox(height: 16),
        _textInput('Bio', _bioController, maxLines: 3),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() {
                  _isEditing = false;
                  _selectedImage = null;
                }),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoSection(String label, String value) {
    return Column(
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _textInput(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
