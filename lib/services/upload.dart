import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth.dart';

class UploadRequest {
  final File file;
  final String fileName;
  bool isUploading;
  double progress;
  String? error;

  UploadRequest({
    required this.file,
    required this.fileName,
    this.isUploading = false,
    this.progress = 0.0,
    this.error,
  });

  UploadRequest copyWith({
    bool? isUploading,
    double? progress,
    String? error,
  }) {
    return UploadRequest(
      file: file,
      fileName: fileName,
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}

class UploadManager {
  final String bucketName;
  final SupabaseClient supabase = Supabase.instance.client;
  final void Function(List<UploadRequest>) onRequestsChanged;

  final List<UploadRequest> _requests = [];
  bool _isUploading = false;

  bool get isUploading => _isUploading;
  List<UploadRequest> get requests => List.unmodifiable(_requests);

  UploadManager({
    required this.bucketName,
    required this.onRequestsChanged,
  });

  void addFiles(List<PlatformFile> files) {
    final newRequests = files.map((file) => UploadRequest(
      file: File(file.path!),
      fileName: file.name,
    )).toList();

    _requests.addAll(newRequests);
    onRequestsChanged(_requests);
  }

  void removeFile(int index) {
    _requests.removeAt(index);
    onRequestsChanged(_requests);
  }

  Future<void> uploadFiles() async {
    if (_requests.isEmpty) return;
    _isUploading = true;
    onRequestsChanged(_requests);

    try {
      for (var i = 0; i < _requests.length; i++) {
        final request = _requests[i];
        _updateRequest(i, isUploading: true, progress: 0, error: null);

        try {
          await supabase.storage
              .from(bucketName)
              .upload(
                bucketName == 'user-data'
                    ? '${Auth.instance.getUUID()}/${request.fileName}'
                    : request.fileName,
                request.file,
              );

          _updateRequest(i, isUploading: false, progress: 1.0);
        } catch (e) {
          _updateRequest(i, isUploading: false, error: e.toString());
        }
      }
    } finally {
      _isUploading = false;
      onRequestsChanged(_requests);
    }
  }

  void _updateRequest(
      int index, {
        bool? isUploading,
        double? progress,
        String? error,
      }) {
    _requests[index] = _requests[index].copyWith(
      isUploading: isUploading,
      progress: progress,
      error: error,
    );
    onRequestsChanged(_requests);
  }

  void clear() {
    _requests.clear();
    onRequestsChanged(_requests);
  }
}