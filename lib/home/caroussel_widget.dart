import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';

final List<Uri> videoList = [
  Uri.parse(
      'https://jtxkuotixiytftaxidmv.supabase.co/storage/v1/object/public/media-content/videos/seances/1795797-hd_1920_1080_30fps.mp4?t=2024-12-07T00%3A57%3A59.505Z'),
  Uri.parse(
      'https://jtxkuotixiytftaxidmv.supabase.co/storage/v1/object/public/media-content/videos/seances/3040808-uhd_3840_2160_30fps.mp4?t=2024-12-07T00%3A59%3A47.152Z'),
  Uri.parse(
      'https://jtxkuotixiytftaxidmv.supabase.co/storage/v1/object/public/media-content/videos/seances/855282-hd_1280_720_25fps.mp4'),
];

class VideoPlayerWidget extends StatefulWidget {
  final Uri url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(widget.url),
      autoPlay: false,
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlickVideoPlayer(flickManager: flickManager);
  }
}

final List<Widget> videoSliders = videoList
    .map((item) => Container(
          margin: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Text("Video ${videoList.indexOf(item)}"),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: VideoPlayerWidget(url: item),
              ),
            ],
          ),
        ))
    .toList();

class CustomCarousel extends StatefulWidget {
  const CustomCarousel({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<CustomCarousel> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CarouselSlider(
        items: videoSliders,
        carouselController: _controller,
        options: CarouselOptions(
            enlargeCenterPage: true,
            enlargeFactor: 0.35,
            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            }),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: videoList.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 12.0,
              height: 12.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(_current == entry.key ? 0.9 : 0.4)),
            ),
          );
        }).toList(),
      ),
    ]);
  }
}
