import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/home/player_widget.dart';
import 'package:mouvaps/services/exercise.dart';

class CustomCarousel extends StatefulWidget {
  const CustomCarousel({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<CustomCarousel> {
  Logger logger = Logger();
  final Future<List<Exercise>> _exercises = Exercise.getAll();
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _exercises,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(children: [
            CarouselSlider(
              items: snapshot.data!.map((content) {
                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      child: VideoPlayerWidget(url: Uri.parse(content.url), requiresAuth: true),
                    );
                  },
                );
              }).toList(),
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
              children: snapshot.data!.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            .withValues(alpha: _current == entry.key ? 0.9 : 0.4)),
                  ),
                );
              }).toList(),
            ),
          ]);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
