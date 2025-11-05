import 'package:flutter/material.dart';

/// Custom logo widget for IPTV Casper
/// Creates a modern TV/streaming icon with gradient and effects
class AppLogo extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool showShadow;
  final bool animated;
  
  const AppLogo({
    super.key,
    this.size = 48,
    this.primaryColor,
    this.secondaryColor,
    this.showShadow = true,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? const Color(0xFF2196F3); // Blue
    final secondary = secondaryColor ?? const Color(0xFF9C27B0); // Purple
    
    Widget logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, secondary],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: primary.withOpacity(0.4),
                  blurRadius: size * 0.3,
                  offset: Offset(0, size * 0.1),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // TV screen outline
          Center(
            child: Container(
              width: size * 0.7,
              height: size * 0.55,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: size * 0.04,
                ),
                borderRadius: BorderRadius.circular(size * 0.08),
              ),
            ),
          ),
          // Play button in center
          Center(
            child: Icon(
              Icons.play_arrow_rounded,
              size: size * 0.35,
              color: Colors.white,
            ),
          ),
          // Signal waves (top-right corner)
          Positioned(
            top: size * 0.12,
            right: size * 0.12,
            child: Icon(
              Icons.wifi,
              size: size * 0.2,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
    
    if (animated) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: logo,
      );
    }
    
    return logo;
  }
}

/// Compact version of the logo for small spaces (like title bars)
class AppLogoCompact extends StatelessWidget {
  final double size;
  final Color? color;
  
  const AppLogoCompact({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            logoColor,
            logoColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Icon(
        Icons.live_tv_rounded,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }
}

/// Text logo with icon combination
class AppLogoWithText extends StatelessWidget {
  final double size;
  final Color? color;
  final String text;
  
  const AppLogoWithText({
    super.key,
    this.size = 32,
    this.color,
    this.text = 'IPTV Casper',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(
          size: size,
          primaryColor: color,
          showShadow: false,
        ),
        SizedBox(width: size * 0.3),
        Text(
          text,
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Animated splash logo with pulsing effect
class SplashLogo extends StatefulWidget {
  final double size;
  
  const SplashLogo({
    super.key,
    this.size = 120,
  });

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: AppLogo(
        size: widget.size,
        showShadow: true,
        primaryColor: const Color(0xFF2196F3),
        secondaryColor: const Color(0xFF9C27B0),
      ),
    );
  }
}
