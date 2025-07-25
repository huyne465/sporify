import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sporify/common/helpers/is_dark.dart';
import 'package:sporify/core/configs/themes/app_colors.dart';
import 'package:sporify/data/dataSources/song/admin_file_upload_service.dart';

class AdminFileUploadPage extends StatefulWidget {
  const AdminFileUploadPage({super.key});

  @override
  State<AdminFileUploadPage> createState() => _AdminFileUploadPageState();
}

class _AdminFileUploadPageState extends State<AdminFileUploadPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _albumController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  final AdminFileUploadService _uploadService = AdminFileUploadService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedAudioFile;
  File? _selectedImageFile;
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';
  String? _message;
  bool _isError = false;
  Map<String, dynamic>? _storageInfo;

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    final info = await _uploadService.getStorageInfo();
    setState(() {
      _storageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Upload Song Files'),
        backgroundColor: context.isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: context.isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadStorageInfo,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageInfoCard(),
            const SizedBox(height: 20),
            _buildFileSelectionSection(),
            const SizedBox(height: 20),
            _buildSongDetailsForm(),
            const SizedBox(height: 30),
            _buildUploadButton(),
            if (_message != null) ...[
              const SizedBox(height: 20),
              _buildMessageCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[900] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Storage Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_storageInfo != null) ...[
            _buildInfoRow('Total Songs', '${_storageInfo!['totalSongs']}'),
            _buildInfoRow(
              'Total Storage Used',
              _storageInfo!['totalFileSizeFormatted'],
            ),
          ] else ...[
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.isDarkMode ? Colors.white70 : Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: context.isDarkMode ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Files',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Audio file selection
        _buildFileSelector(
          title: 'Audio File *',
          subtitle: 'Select MP3, WAV, AAC, M4A, OGG, or FLAC file',
          file: _selectedAudioFile,
          onTap: _pickAudioFile,
          icon: Icons.audiotrack,
          isRequired: true,
        ),

        const SizedBox(height: 16),

        // Image file selection
        _buildFileSelector(
          title: 'Cover Image',
          subtitle: 'Select JPG, PNG, GIF, or WebP file (optional)',
          file: _selectedImageFile,
          onTap: _pickImageFile,
          icon: Icons.image,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildFileSelector({
    required String title,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
    required IconData icon,
    required bool isRequired,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: file != null
              ? AppColors.primary
              : (context.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: file != null ? AppColors.primary : Colors.grey,
          size: 32,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                color: context.isDarkMode ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (file != null) ...[
              const SizedBox(height: 4),
              Text(
                'Selected: ${file.path.split('/').last}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: file != null
            ? IconButton(
                onPressed: () {
                  setState(() {
                    if (icon == Icons.audiotrack) {
                      _selectedAudioFile = null;
                    } else {
                      _selectedImageFile = null;
                    }
                  });
                },
                icon: const Icon(Icons.close, color: Colors.red),
              )
            : Icon(Icons.add_circle_outline, color: AppColors.primary),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSongDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Song Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _titleController,
          label: 'Title *',
          hint: 'Enter song title',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _artistController,
          label: 'Artist *',
          hint: 'Enter artist name',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _albumController,
          label: 'Album',
          hint: 'Enter album name (optional)',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _genreController,
          label: 'Genre',
          hint: 'Enter genre (optional)',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _durationController,
          label: 'Duration (seconds)',
          hint: 'Enter duration in seconds (optional)',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.isDarkMode ? Colors.white54 : Colors.grey,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          style: TextStyle(
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return Column(
      children: [
        if (_isLoading) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.isDarkMode ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud_upload, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      _uploadStatus.isEmpty ? 'Uploading...' : _uploadStatus,
                      style: TextStyle(
                        color: context.isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_uploadProgress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: context.isDarkMode
                        ? Colors.white70
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _uploadSong,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : const Text(
                    'Upload Song',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isError
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isError ? Colors.red : Colors.green),
      ),
      child: Row(
        children: [
          Icon(
            _isError ? Icons.error : Icons.check_circle,
            color: _isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _message!,
              style: TextStyle(
                color: _isError ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Validate file exists
        if (!await file.exists()) {
          _showMessage('Selected file does not exist', isError: true);
          return;
        }

        // Validate file size (max 50MB)
        final fileSize = await file.length();
        if (fileSize > 50 * 1024 * 1024) {
          _showMessage('File too large. Maximum size is 50MB', isError: true);
          return;
        }

        setState(() {
          _selectedAudioFile = file;
          _message = null;
        });

        print('Selected audio file: ${file.path}');
        print('File exists: ${await file.exists()}');
        print('File size: ${fileSize / (1024 * 1024)} MB');
      }
    } catch (e) {
      _showMessage('Error selecting audio file: $e', isError: true);
    }
  }

  Future<void> _pickImageFile() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);

        // Validate file exists
        if (!await file.exists()) {
          _showMessage('Selected image does not exist', isError: true);
          return;
        }

        // Validate file size (max 5MB)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          _showMessage('Image too large. Maximum size is 5MB', isError: true);
          return;
        }

        setState(() {
          _selectedImageFile = file;
          _message = null;
        });

        print('Selected image file: ${file.path}');
        print('File exists: ${await file.exists()}');
        print('File size: ${fileSize / (1024 * 1024)} MB');
      }
    } catch (e) {
      _showMessage('Error selecting image file: $e', isError: true);
    }
  }

  Future<void> _uploadSong() async {
    if (_selectedAudioFile == null) {
      _showMessage('Please select an audio file', isError: true);
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showMessage('Please enter a song title', isError: true);
      return;
    }

    if (_artistController.text.trim().isEmpty) {
      _showMessage('Please enter an artist name', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Preparing upload...';
      _message = null;
    });

    try {
      // Simulate progress updates (in real implementation, you'd get this from the upload service)
      _updateProgress(0.1, 'Validating files...');
      await Future.delayed(const Duration(milliseconds: 500));

      _updateProgress(0.2, 'Uploading audio file...');
      await Future.delayed(const Duration(milliseconds: 500));

      final result = await _uploadService.addSongWithFiles(
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        audioFile: _selectedAudioFile!,
        imageFile: _selectedImageFile,
        album: _albumController.text.trim().isEmpty
            ? null
            : _albumController.text.trim(),
        genre: _genreController.text.trim().isEmpty
            ? null
            : _genreController.text.trim(),
        duration: _durationController.text.trim().isEmpty
            ? null
            : double.tryParse(_durationController.text.trim()),
      );

      _updateProgress(1.0, 'Upload completed!');
      await Future.delayed(const Duration(milliseconds: 500));

      if (result.isRight()) {
        final message = result.fold((l) => '', (r) => r);
        _showMessage(message, isError: false);
        _clearForm();
        _loadStorageInfo();
      } else {
        final error = result.fold((l) => l, (r) => '');
        _showMessage(error, isError: true);
      }
    } catch (e) {
      _showMessage('Unexpected error: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
        _uploadProgress = 0.0;
        _uploadStatus = '';
      });
    }
  }

  void _updateProgress(double progress, String status) {
    if (mounted) {
      setState(() {
        _uploadProgress = progress;
        _uploadStatus = status;
      });
    }
  }

  void _showMessage(String message, {required bool isError}) {
    setState(() {
      _message = message;
      _isError = isError;
    });
  }

  void _clearForm() {
    _titleController.clear();
    _artistController.clear();
    _albumController.clear();
    _genreController.clear();
    _durationController.clear();
    setState(() {
      _selectedAudioFile = null;
      _selectedImageFile = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _genreController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
