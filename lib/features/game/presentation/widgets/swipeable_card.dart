import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/situation.dart';

class SwipeableCard extends StatefulWidget {
  final Situation situation;
  final String categoryName;
  final bool isVoted;
  final Function(Choice) onVote;

  const SwipeableCard({
    super.key,
    required this.situation,
    required this.categoryName,
    required this.isVoted,
    required this.onVote,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _swipeAnimation;
  Offset _dragOffset = Offset.zero;
  final double _swipeThreshold = 120.0;


  bool _hasVibratedForThreshold = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_animationController);
  }

  @override
  void didUpdateWidget(covariant SwipeableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.situation.id != widget.situation.id) {
      _dragOffset = Offset.zero;
      _hasVibratedForThreshold = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _runAnimation(Offset target, {bool flyOut = false, Choice? choice}) {
    _swipeAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: flyOut ? Curves.fastOutSlowIn : Curves.easeOutBack,
      ),
    );

    _animationController.forward(from: 0.0).then((_) {
      if (flyOut && choice != null) {
        widget.onVote(choice);
      }
      setState(() {
        _dragOffset = target;
      });
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.isVoted || _animationController.isAnimating) return;

    final double nextX = _dragOffset.dx + details.delta.dx;



    if (nextX.abs() > _swipeThreshold && !_hasVibratedForThreshold) {
      HapticFeedback.selectionClick();
      _hasVibratedForThreshold = true;
    }

    else if (nextX.abs() <= _swipeThreshold && _hasVibratedForThreshold) {
      _hasVibratedForThreshold = false;
    }

    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (widget.isVoted || _animationController.isAnimating) return;

    final screenWidth = MediaQuery.of(context).size.width;

    if (_dragOffset.dx > _swipeThreshold) {

      HapticFeedback.mediumImpact();
      final target = Offset(screenWidth * 1.5, _dragOffset.dy * 1.5);
      _runAnimation(target, flyOut: true, choice: Choice.base);
    } else if (_dragOffset.dx < -_swipeThreshold) {

      HapticFeedback.mediumImpact();
      final target = Offset(-screenWidth * 1.5, _dragOffset.dy * 1.5);
      _runAnimation(target, flyOut: true, choice: Choice.cringe);
    } else {
      _runAnimation(Offset.zero);
    }

    _hasVibratedForThreshold = false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animatedOffset = _animationController.isAnimating ? _swipeAnimation.value : _dragOffset;
        final double animatedAngle = (animatedOffset.dx / 350) * (pi / 12);

        return GestureDetector(
          onPanUpdate: _onDragUpdate,
          onPanEnd: _onDragEnd,
          child: Transform.translate(
            offset: widget.isVoted ? Offset.zero : animatedOffset,
            child: Transform.rotate(
              angle: widget.isVoted ? 0.0 : animatedAngle,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Card(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentPurple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.categoryName,
                                style: const TextStyle(
                                  color: AppTheme.accentPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            widget.situation.text,
                            style: AppTheme.darkTheme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!widget.isVoted && animatedOffset.dx > 10)
                    Positioned(
                      top: 24,
                      left: 24,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Opacity(
                          opacity: (animatedOffset.dx / _swipeThreshold).clamp(0.0, 1.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.neonGreen, width: 4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'БАЗА',
                              style: TextStyle(
                                color: AppTheme.neonGreen,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!widget.isVoted && animatedOffset.dx < -10)
                    Positioned(
                      top: 24,
                      right: 24,
                      child: Transform.rotate(
                        angle: 0.2,
                        child: Opacity(
                          opacity: (animatedOffset.dx.abs() / _swipeThreshold).clamp(0.0, 1.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.neonRed, width: 4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'КРИНЖ',
                              style: TextStyle(
                                color: AppTheme.neonRed,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
