import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/firebase_service.dart';

class AdminAdvertisementsScreen extends StatefulWidget {
  const AdminAdvertisementsScreen({super.key});

  @override
  State<AdminAdvertisementsScreen> createState() =>
      _AdminAdvertisementsScreenState();
}

class _AdminAdvertisementsScreenState extends State<AdminAdvertisementsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSaving = false;

  Future<void> _showAdvertForm() async {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final buttonController = TextEditingController(text: 'EXPLORE NOW');
    final linkController = TextEditingController();
    final orderController = TextEditingController(text: '0');
    XFile? selectedImage;
    bool active = true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setFormState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Post an advert',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        labelText: 'Title', hintText: 'Weekend deals')),
                TextField(
                    controller: subtitleController,
                    decoration: const InputDecoration(
                        labelText: 'Subtitle',
                        hintText:
                            'Shop selected products at a special price.')),
                TextField(
                    controller: buttonController,
                    decoration:
                        const InputDecoration(labelText: 'Button text')),
                TextField(
                    controller: linkController,
                    decoration: const InputDecoration(
                        labelText: 'Link (optional)',
                        hintText: 'https://example.com')),
                TextField(
                    controller: orderController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Display order')),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final image = await _imagePicker.pickImage(
                        source: ImageSource.gallery, imageQuality: 85);
                    if (image != null) {
                      setFormState(() => selectedImage = image);
                    }
                  },
                  icon: const Icon(Icons.image_outlined),
                  label: Text(selectedImage == null
                      ? 'Choose banner image'
                      : 'Image selected'),
                ),
                if (selectedImage != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(selectedImage!.path),
                          height: 140, fit: BoxFit.cover)),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Publish immediately'),
                  value: active,
                  onChanged: (value) => setFormState(() => active = value),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty ||
                              selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Add a title and banner image first.')));
                            return;
                          }
                          setState(() => _isSaving = true);
                          try {
                            final document = _firebaseService.firestore
                                .collection('advertisements')
                                .doc();
                            final imageUrl = await _firebaseService.uploadImage(
                              'advertisements',
                              '${document.id}.jpg',
                              File(selectedImage!.path),
                            );
                            await document.set({
                              'title': titleController.text.trim(),
                              'subtitle': subtitleController.text.trim(),
                              'button_text':
                                  buttonController.text.trim().isEmpty
                                      ? 'EXPLORE NOW'
                                      : buttonController.text.trim(),
                              'link_url': linkController.text.trim(),
                              'image_url': imageUrl,
                              'sort_order':
                                  int.tryParse(orderController.text.trim()) ??
                                      0,
                              'active': active,
                              'created_by':
                                  FirebaseAuth.instance.currentUser?.uid,
                              'created_at': FieldValue.serverTimestamp(),
                              'updated_at': FieldValue.serverTimestamp(),
                            });
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Advert published successfully.')));
                            }
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Could not publish advert: $error')));
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isSaving = false);
                            }
                          }
                        },
                  icon: const Icon(Icons.publish),
                  label: Text(_isSaving ? 'Publishing...' : 'Publish advert'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    titleController.dispose();
    subtitleController.dispose();
    buttonController.dispose();
    linkController.dispose();
    orderController.dispose();
  }

  Future<void> _deleteAdvert(String id) async {
    await _firebaseService.firestore
        .collection('advertisements')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage adverts')),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAdvertForm,
          icon: const Icon(Icons.add),
          label: const Text('New advert')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firebaseService.firestore
            .collection('advertisements')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Unable to load adverts: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final adverts = snapshot.data!.docs;
          if (adverts.isEmpty) {
            return const Center(
                child: Text('No adverts yet. Add your first banner.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: adverts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final advert = adverts[index];
              final data = advert.data();
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: data['image_url'] == null
                      ? const Icon(Icons.image)
                      : Image.network(data['image_url'],
                          width: 72, height: 56, fit: BoxFit.cover),
                  title: Text(data['title']?.toString() ?? 'Untitled'),
                  subtitle:
                      Text(data['active'] == true ? 'Published' : 'Draft'),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteAdvert(advert.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
