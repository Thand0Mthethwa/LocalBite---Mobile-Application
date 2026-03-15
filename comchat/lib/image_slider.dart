import 'dart:async';
import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _imageUrls = [
    'https://www.ekurhuleni.gov.za/about-the-city/priority-projects/urban-design/',
    'https://picsum.photos/seed/picsum/200/300',
    'https://picsum.photos/seed/picsum/200/300',
    'https://picsum.photos/seed/picsum/200/300',
    'https://picsum.photos/seed/picsum/200/300',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _imageUrls.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _imageUrls.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(_imageUrls[index], fit: BoxFit.cover);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_imageUrls.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              height: 8.0,
              width: _currentPage == index ? 24.0 : 8.0,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
      ],
    );
  }
}