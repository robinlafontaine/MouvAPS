import 'dart:async';
import 'package:flutter/material.dart';
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
  late final String _itemId;
  bool _isDownloading = false;
  bool isCompleted = false;
  double _progress = 0;
  StreamSubscription<double>? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _itemId = widget.item.toString();
    _checkDownloadState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkDownloadState();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }

  void _checkDownloadState() {
    if (_downloadManager.isDownloading(_itemId)) {
      _initializeDownload();
    }
  }

  void _initializeDownload() {
    final currentProgress = _downloadManager.getCurrentProgress(_itemId);
    _updateState(true, currentProgress);
    _subscribeToProgress();
  }

  void _subscribeToProgress() {
    _progressSubscription?.cancel();

    final stream = _downloadManager.getProgress(_itemId);
    if (stream != null) {
      _progressSubscription = stream.listen(
            (progress) => _updateState(true, progress),
        onError: (_) => _resetState(),
        onDone: () => _checkDownloadState(),
      );
    }
  }

  Future<void> _handleDownload() async {
    if (_isDownloading) {
      await _cancelDownload();
      return;
    }

    _updateState(true, 0);
    try {
      final downloadFuture = _downloadManager.downloadFiles(
        widget.downloadRequests,
        _itemId,
      );

      _subscribeToProgress();

      final paths = await downloadFuture;

      await widget.onSave(paths);
      isCompleted = true;
      widget.onDownloadComplete(widget.item);

      if (mounted) {
        _updateState(false, 1.0);
      }
    } catch (e) {
      if (mounted) {
        _showError();
        _resetState();
      }
    }
  }

  Future<void> _cancelDownload() async {
    _downloadManager.cancelDownload(_itemId);
    _resetState();
  }

  void _updateState(bool isDownloading, double progress) {
    if (mounted) {
      setState(() {
        _isDownloading = isDownloading;
        _progress = progress;
      });
    }
  }

  void _resetState() => _updateState(false, 0);

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Une erreur est survenue lors du téléchargement')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: widget.isEnabled ? _handleDownload : null,
        icon: Stack(
          alignment: Alignment.center,
          children: [
            if (_isDownloading)
              CircularProgressIndicator(
                value: _progress,
                color: constants.primaryColor,
                backgroundColor: constants.unselectedColor,
              ),
            Icon(
              _isDownloading ? Icons.close : (isCompleted ? Icons.check_circle_outlined : Icons.download),
              color: constants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}