import 'package:flutter/widgets.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';

typedef void PaintCallback(Canvas canvas, Size siz);

class ColorPainter extends CustomPainter {
  final Paint _paint;
  final TransformInfo info;
  final List<Color> colors;

  ColorPainter(this._paint, this.info, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    int index = info.fromIndex;
    _paint.color = colors[index];
    canvas.drawRect(
        new Rect.fromLTWH(0.0, 0.0, size.width, size.height), _paint);
    if (info.done) {
      return;
    }
    int alpha;
    int color;
    double opacity;
    double position = info.position;
    if (info.forward) {
      if (index < colors.length - 1) {
        color = colors[index + 1].value & 0x00ffffff;
        opacity = (position <= 0
            ? (-position / info.viewportFraction)
            : 1 - position / info.viewportFraction);
        if (opacity > 1) {
          opacity -= 1.0;
        }
        if (opacity < 0) {
          opacity += 1.0;
        }
        alpha = (0xff * opacity).toInt();

        _paint.color = new Color((alpha << 24) | color);
        canvas.drawRect(
            new Rect.fromLTWH(0.0, 0.0, size.width, size.height), _paint);
      }
    } else {
      if (index > 0) {
        color = colors[index - 1].value & 0x00ffffff;
        opacity = (position > 0
            ? position / info.viewportFraction
            : (1 + position / info.viewportFraction));
        if (opacity > 1) {
          opacity -= 1.0;
        }
        if (opacity < 0) {
          opacity += 1.0;
        }
        alpha = (0xff * opacity).toInt();

        _paint.color = new Color((alpha << 24) | color);
        canvas.drawRect(
            new Rect.fromLTWH(0.0, 0.0, size.width, size.height), _paint);
      }
    }
  }

  @override
  bool shouldRepaint(ColorPainter oldDelegate) {
    return oldDelegate.info != info;
  }
}

class _ParallaxColorState extends State<ParallaxColor> {
  Paint paint = new Paint();

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new ColorPainter(paint, widget.info, widget.colors),
      child: widget.child,
    );
  }
}

class ParallaxColor extends StatefulWidget {
  final Widget child;

  final List<Color> colors;

  final TransformInfo info;

  ParallaxColor({
    @required this.colors,
    @required this.info,
    @required this.child,
  });

  @override
  State<StatefulWidget> createState() {
    return new _ParallaxColorState();
  }
}

class ParallaxContainer extends StatelessWidget {
  final Widget child;
  final double position;
  final double translationFactor;
  final double opacityFactor;
  final Axis axis;

  ParallaxContainer(
      {@required this.child,
        @required this.position,
        this.translationFactor: 100.0,
        this.opacityFactor: 1.0,
        this.axis: Axis.horizontal})
      : assert(position != null),
        assert(translationFactor != null);

  @override
  Widget build(BuildContext context) {
    final translation = position * translationFactor;
    final opacity = (1 - position.abs()).clamp(0.0, 1.0) * opacityFactor;
    return Transform.translate(
      offset: new Offset(axis == Axis.horizontal ? translation : 0.0,
          axis == Axis.vertical ? translation : 0.0),
      child: !(opacity >= 0.0 && opacity <= 1.0)
          ? SizedBox()
          : Opacity(
          opacity: opacity,
          child: child),
    );
  }
}

class ParallaxImage extends StatelessWidget {
  final Widget image;
  final double imageFactor;

  ParallaxImage.asset(String name,
      {@required double position,
      this.imageFactor: 0.3,
      Axis axis = Axis.horizontal})
      : assert(imageFactor != null && position != null),
        image = Image.asset(name,
            fit: BoxFit.cover,
            alignment: FractionalOffset(
              axis == Axis.horizontal ? 0.5 + position * imageFactor : 0.5,
              axis == Axis.vertical   ? 0.5 + position * imageFactor : 0.5,
            ));

  ParallaxImage.cachedNetwork(String url,
      {@required double position,
      this.imageFactor: 0.3,
      PlaceholderWidgetBuilder placeholder,
      LoadingErrorWidgetBuilder errorWidget,
      Map<String, String> httpHeaders,
      Axis axis = Axis.horizontal})
      : assert(imageFactor != null && position != null),
        image = CachedNetworkImage(
            imageUrl: url,
            placeholder: placeholder,
            errorWidget: errorWidget,
            httpHeaders: httpHeaders,
            fit: BoxFit.cover,
            alignment: FractionalOffset(
              axis == Axis.horizontal ? 0.5 + position * imageFactor : 0.5,
              axis == Axis.vertical   ? 0.5 + position * imageFactor : 0.5,
            ));

  ParallaxImage.network(String url,
      {@required double position,
      this.imageFactor: 0.3,
      Map<String, String> httpHeaders,
      Axis axis = Axis.horizontal})
      : assert(imageFactor != null && position != null),
        image = Image.network(url,
            headers: httpHeaders,
            fit: BoxFit.cover,
            alignment: FractionalOffset(
              axis == Axis.horizontal ? 0.5 + position * imageFactor : 0.5,
              axis == Axis.vertical   ? 0.5 + position * imageFactor : 0.5,
            ));

  ParallaxImage.memory(Uint8List bytes,
      {@required double position,
      this.imageFactor: 0.3,
      Axis axis = Axis.horizontal})
      : assert(imageFactor != null && position != null),
        image = Image.memory(bytes,
            fit: BoxFit.cover,
            alignment: FractionalOffset(
              axis == Axis.horizontal ? 0.5 + position * imageFactor : 0.5,
              axis == Axis.vertical   ? 0.5 + position * imageFactor : 0.5,
            ));

  @override
  Widget build(BuildContext context) {
    return image;
  }
}
