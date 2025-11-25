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
    final first = words.first[0].toUpperCase();
    final second = words.length > 1 ? words.last[0].toUpperCase() : '';
    return second.isEmpty ? first : '$first$second';
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
      backgroundColor: Colors.grey.shade300,
      child: Text(
        _getInitial(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildLoading(double diameter) {
    return Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: SizedBox(
        width: radius * 0.8,
        height: radius * 0.8,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.grey.shade600),
        ),
      ),
    );
  }
}
