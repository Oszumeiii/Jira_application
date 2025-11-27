import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? url;
  final String? initials;
  final double radius;

  const AvatarWidget({super.key, this.url, this.initials, this.radius = 24});

  String _getInitial() {
    final text = (initials ?? '').trim();
    if (text.isEmpty) return '?';

    final words = text.split(' ');
    if (words.length == 1) {
      final word = words.first;
      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word[0].toUpperCase();
    }

    final first = words.first[0].toUpperCase();
    final second = words.last[0].toUpperCase();
    return '$first$second';
  }

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final hasValidUrl = url != null && url!.trim().isNotEmpty;

    if (!hasValidUrl) {
      return _buildFallback(diameter);
    }

    return SizedBox(
      width: diameter,
      height: diameter,
      child: ClipOval(
        child: Image.network(
          url!,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          cacheWidth: (diameter * 3).round(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoading(diameter);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallback(diameter);
          },
        ),
      ),
    );
  }

  Widget _buildFallback(double diameter) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color.fromARGB(255, 26, 76, 224).withOpacity(0.9),
      child: Text(
        _getInitial(),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.7,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoading(double diameter) {
    return Container(
      color: const Color.fromARGB(255, 26, 76, 224).withOpacity(0.9),
      alignment: Alignment.center,
      child: SizedBox(
        width: radius * 0.8,
        height: radius * 0.8,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      ),
    );
  }
}
