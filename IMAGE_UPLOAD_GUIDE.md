# Image Upload & Storage Implementation Guide

## Overview

Fitur image upload dan storage telah diimplementasikan di seluruh aplikasi untuk mendukung profil pengguna dan galeri listing.

## Architecture

### Services

#### ImagePickerService
**File:** `lib/services/image_picker_service.dart`

Utility service untuk menangani pemilihan gambar dari gallery atau camera.

```dart
// Contoh penggunaan
final File? image = await ImagePickerService.pickImageFromGallery();
if (image != null) {
  // Handle selected image
}
```

**Methods:**
- `pickImageFromGallery()` - Buka gallery untuk memilih gambar
- `pickImageFromCamera()` - Buka kamera untuk mengambil foto
- `getImageSize(File)` - Dapatkan ukuran file dalam MB
- `fileExists(String)` - Cek keberadaan file

### Widgets

#### ImageGalleryDialog
**File:** `lib/widgets/image_gallery_dialog.dart`

Widget dialog untuk mengelola koleksi gambar dengan kemampuan:
- Menampilkan preview gambar
- Menambah gambar baru
- Menghapus gambar
- Support untuk network images dan local files

```dart
showDialog(
  context: context,
  builder: (context) => ImageGalleryDialog(
    initialImages: _images,
    onImagesChanged: (newImages) {
      setState(() => _images = newImages);
    },
  ),
);
```

## Implementation Details

### 1. Profile Image Selection

#### Mahasiswa Profile (`lib/screens/mahasiswa/pages/profile_page.dart`)

Fitur yang diimplementasikan:
- Avatar clickable saat mode editing
- Visual feedback dengan camera icon overlay
- Image picker terintegrasi dengan `ImagePickerService`
- Menampilkan selected image atau fallback ke profile image database

**State Variables:**
```dart
File? _selectedImage;  // Temporary storage for selected image
```

**Key Methods:**
```dart
Future<void> _pickImage() async {
  final File? image = await ImagePickerService.pickImageFromGallery();
  if (image != null) {
    setState(() => _selectedImage = image);
  }
}
```

**UI Implementation:**
```dart
GestureDetector(
  onTap: _isEditing ? _pickImage : null,
  child: Stack(
    children: [
      // Display selected image or profile image
      _selectedImage != null
          ? Image.file(_selectedImage!)
          : Image.network(_currentUser.profileImage!),
      // Camera icon overlay when editing
      if (_isEditing)
        Positioned(
          child: Icon(Icons.camera_alt)
        ),
    ],
  ),
)
```

#### Penyedia Profile (`lib/screens/penyedia/pages/profile_page.dart`)

Implementasi identik dengan mahasiswa profile dengan dukungan penuh untuk:
- Image selection saat edit
- Image preview dengan fallback
- Cancel operation untuk reset image selection

#### Admin Profile (`lib/screens/admin/pages/profile_page.dart`)

Implementasi konsisten dengan profile pages lainnya.

### 2. Listing Image Gallery

#### Create Listing Dialog (`lib/screens/penyedia/pages/listings_page.dart`)

Fitur galeri gambar untuk listing hunian dan kegiatan:

**State Variables:**
```dart
List<String> _images = [];  // Menyimpan path gambar
```

**Dialog Integration:**
```dart
Container(
  child: Row(
    children: [
      Column(
        children: [
          const Text('Foto Listing'),
          Text('${_images.length} foto'),
        ],
      ),
      ElevatedButton.icon(
        onPressed: () => showDialog(
          builder: (c) => ImageGalleryDialog(
            initialImages: _images,
            onImagesChanged: (images) {
              setState(() => _images = images);
            },
          ),
        ),
        label: const Text('Kelola'),
      ),
    ],
  ),
)
```

### 3. Current Status

#### Implemented ✅
- `ImagePickerService` - Image selection utility
- `ImageGalleryDialog` - Image management widget
- Profile avatar image selection (Mahasiswa, Penyedia, Admin)
- Listing image gallery UI in create dialog

#### Pending (Next Steps)
- Database persistence untuk profile images
- Image file storage dan path management
- Image display di listing detail page
- Image cleanup saat listing dihapus
- Multiple image persistence untuk listing

## Database Integration

### User Model
File: `lib/models/user.dart`

