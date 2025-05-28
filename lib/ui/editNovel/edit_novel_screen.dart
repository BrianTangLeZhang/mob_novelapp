import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mob_novelapp/data/model/novel.dart';
import 'package:mob_novelapp/data/repo/novel_repo.dart';
import 'package:mob_novelapp/service/storage_service.dart';
import 'package:mob_novelapp/ui/drawer/drawer.dart';

class EditNovelScreen extends ConsumerStatefulWidget {
  const EditNovelScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<EditNovelScreen> createState() => _EditNovelScreenState();
}

class _EditNovelScreenState extends ConsumerState<EditNovelScreen> {
  final repo = NovelRepoSupabase();
  final storageService = StorageService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Novel? novel;
  int titleCounter = 0;
  int descriptionCounter = 0;
  List<Uint8List> defaultCoverBytesList = [];
  List<String> defaultCovers = [];
  int? selectedDefaultCoverIndex;
  File? selectedFile;
  Uint8List? bytes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNovel();
    _loadAssets();

    _titleController.addListener(() {
      setState(() {
        titleCounter = _titleController.text.trim().length;
      });
    });

    _descriptionController.addListener(() {
      setState(() {
        descriptionCounter = _descriptionController.text.trim().length;
      });
    });
  }

  void _loadNovel() async {
    setState(() => isLoading = true);
    final res = await repo.getNovelById(widget.id);
    final imageBytes = await storageService.getImage(res!.cover);
    setState(() {
      novel = res;
      bytes = imageBytes;
      _titleController.text = novel!.title;
      _descriptionController.text = novel!.description;
      isLoading = false;
    });
  }

  void _loadAssets() async {
    const folder = 'assets/';
    final manifest = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = Map.from(
      (await json.decode(manifest)).cast<String, dynamic>(),
    );

    final assets =
        manifestMap.keys
            .where(
              (String key) => key.startsWith(folder) && key.endsWith('.jpg'),
            )
            .toList();

    final List<Uint8List> bytesList = [];
    for (final assetPath in assets) {
      final byteData = await rootBundle.load(assetPath);
      bytesList.add(byteData.buffer.asUint8List());
    }

    setState(() {
      defaultCovers = assets;
      defaultCoverBytesList = bytesList;
    });
  }

  Widget _buildCoverImage() {
    if (bytes != null) {
      return Image.memory(bytes!, fit: BoxFit.cover);
    } else if (selectedDefaultCoverIndex != null &&
        selectedDefaultCoverIndex! < defaultCoverBytesList.length) {
      return Image.memory(
        defaultCoverBytesList[selectedDefaultCoverIndex!],
        fit: BoxFit.cover,
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  void _showCoverSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choose Cover"),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              children: [
                if (defaultCovers.isNotEmpty)
                  ...defaultCoverBytesList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final coverBytes = entry.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDefaultCoverIndex = index;
                          bytes = null;
                        });
                        Navigator.pop(context);
                      },
                      child: Image.memory(
                        coverBytes,
                        height: 160,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  }),
                GestureDetector(
                  onTap: _pickAndCropImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(child: Icon(Icons.add)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickAndCropImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      if (result.files.single.size > 10 * 1024 * 1024) {
        _snackbar('File size exceeds 10MB.');
        return;
      }

      final pickedFilePath = result.files.single.path!;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFilePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1.6),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Cover',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
        ],
      );
      if (croppedFile != null && croppedFile.path.isNotEmpty) {
        final croppedBytes = await File(croppedFile.path).readAsBytes();

        setState(() {
          bytes = croppedBytes;
          selectedDefaultCoverIndex = null;
        });
        if (mounted) {
          context.pop();
        }
      } else {
        _snackbar('Cropping cancelled.');
      }
    } else {
      _snackbar('No file selected or invalid file path.');
    }
  }

  void _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      _snackbar("Please fill in all fields.");
      return;
    }

    if (title.length > 25) {
      _snackbar("Title can't be more than 25 characters");
      return;
    }

    if (description.length > 200) {
      _snackbar("Description can't be more than 200 characters");
      return;
    }

    if (bytes == null && selectedDefaultCoverIndex == null) {
      _snackbar("Please select a cover image.");
      return;
    }

    try {
      String newCoverName = novel!.cover;

      final isCoverUpdated = bytes != null || selectedDefaultCoverIndex != null;

      if (isCoverUpdated) {
        await storageService.deleteImage(novel!.cover);

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        newCoverName = "cover_$timestamp.jpg";

        Uint8List imageToUpload =
            bytes ?? defaultCoverBytesList[selectedDefaultCoverIndex!];

        await storageService.uploadImage(newCoverName, imageToUpload);
      }

      final updatedNovel = novel!.copy(
        id: widget.id,
        title: title,
        description: description,
        cover: newCoverName,
      );

      await repo.updateNovel(updatedNovel);

      _snackbar("Novel updated successfully.");
      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      _snackbar("Failed to submit novel.");
    }
  }

  void _snackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Edit Novel",
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _showCoverSelectionDialog,
                    child: Container(
                      height: 240,
                      width: 120,
                      color: Colors.grey[200],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _buildCoverImage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$titleCounter / 25 chars',
                  style: TextStyle(
                    fontSize: 12,
                    color: titleCounter > 25 ? Colors.red : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  textAlign: TextAlign.start,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$descriptionCounter / 200 chars',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        descriptionCounter > 200
                            ? Colors.red
                            : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: MaterialButton(
                    onPressed: _submit,
                    color: Colors.black,
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
