import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mouvaps/utils/constants.dart' as constants;

class RecipeDownloadButton extends StatefulWidget {
  final Recipe recipe;
  final bool isEnabled;
  final Function(Recipe) onDownloadComplete;

  const RecipeDownloadButton({
    super.key,
    required this.recipe,
    this.isEnabled = true,
    required this.onDownloadComplete,
  });

  @override
  State<RecipeDownloadButton> createState() => _RecipeDownloadButtonState();
}

class _RecipeDownloadButtonState extends State<RecipeDownloadButton> {
  bool _isDownloading = false;
  double _progress = 0;
  final double _totalSteps = 2;

  Future<void> _startDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      final Dio dio = Dio();
      var tempDir = await getTemporaryDirectory();
      var videoPath = '${tempDir.path}/r_${widget.recipe.name}_v.${widget.recipe.videoUrl.split('.').last}';
      var thumbnailPath = '${tempDir.path}/r_${widget.recipe.name}_t.${widget.recipe.imageUrl.split('.').last}';

      await dio.download(
          widget.recipe.imageUrl,
          thumbnailPath,
          onReceiveProgress: (received, total) {
            setState(() {
              _progress = (received / total) * (1 / _totalSteps);
            });
          }
      );

      await dio.download(
          widget.recipe.videoUrl,
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

      await Recipe.saveLocalRecipe(widget.recipe, videoPath, thumbnailPath).then((value){
        widget.onDownloadComplete(widget.recipe);
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