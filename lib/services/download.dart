import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadTask {
  final String url;
  final String destination;
  final CancelToken cancelToken;
  final Completer<String> completer;
  double progress = 0.0;

  DownloadTask({
    required this.url,
    required this.destination,
    required this.cancelToken,
    required this.completer,
  });
}

class DownloadRequest {
  final String url;
  final String filename;
  final String fileExtension;

  const DownloadRequest({
    required this.url,
    required this.filename,
    required this.fileExtension,
  });
}

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final _activeDownloads = <String, List<DownloadTask>>{};
  final _progressControllers = <String, StreamController<double>>{};
  final _dio = Dio();

  Stream<double>? getProgress(String groupId) {
    if (isDownloading(groupId)) {
      _progressControllers[groupId]?.close();
      _progressControllers[groupId] = StreamController<double>.broadcast();
      _progressControllers[groupId]?.add(getCurrentProgress(groupId));
    }
    return _progressControllers[groupId]?.stream;
  }

  void _updateProgress(String groupId) {
    final tasks = _activeDownloads[groupId];
    if (tasks == null || tasks.isEmpty) return;

    final averageProgress = tasks.fold<double>(
        0,
            (sum, task) => sum + task.progress
    ) / tasks.length;

    _progressControllers[groupId]?.add(averageProgress);
  }

  Future<List<String>> downloadFiles(
      List<DownloadRequest> requests,
      String groupId,
      ) async {
    _progressControllers[groupId] = StreamController<double>.broadcast();

    _progressControllers[groupId]!.add(0.0);

    final tasks = await _createDownloadTasks(requests);
    _activeDownloads[groupId] = tasks;

    try {
      return await _executeDownloads(tasks, groupId);
    } finally {
      _cleanup(groupId);
    }
  }

  Future<List<DownloadTask>> _createDownloadTasks(
      List<DownloadRequest> requests,
      ) async {
    final tempDir = await getTemporaryDirectory();

    return requests.map((request) {
      final destination = '${tempDir.path}/${request.filename}.${request.fileExtension}';
      return DownloadTask(
        url: request.url,
        destination: destination,
        cancelToken: CancelToken(),
        completer: Completer<String>(),
      );
    }).toList();
  }

  Future<List<String>> _executeDownloads(
      List<DownloadTask> tasks,
      String groupId,
      ) async {
    final futures = tasks.map((task) => _downloadFile(task, groupId));
    final paths = await Future.wait(futures);
    return paths;
  }

  Future<String> _downloadFile(DownloadTask task, String groupId) async {
    try {
      await _dio.download(
        task.url,
        task.destination,
        cancelToken: task.cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            task.progress = received / total;
            _updateProgress(groupId);
          }
        },
      );
      task.completer.complete(task.destination);
    } catch (e) {
      if (!task.cancelToken.isCancelled) {
        task.completer.completeError(e);
      }
    }
    return task.completer.future;
  }

  void _cleanup(String groupId) {
    _progressControllers[groupId]?.close();
    _progressControllers.remove(groupId);
    _activeDownloads.remove(groupId);
  }

  void cancelDownload(String groupId) {
    final tasks = _activeDownloads[groupId];
    if (tasks != null) {
      for (var task in tasks) {
        task.cancelToken.cancel("Téléchargement annulé par l'utilisateur");
      }
      _cleanup(groupId);
    }
  }

  double getCurrentProgress(String groupId) {
    final tasks = _activeDownloads[groupId];
    if (tasks == null || tasks.isEmpty) return 0.0;

    return tasks.fold<double>(0, (sum, task) => sum + task.progress) / tasks.length;
  }

  bool isDownloading(String groupId) => _activeDownloads.containsKey(groupId);
}