```dart
class User {
  String? profileImage;  // Path untuk stored image
  // ... other fields
  
  User.fromMap(Map<String, dynamic> map)
    : profileImage = map['profileImage'],
      // ... other mappings
      ;
}
```

### Listing Model
File: `lib/models/listing.dart`

Pending: Menambahkan field untuk multiple images
```dart
class Listing {
  // TODO: Add imageUrls list
  // TODO: Add thumbnailUrl
  // ... existing fields
}
```

## Best Practices

### 1. Image Size Validation
```dart
final File? image = await ImagePickerService.pickImageFromGallery();
if (image != null) {
  final sizeMB = await ImagePickerService.getImageSize(image);
  if (sizeMB > 5) {
    // Show error: image too large
  }
}
```

### 2. Error Handling
```dart
try {
  final image = await ImagePickerService.pickImageFromGallery();
  if (image != null) {
    setState(() => _selectedImage = image);
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e'))
  );
}
```

### 3. Memory Management
- Images disimpan sementara di `_selectedImage` (File)
- Network images ditampilkan langsung dari URL
- Pastikan dispose controllers saat page dispose

## Dependencies

File: `pubspec.yaml`

```yaml
dependencies:
  image_picker: ^0.8.7  # For gallery/camera access
  flutter:
    sdk: flutter
```

Permissions sudah dikonfigurasi di:
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

## Future Enhancements

1. **Image Compression**
   - Implement image compression sebelum upload
   - Resize images untuk thumbnail

2. **Local Storage**
   - Implement caching strategy
   - Save images to app documents directory

3. **Cloud Integration**
   - Upload ke cloud storage (Firebase Storage, AWS S3)
   - Generate shareable URLs

4. **Gallery Display**
   - Implement image carousel di listing detail
   - Swipe gallery dengan thumbnails

5. **Image Editing**
   - Add image cropping tool
   - Basic filters dan adjustments

## Testing

### Manual Testing Checklist

- [ ] Select image from gallery in profile
- [ ] See image preview in avatar
- [ ] Cancel edit without saving image
- [ ] Edit and save profile with new image
- [ ] Add multiple images to listing gallery
- [ ] Remove images from gallery
- [ ] View image gallery dialog properly

### Unit Tests (Future)

```dart
test('ImagePickerService should return File', () async {
  final image = await ImagePickerService.pickImageFromGallery();
  expect(image, isA<File>());
});

test('ImageGalleryDialog should handle image addition', () {
  // Test implementation
});
```

## Troubleshooting

### Common Issues

1. **Image not displaying**
   - Check file path validity
   - Verify image file exists
   - Check error handler dalam Image.file/Image.network

2. **Permission denied**
   - Verify manifest permissions
   - Check iOS plist configuration
   - Request runtime permissions untuk Android 6+

3. **Memory issues with large images**
   - Implement image compression
   - Limit maximum image dimensions
   - Clear temporary files regularly

## Code Examples

### Complete Profile Image Update Flow

```dart
class ProfileState extends State {
  File? _selectedImage;
  
  Future<void> _pickImage() async {
    final image = await ImagePickerService.pickImageFromGallery();
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }
  
  Future<void> _updateProfile() async {
    final updated = _currentUser.copyWith(
      // TODO: Save image path
      name: _nameController.text,
    );
    await _dbHelper.updateUser(updated);
    setState(() {
      _currentUser = updated;
      _selectedImage = null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: Stack(
        children: [
          _selectedImage != null
              ? Image.file(_selectedImage!)
              : Image.network(_currentUser.profileImage ?? ''),
          if (_isEditing)
            Positioned(
              child: Icon(Icons.camera_alt),
            ),
        ],
      ),
    );
  }
}
```

### Complete Listing Image Gallery Flow

```dart
class ListingState extends State {
  List<String> _images = [];
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => showDialog(
            builder: (c) => ImageGalleryDialog(
              initialImages: _images,
              onImagesChanged: (images) {
                setState(() => _images = images);
              },
            ),
          ),
          child: const Text('Manage Images'),
        ),
        // Display image count
        Text('${_images.length} images selected'),
      ],
    );
  }
}
```

## Related Documentation

- [Database Guide](DATABASE_GUIDE.md) - Schema dan model information
- [Development Guide](DEVELOPMENT.md) - Development setup
- [Implementation Templates](IMPLEMENTATION_TEMPLATES.md) - Code patterns

---

**Last Updated:** 2024
**Status:** Implementation in progress
