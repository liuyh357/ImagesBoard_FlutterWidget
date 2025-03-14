import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:simple_canvas/images_board.dart';
import 'package:simple_canvas/images_board_item_img.dart';


class DraggableImage extends StatefulWidget {
  const DraggableImage(
      {super.key,
      required this.width,
      required this.height,
      required this.imgPath});

  final double width;
  final double height;
  final String imgPath;

  @override
  State<StatefulWidget> createState() {
    return _DraggableImageState();
  }
}

class _DraggableImageState extends State<DraggableImage> {
  bool isDragging = false;
  Offset draggingPosition = Offset.zero;
  Offset globalDraggingPosition = Offset.zero;
  Offset firstDraggingPosition = Offset.zero;
  Offset globalFirstDraggingPosition = Offset.zero;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ImagesBoardManager().loadImage(widget.imgPath),
      builder: (BuildContext context, AsyncSnapshot img) {
        if (img.hasData) {
          return Listener(
            onPointerDown: (event) {
              setState(() {
                isDragging = true;
                draggingPosition = event.localPosition;
                globalDraggingPosition = event.position;
                firstDraggingPosition = event.localPosition;
                globalFirstDraggingPosition = event.position;
              });
            },
            onPointerUp: (event) {
              setState(() {
                isDragging = false;
                double scale = min((widget.width - 15) / img.data.width,
                    (widget.height - 15) / img.data.height);
                var scaleImgWidth = img.data.width.toDouble() * scale;
                var scaleImgHeight = img.data.height.toDouble() * scale;
                var centerXOffset = (widget.width - scaleImgWidth) / 2;
                var centerYOffset = (widget.height - scaleImgHeight) / 2;
                Offset center = Offset(
                    globalDraggingPosition.dx -
                        firstDraggingPosition.dx +
                        centerXOffset +
                        scaleImgWidth / 2,
                    globalDraggingPosition.dy -
                        firstDraggingPosition.dy +
                        centerYOffset +
                        scaleImgHeight / 2);
                var inBoardArea =
                    ImagesBoardManager().inBoardArea(event.position);
                if (inBoardArea) {
                  var imageItem = ImageItem(
                    imgPath: widget.imgPath,
                    globalPosition: center,
                    scale: 1/ImagesBoardManager().scale,
                    width: scaleImgWidth,
                    height: scaleImgHeight,
                    image: img.data,
                    code: DateTime.now().millisecondsSinceEpoch,
                  );
                  ImagesBoardManager().addImageItem(imageItem);
                }
              });
            },
            onPointerMove: (event) {
              if (isDragging) {
                setState(() {
                  draggingPosition = event.localPosition;
                  globalDraggingPosition = event.position;
                });
              }
            },
            child: CustomPaint(
              painter: DraggableImagePainter(
                  image: img.data,
                  isDragging: isDragging,
                  draggingPosition: draggingPosition,
                  imgWidth: widget.width,
                  imgHeight: widget.height,
                  firstDraggingPositon: firstDraggingPosition),
              size: Size(widget.width, widget.height),
            ),
          );
        }
        return Container();
      },
    );
  }
}

class DraggableImagePainter extends CustomPainter {
  ui.Image image;
  bool isDragging;
  Offset draggingPosition;
  Offset firstDraggingPositon;
  double imgWidth;
  double imgHeight;
  DraggableImagePainter(
      {required this.image,
      this.isDragging = false,
      this.draggingPosition = Offset.zero,
      this.imgWidth = 100,
      this.imgHeight = 100,
      this.firstDraggingPositon = Offset.zero});
  @override
  void paint(Canvas canvas, Size size) {
    Rect src =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    double scale =
        min((imgWidth - 15) / image.width, (imgHeight - 15) / image.height);
    var scaleImgWidth = image.width.toDouble() * scale;
    var scaleImgHeight = image.height.toDouble() * scale;
    Rect dst = Rect.fromLTWH((imgWidth - scaleImgWidth) / 2,
        (imgHeight - scaleImgHeight) / 2, scaleImgWidth, scaleImgHeight);
    RRect rrect = RRect.fromRectAndRadius(dst, Radius.circular(10));

    Rect shadowRec =
        Rect.fromLTWH(dst.left, dst.top, scaleImgWidth, scaleImgHeight);
    var shadowRRec = RRect.fromRectAndRadius(shadowRec, Radius.circular(10));
    canvas.drawRRect(
        shadowRRec,
        Paint()
          ..color = Colors.black.withAlpha(80)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4));

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawImageRect(image, src, dst, Paint());
    canvas.restore();

    if (isDragging) {
      var draggingDx = draggingPosition.dx;
      var draggingDy = draggingPosition.dy;

      // print('dst img width: ${dst.width} height: ${dst.height}');

      dst = Rect.fromLTWH(
          draggingDx - firstDraggingPositon.dx + dst.left,
          draggingDy - firstDraggingPositon.dy + dst.top,
          dst.width,
          dst.height);
      RRect rrect = RRect.fromRectAndRadius(dst, Radius.circular(10));

      Rect shadowRec = Rect.fromLTWH(dst.left, dst.top, dst.width, dst.height);
      var shadowRRec = RRect.fromRectAndRadius(shadowRec, Radius.circular(10));
      canvas.drawRRect(
          shadowRRec,
          Paint()
            ..color = Colors.black.withAlpha(100)
            ..style = PaintingStyle.fill
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4));

      canvas.save();

      canvas.clipRRect(rrect);
      canvas.drawImageRect(image, src, dst, Paint());
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

