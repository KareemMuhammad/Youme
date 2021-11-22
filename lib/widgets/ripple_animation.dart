import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:umee/widgets/curve.dart';
import 'package:umee/widgets/painter.dart';



class RippleAnimation extends StatefulWidget {
  const RippleAnimation({Key key, this.size = 80.0, this.color = Colors.lightBlue,
    this.onPressed}) : super(key: key);
  final double size;
  final Color color;
  final VoidCallback onPressed;
  @override
  _RippleAnimationState createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation> with TickerProviderStateMixin {
  AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                widget.color,
                Color.lerp(widget.color, Colors.black, .05)
              ],
            ),
          ),
          child: ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const CurveWave(),
                ),
              ),
              child: GestureDetector(
                  onTap: widget.onPressed,
                  child: Icon(Icons.mic, size: 44,)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Center(
        child: CustomPaint(
          painter: CirclePainter(
            _controller,
            color: widget.color,
          ),
          child: SizedBox(
            width: widget.size * 4.125,
            height: widget.size * 4.125,
            child: _button(),
          ),
        ),
      );
  }
}