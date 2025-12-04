import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/user.dart';
import '../../../utils/app_theme.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
    with SingleTickerProviderStateMixin {
  late DatabaseHelper _dbHelper;
  late TabController _tabController;
  List<User> _mahasiswa = [], _penyedia = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final mhs = await _dbHelper.getUsersByType('mahasiswa');
      final pny = await _dbHelper.getUsersByType('penyedia');
      setState(() {
        _mahasiswa = mhs;
        _penyedia = pny;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleUserStatus(User user) async {
    try {
      final updated = user.copyWith(isActive: !user.isActive);
      await _dbHelper.updateUser(updated);
      _loadUsers();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status ${updated.isActive ? "aktif" : "nonaktif"}'),
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Mahasiswa'),
            Tab(text: 'Penyedia'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(_mahasiswa, 'mahasiswa'),
          _buildUserList(_penyedia, 'penyedia'),
        ],
      ),
    );
  }

  Widget _buildUserList(List<User> users, String type) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Tidak ada pengguna'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                user.email,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              trailing: PopupMenuButton(
                itemBuilder: (c) => [
                  PopupMenuItem(
                    child: Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                    onTap: () => _toggleUserStatus(user),
                  ),
                  PopupMenuItem(
                    child: const Text('Hapus'),
                    onTap: () => showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Nonaktifkan Pengguna?'),
                        content: Text('Nonaktifkan akun ${user.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _toggleUserStatus(user);
                              Navigator.pop(c);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text('Nonaktifkan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          ),
        );
      },
    );
  }
}
