import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';
import '../../../models/category.dart';
import '../../../utils/app_theme.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late DatabaseHelper _dbHelper;
  late TabController _tabController;
  final List<String> _types = ['hunian', 'kegiatan', 'marketplace'];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addCategory(String type, String name) async {
    try {
      final newCat = Category(
        id: 0,
        name: name,
        type: type,
        createdAt: DateTime.now(),
      );
      await _dbHelper.insertCategory(newCat);
      setState(() {});
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kategori ditambahkan')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteCategory(int id) async {
    try {
      await _dbHelper.deleteCategory(id);
      setState(() {});
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kategori dihapus')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddDialog(String type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nama Kategori',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addCategory(type, controller.text);
                Navigator.pop(c);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Hunian'),
            Tab(text: 'Kegiatan'),
            Tab(text: 'Marketplace'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _types.map((t) => _buildCategoryList(t)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(_types[_tabController.index]),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(String type) {
    return FutureBuilder<List<Category>>(
      future: _dbHelper.getCategoriesByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        final categories = snapshot.data ?? [];
        final mainCats = categories.where((c) => !c.isSubCategory).toList();
        final subCats = categories.where((c) => c.isSubCategory).toList();

        if (mainCats.isEmpty && subCats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('Tidak ada kategori'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showAddDialog(type),
                  child: const Text('Tambah Kategori'),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (mainCats.isNotEmpty) ...[
              Text(
                'Kategori Utama',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ..._buildCategoryTiles(mainCats),
            ],
            if (subCats.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Sub Kategori',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ..._buildCategoryTiles(subCats),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _buildCategoryTiles(List<Category> cats) {
    return cats.map((cat) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Icon(Icons.label, color: AppTheme.primaryColor),
            title: Text(
              cat.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: PopupMenuButton(
              itemBuilder: (c) => [
                PopupMenuItem(
                  child: const Text('Hapus'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Hapus Kategori?'),
                      content: Text('Yakin hapus "${cat.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _deleteCategory(cat.id);
                            Navigator.pop(c);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
