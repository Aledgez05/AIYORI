import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class InspoImageCard extends StatefulWidget {
  final double height;
  const InspoImageCard({super.key, this.height = 190});

  @override
  State<InspoImageCard> createState() => _InspoImageCardState();
}

class _InspoImageCardState extends State<InspoImageCard> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;
  
  // Imágenes locales desde assets
  final List<String> _images = [
    'assets/images/inspo_1.jpg',
    'assets/images/inspo_2.jpg',
    'assets/images/inspo_3.jpg',
    'assets/images/inspo_4.jpg',
    'assets/images/inspo_5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  _images[index],
                  width: double.infinity,
                  height: widget.height,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.image_not_supported, color: AppColors.primary, size: 40),
                  ),
                );
              },
            ),
            // Indicadores de página
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: _currentPage == index 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}