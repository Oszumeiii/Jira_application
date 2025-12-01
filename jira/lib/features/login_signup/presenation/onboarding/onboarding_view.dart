import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/onboard1.png',
      'title': 'Organize Your Projects',
      'desc':
          'Keep all your tasks, deadlines, and goals in one place. Manage projects effortlessly and stay productive every day.',
    },
    {
      'image': 'assets/images/onboard2.png',
      'title': 'Collaborate With Your Team',
      'desc':
          'Work together seamlessly. Assign tasks, share updates, and track progress in real time with your teammates.',
    },
    {
      'image': 'assets/images/onboard3.png',
      'title': 'Stay On Top Of Deadlines',
      'desc':
          'Receive smart reminders and notifications so you never miss an important milestone again.',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _skip() {
    _controller.jumpToPage(_pages.length - 1);
  }

  void _goToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (_, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 30.h),
                        Image.asset(
                          page['image']!,
                          height: 200.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 60.h),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          page['desc']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  height: 8.h,
                  width: _currentPage == index ? 24.w : 8.w,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.deepPurple
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage < _pages.length - 1
                      ? TextButton(
                          onPressed: _skip,
                          child: Text(
                            'Skip',
                            style: TextStyle(color: Colors.black54, fontSize: 16.sp),
                          ),
                        )
                      : SizedBox(width: 70.w),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.all(16.w),
                    ),
                    child: Icon(
                      _currentPage == _pages.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
