import 'package:impact_loop/core/exports.dart';

// Amer
class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.image,
    this.isUser = false,
    this.height,
    this.width,
  });

  final String image;
  final bool isUser;
  final double? height;
  final double? width;

  String _resolveImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('/')) {
      return 'https://api.impact-loop.dawava.me$trimmed';
    }
    if (trimmed.startsWith('http://api.impact-loop.dawava.me')) {
      return trimmed.replaceFirst('http://', 'https://');
    }
    if (trimmed.contains('127.0.0.1:3000') ||
        trimmed.contains('localhost:3000') ||
        trimmed.contains('10.0.2.2:3000') ||
        trimmed.contains('192.168.')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.path.isNotEmpty) {
        return 'https://api.impact-loop.dawava.me${uri.path}';
      }
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveImageUrl(image);
    return Image.network(resolvedUrl,
        fit: BoxFit.cover,
        height: height,
        width: width,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Image.asset(
              isUser ? ImageAssets.profileDefault : ImageAssets.logoImage,
              height: height,
              width: width,
              fit: BoxFit.cover,
            ));
  }
}
