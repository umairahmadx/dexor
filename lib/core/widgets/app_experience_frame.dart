import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AppExperienceFrame extends StatefulWidget {
  const AppExperienceFrame({super.key, required this.child});

  final Widget child;

  @override
  State<AppExperienceFrame> createState() => _AppExperienceFrameState();
}

class _AppExperienceFrameState extends State<AppExperienceFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AppExperienceFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.child, widget.child)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final driftX = math.sin(t * math.pi * 2) * 18;
        final driftY = math.cos(t * math.pi * 2) * 14;

        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surface,
                      colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Stack(
                children: [
                  Positioned(
                    left: -72 + driftX,
                    top: -48 + driftY,
                    child: _GlowOrb(
                      color: colorScheme.primary.withValues(alpha: 0.13),
                      size: 220,
                    ),
                  ),
                  Positioned(
                    right: -84 - driftX,
                    bottom: -72 - driftY,
                    child: _GlowOrb(
                      color: colorScheme.secondary.withValues(alpha: 0.12),
                      size: 260,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: AppTokens.normal,
              switchInCurve: AppTokens.emphasizedCurve,
              switchOutCurve: AppTokens.standardCurve,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.015),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ObjectKey(widget.child),
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
