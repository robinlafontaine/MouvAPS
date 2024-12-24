import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/services/download.dart';
import 'package:mouvaps/utils/constants.dart' as constants;

class DownloadButton<T> extends StatefulWidget {
  final T item;
  final List<DownloadRequest> downloadRequests;
  final Future<void> Function(List<String> paths) onSave;
  final Function(T) onDownloadComplete;
  final bool isEnabled;

  const DownloadButton({
    super.key,
    required this.item,
    required this.downloadRequests,
    required this.onSave,
    required this.onDownloadComplete,
    this.isEnabled = true,
  });

  @override
  State<DownloadButton<T>> createState() => _DownloadButtonState<T>();
}

class _DownloadButtonState<T> extends State<DownloadButton<T>> {
  final DownloadManager _downloadManager = DownloadManager();
  String _itemId = '';
  bool _isDownloading = false;
  double _progress = 0;
  StreamSubscription<double>? _progressSubscription;
  final Logger _logger = Logger(printer: SimplePrinter());

  @override
  void initState() {
    super.initState();
    _initializeItemId();
    _restoreDownloadState();
  }

  @override
  void didUpdateWidget(covariant DownloadButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _initializeItemId();
      _restoreDownloadState();
    }
  }

  @override
  void dispose() {
    _cleanupSubscription();
    super.dispose();
  }

  void _initializeItemId() {
    try {
      _itemId = widget.item.hashCode.toString();
    } catch (e) {
      _itemId = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  void _restoreDownloadState() {
    if (_itemId.isEmpty) {
      _logger.e('Cannot restore download state', error: 'Empty _itemId');
      return;
    }

    if (_downloadManager.isDownloading(_itemId)) {
      _updateDownloadState(
        isDownloading: true,
        progress: _downloadManager.getCurrentProgress(_itemId),
      );
      _setupProgressSubscription();
    } else {
      _resetDownloadState();
    }
  }

  Future<void> _handleDownload() async {
    if (_itemId.isEmpty) {
      _logger.e('Cannot start download', error: 'Empty _itemId');
      return;
    }

    if (_isDownloading) {
      await _cancelDownload();
      return;
    }

    await _startNewDownload();
  }

  Future<void> _startNewDownload() async {
    _updateDownloadState(isDownloading: true, progress: 0);

    try {
      final downloadFuture = _downloadManager.downloadFiles(
          widget.downloadRequests,
          _itemId
      );

      _setupProgressSubscription();

      final paths = await downloadFuture;

      await widget.onSave(paths);
      widget.onDownloadComplete(widget.item);

      if (mounted) {
        _updateDownloadState(isDownloading: false, progress: 1.0);
      }
    } catch (e) {
      _logger.e('Download error', error: e);
      if (mounted) {
        _handleDownloadError();
      }
    }
  }

  Future<void> _cancelDownload() async {
    _cleanupSubscription();
    _downloadManager.cancelDownload(_itemId);
    _resetDownloadState();
  }

  void _setupProgressSubscription() {
    _cleanupSubscription();

    final stream = _downloadManager.getProgress(_itemId);
    if (stream != null && mounted) {
      _progressSubscription = stream.listen(
        _handleProgressUpdate,
        onError: _handleProgressError,
        onDone: _handleProgressComplete,
      );
    } else {
      _logger.e('Failed to set up progress subscription for $_itemId');
    }
  }

  void _handleProgressUpdate(double progress) {
      _updateDownloadState(isDownloading: true, progress: progress);
  }

  void _handleProgressError(dynamic error) {
    if (mounted) {
      _resetDownloadState();
    }
  }

  void _handleProgressComplete() {
    if (mounted && _progress < 1.0) {
      _resetDownloadState();
    }
  }

  void _updateDownloadState({required bool isDownloading, required double progress}) {
    setState(() {
      _isDownloading = isDownloading;
      _progress = progress;
    });
  }

  void _resetDownloadState() {
    _updateDownloadState(isDownloading: false, progress: 0);
  }

  void _handleDownloadError() {
    _resetDownloadState();
    _showErrorMessage();
  }

  void _cleanupSubscription() {
    if (_progressSubscription != null) {
      _progressSubscription?.cancel();
      _progressSubscription = null;
    }
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download failed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: widget.isEnabled ? _handleDownload : null,
        icon: _buildButtonIcon(),
      ),
    );
  }

  Widget _buildButtonIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isDownloading)
          CircularProgressIndicator(
            value: _progress,
            color: constants.primaryColor,
            backgroundColor: constants.unselectedColor,
          ),
        Icon(
          _isDownloading ? Icons.close : Icons.download,
          color: constants.primaryColor,
        ),
      ],
    );
  }
}