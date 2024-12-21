import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mouvaps/utils/constants.dart' as constants;

class DownloadButton extends StatefulWidget {
  final Exercise exercise;
  final bool isEnabled;
  final Function(Exercise) onDownloadComplete;

  const DownloadButton({
    super.key,
    required this.exercise,
    this.isEnabled = true,
    required this.onDownloadComplete,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _isDownloading = false;
  double _progress = 0;
  final double _totalSteps = 4;

  Future<void> _startDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      final Dio dio = Dio();
      var tempDir = await getTemporaryDirectory();
      var videoPath = '${tempDir.path}/${widget.exercise.name}_v.${widget.exercise.url.split('.').last}';
      var thumbnailPath = '${tempDir.path}/${widget.exercise.name}_t.${widget.exercise.thumbnailUrl.split('.').last}';

      await dio.download(
          widget.exercise.thumbnailUrl,
          thumbnailPath,
          onReceiveProgress: (received, total) {
            setState(() {
              _progress = (received / total) * (1 / _totalSteps);
            });
          }
      );

      await dio.download(
          widget.exercise.url,
          videoPath,
          onReceiveProgress: (received, total) {
            setState(() {
              _progress = (1 / _totalSteps) + (received / total) * (1 / _totalSteps);
            });
          }
      );

      setState(() {
        _progress = 1.0;
        _isDownloading = false;
      });

      await Exercise.saveLocalExercise(widget.exercise, videoPath, thumbnailPath).then((value){
        widget.onDownloadComplete(widget.exercise);
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _progress = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Echec du téléchargement !')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: (_isDownloading || !widget.isEnabled) ? null : _startDownload,
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
              _isDownloading ? Icons.download_done : Icons.download,
              color: _isDownloading ? Colors.white : constants.primaryColor,
            ),
            //TODO: Fix showing download_done icon when done
          ],
        ),
      ),
    );
  }
}