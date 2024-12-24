import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class DownloadTask {
  final String url;
  final String destination;
  final CancelToken cancelToken;
  final Completer<String> completer;
  final String groupId;
  double currentProgress = 0.0;

  DownloadTask({
    required this.url,
    required this.destination,
    required this.cancelToken,
    required this.completer,
    required this.groupId,
  });
}

class DownloadRequest {
  final String url;
  final String filename;
  final String fileExtension;

  DownloadRequest({
    required this.url,
    required this.filename,
    required this.fileExtension,
  });
}

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final Map<String, List<DownloadTask>> _activeDownloads = {};
  final Map<String, StreamController<double>> _groupProgressControllers = {};
  final Logger _logger = Logger(printer: SimplePrinter());
  final Dio _dio = Dio();

  Stream<double>? getProgress(String groupId) {
    return _groupProgressControllers[groupId]?.stream;
  }

  void _updateGroupProgress(String groupId) {
    final tasks = _activeDownloads[groupId];
    final controller = _groupProgressControllers[groupId];

    if (tasks != null && controller != null) {
      double totalProgress = 0;
      for (var task in tasks) {
        totalProgress += task.currentProgress;
      }

      final averageProgress = totalProgress / tasks.length;

      if (!controller.isClosed) {
        controller.add(averageProgress);
      }
    }
  }

  Future<List<String>> downloadFiles(List<DownloadRequest> requests, String groupId) async {
    final List<String> paths = [];
    final List<DownloadTask> tasks = [];

    _groupProgressControllers[groupId] = StreamController<double>.broadcast();

    for (var request in requests) {
      final tempDir = await getTemporaryDirectory();
      final destination = '${tempDir.path}/${request.filename}.${request.fileExtension}';

      final cancelToken = CancelToken();
      final completer = Completer<String>();

      final task = DownloadTask(
        url: request.url,
        destination: destination,
        cancelToken: cancelToken,
        completer: completer,
        groupId: groupId,
      );

      tasks.add(task);
    }

    _activeDownloads[groupId] = tasks;

    try {
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        final request = requests[i];

        unawaited(_dio.download(
          request.url,
          task.destination,
          cancelToken: task.cancelToken,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              task.currentProgress = received / total;
              _updateGroupProgress(groupId);
            }
          },
        ).then((_) {
          task.completer.complete(task.destination);
        }).catchError((error) {
          _logger.e('Download error: $error');
          if (!task.cancelToken.isCancelled) {
            task.completer.completeError(error);
          }
        }));

        final path = await task.completer.future;
        paths.add(path);
      }
    } catch (e) {
      _logger.e('Download error in downloadFiles: $e');
      cancelDownload(groupId);
      rethrow;
    } finally {
      _groupProgressControllers[groupId]?.close();
      _groupProgressControllers.remove(groupId);
      _activeDownloads.remove(groupId);
    }

    return paths;
  }

  void cancelDownload(String groupId) {
    final tasks = _activeDownloads[groupId];
    if (tasks != null) {
      for (var task in tasks) {
        task.cancelToken.cancel('Download cancelled by user');
      }
      _groupProgressControllers[groupId]?.close();
      _groupProgressControllers.remove(groupId);
      _activeDownloads.remove(groupId);
    }
  }

  double getCurrentProgress(String groupId) {
    final tasks = _activeDownloads[groupId];
    if (tasks == null || tasks.isEmpty) return 0.0;

    double totalProgress = 0;
    for (var task in tasks) {
      totalProgress += task.currentProgress;
    }
    return totalProgress / tasks.length;
  }

  bool isDownloading(String groupId) {
    return _activeDownloads.containsKey(groupId);
  }
}
