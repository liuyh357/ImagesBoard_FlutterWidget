import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // 新增导入
import 'dart:ui' as ui;

import 'package:provider/provider.dart';
import 'package:simple_canvas/images_board_item.dart';
import 'package:simple_canvas/images_board_item_img.dart';

class ImagesBoardManager with ChangeNotifier {
  static final ImagesBoardManager _instance = ImagesBoardManager._internal();

  ImagesBoardManager._internal();

  factory ImagesBoardManager() => _instance;

  Offset globalOffset = Offset.zero;

  Offset boardOffset = Offset.zero;

  var mousePosition = Offset.zero;

  double boardWidth = 0;

  double boardHeight = 0;

  double scale = 1;

  double oldScale = 1;

  double minScale = 0.25;

  double maxScale = 4;

  Offset backgroundLine = Offset.zero;

  int clickFresh = 0;

  int currentItemCode = 0;

  bool enableDragging = true;

  List<ImageItem> imageItems = [];

  List<BoardLine> lines = [];

  ImageItem? currentSelectedImgItem;

  ImageItem? preSelectedImgItem;

  Offset global2Local(Offset point) {
    return point - boardOffset - globalOffset;
  }

  void updateBoardOffset(Offset offset) {
    boardOffset = offset;
    notifyListeners();
  }

  void updateView() {
    notifyListeners();
  }

  void addImageItem(ImageItem item) {
    oldScale = scale;
    imageItems.add(item);
    print('add item center: ${item.localPosition}');
    notifyListeners();
  }

  void addLine(BoardLine line) {
    print('add line');
    lines.add(line);
    clickFresh++;
    for (var point in line.points) {
      point.unclick();
      point.unclick();
    }
    notifyListeners();
  }

  void addScale(double s, Offset mousePosition) {
    oldScale = scale;
    scale += s;
    scale = min(max(scale, minScale), maxScale);
    backgroundLine = mousePosition -
        globalOffset +
        (backgroundLine - mousePosition + globalOffset) * (scale / oldScale);
    print(
        'backgroundLine: $backgroundLine mouse position: ${mousePosition - globalOffset}');
    for (var item in imageItems) {
      item.updatePosition();
    }
    notifyListeners();
  }

  bool inBoardArea(Offset globalPoint) {
    var localPoint = globalPoint - boardOffset;
    return localPoint.dx >= 0 &&
        localPoint.dx <= boardWidth &&
        localPoint.dy >= 0 &&
        localPoint.dy <= boardHeight;
  }

  Future<ui.Image> loadImage(String imagePath) async {
    final image = FileImage(File(imagePath));
    final completer = Completer<ui.Image>();
    final listener = ImageStreamListener((ImageInfo info, _) {
      completer.complete(info.image);
    });
    final stream = image.resolve(ImageConfiguration.empty);
    stream.addListener(listener);
    return completer.future.whenComplete(() => stream.removeListener(listener));
  }

  void showAll() {
    print('boardOffset: $boardOffset');
    print('boardWidth: $boardWidth');
    print('boardHeight: $boardHeight');
    print('scale: $scale');
  }
}

//!白板

class ImagesBoard extends StatefulWidget {
  const ImagesBoard({super.key, required this.width, required this.height});
  final double width;
  final double height;

  @override
  State<ImagesBoard> createState() => _ImagesBoardState();
}

class _ImagesBoardState extends State<ImagesBoard> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        ImagesBoardManager().boardWidth = renderBox.size.width;
        ImagesBoardManager().boardHeight = renderBox.size.height;
        ImagesBoardManager().boardOffset = renderBox.localToGlobal(Offset.zero);
      } else {
        print('renderBox is null');
      }
    });
    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent) {
          // 检测到滚轮滚动事件
          ImagesBoardManager().mousePosition = event.localPosition;
          timer?.cancel();
          timer = Timer(const Duration(milliseconds: 50), () {
            ImagesBoardManager().addScale(0, event.localPosition);
          });

          if (ImagesBoardManager().enableDragging) {
            ImagesBoardManager()
                .addScale(-event.scrollDelta.dy * 0.002, event.localPosition);
          } else {
            //todo：改成图片的坐标在这里更新
            for (var item in ImagesBoardManager().imageItems) {
              if (ImagesBoardManager().currentItemCode == item.code) {
                item.addScale(-event.scrollDelta.dy * 0.002);

                ImagesBoardManager().clickFresh++;
                ImagesBoardManager().updateView();
              }
            }
          }
        }
      },
      onPointerMove: (event) {
        ImagesBoardManager().scale = ImagesBoardManager().oldScale;
        if (event.buttons == 1) {
          // print('鼠标移动事件');
          ImagesBoardManager().mousePosition = event.localPosition;
          // 检测到鼠标左键按下
          if (ImagesBoardManager().enableDragging) {
            ImagesBoardManager().globalOffset += event.delta;
          } else {
            for (var item in ImagesBoardManager().imageItems) {
              if (ImagesBoardManager().currentItemCode == item.code) {
                item.addOffset(event.delta);
                // print('item localPosition: ${item.localPosition}');
                ImagesBoardManager().clickFresh++;
              }
            }
          }
          ImagesBoardManager().updateView();
        }
      },
      onPointerDown: (event) {
        // print('鼠标按下事件');
        ImagesBoardManager().oldScale = ImagesBoardManager().scale;
        bool isClicked = false;
        for (var item in ImagesBoardManager().imageItems.reversed) {
          //todo: 添加线的点击事件

          if (item.checkInArea(event.position, isClicked)) {
            // print('点击了图片: ${item.imgPath}');
            ImagesBoardManager().currentItemCode = item.code;
            if (!item.enableBoardDragging()) {
              ImagesBoardManager().enableDragging = false;
            } else {
              ImagesBoardManager().enableDragging = true;
            }
            isClicked = true;
          }

          if (item.checkPointsOnTap(event.position)) {
            // print('点击了 点');
          }
        }

        for (var line in ImagesBoardManager().lines) {
          if (line.isPointOnPath(event.position)) {
            // print('点击了 线');
          }
        }

        if (!isClicked) {
          ImagesBoardManager().enableDragging = true;
        }
        ImagesBoardManager().clickFresh++;
        ImagesBoardManager().updateView();
      },
      child: Selector<ImagesBoardManager, (int, double, Offset, int)>(
        selector: (context, imagesBoardManager) => (
          imagesBoardManager.imageItems.length,
          imagesBoardManager.scale,
          imagesBoardManager.globalOffset,
          imagesBoardManager.clickFresh
        ),
        builder: (context, _, child) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                CustomPaint(
                  painter: ImagesBoardPainter(),
                  size: Size(widget.width, widget.height),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                      onPressed: () {
                        Offset middle = Offset.zero;
                        if (ImagesBoardManager().imageItems.isEmpty) {
                          ImagesBoardManager().globalOffset =
                              Offset(widget.width / 2, widget.height / 2);
                          return;
                        }
                        for (var item in ImagesBoardManager().imageItems) {
                          middle += item.localPosition;
                        }
                        ImagesBoardManager().globalOffset = -middle /
                            ImagesBoardManager().imageItems.length.toDouble();
                        ImagesBoardManager().globalOffset +=
                            Offset(widget.width / 2, widget.height / 2);
                        ImagesBoardManager().updateView();
                      },
                      icon: Icon(Icons.center_focus_strong_outlined)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ImagesBoardPainter extends CustomPainter {
  Path createSmoothPath(List<Offset> points) {
    if (points.length < 2) {
      return Path();
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int index = 0; index < points.length - 1; index++) {
      final currentPoint = points[index];
      final nextPoint = points[index + 1];

      // 计算前一个点（边界处理）
      final Offset previousPoint;
      if (index == 0) {
        // 外推：2 * currentPoint - nextPoint
        previousPoint = Offset(
          2 * currentPoint.dx - nextPoint.dx,
          2 * currentPoint.dy - nextPoint.dy,
        );
      } else {
        previousPoint = points[index - 1];
      }

      // 计算后一个点（边界处理）
      final Offset nextNextPoint;
      if (index == points.length - 2) {
        // 外推：2 * nextPoint - currentPoint
        nextNextPoint = Offset(
          2 * nextPoint.dx - currentPoint.dx,
          2 * nextPoint.dy - currentPoint.dy,
        );
      } else {
        nextNextPoint = points[index + 2];
      }

      // 计算贝塞尔曲线的控制点
      final firstControlPoint = Offset(
        currentPoint.dx + (nextPoint.dx - previousPoint.dx) / 6,
        currentPoint.dy + (nextPoint.dy - previousPoint.dy) / 6,
      );
      final secondControlPoint = Offset(
        nextPoint.dx + (currentPoint.dx - nextNextPoint.dx) / 6,
        nextPoint.dy + (currentPoint.dy - nextNextPoint.dy) / 6,
      );

      path.cubicTo(
        firstControlPoint.dx,
        firstControlPoint.dy,
        secondControlPoint.dx,
        secondControlPoint.dy,
        nextPoint.dx,
        nextPoint.dy,
      );
    }

    return path;
  }

  void drawLine(
      BoardLine line, Canvas canvas, Offset globalOffset, double globalScale) {
    var points = line.points.map((e) => e.position + globalOffset).toList();
    var paint = Paint()
      ..color = line.color
      ..strokeWidth = line.width * globalScale * line.scale
      ..style = PaintingStyle.stroke;

    line.path = createSmoothPath(points);
    canvas.drawPath(line.path, paint);
    for (int i = 1; i < line.points.length - 1; i++) {
      drawPoint(line.points[i], canvas, globalOffset, globalScale);
    }
  }

  void drawPoint(
      BoardPoint point, Canvas canvas, Offset globalOffset, double totalScale) {
    // 绘制阴影
    var shadowPaint = Paint()
      ..color = point.color.withOpacity(0.3) // 阴影颜色，使用原颜色并降低透明度
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4); // 设置模糊效果，模拟阴影
    canvas.drawCircle(point.position + globalOffset,
        point.size * totalScale + 2, shadowPaint); // 阴影圆稍微大一点

    // 绘制实际的圆
    var paint = Paint()..color = point.color;
    canvas.drawCircle(
        point.position + globalOffset, point.size * totalScale, paint);
  }

  void drawImg(ImageItem item, Canvas canvas, Offset mousePosition,
      Offset globalOffset, double totalScale, double deltaScale) {
    var width = item.width;
    var height = item.height;

    // var newPosition =
    //     mousePosition + (item.localPosition - mousePosition) * deltaScale;
    // // print(
    // //     'old localPosition: ${item.localPosition} new localPosition: $newPosition');
    // item.localPosition = newPosition;

    // 添加圆角矩形裁切// 添加新变量记录圆角
    double borderRadius = 0.06 * (width > height ? width : height) * totalScale;
    double sideWidth = 0.03 * (width > height ? width : height) * totalScale;

    var rect = Rect.fromCenter(
        center: item.localPosition + globalOffset,
        width: width * totalScale,
        height: height * totalScale);

    var shadowRect = Rect.fromCenter(
        center: item.localPosition + globalOffset,
        width: width * totalScale + sideWidth,
        height: height * totalScale + sideWidth);

    var rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    var shadowRrect =
        RRect.fromRectAndRadius(shadowRect, Radius.circular(borderRadius));

    var paint = Paint()..color = item.sideColor;
    var shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawRRect(shadowRrect, shadowPaint);
    canvas.drawRRect(shadowRrect, paint);
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawImageRect(
      item.image!,
      Rect.fromLTWH(
          0, 0, item.image!.width.toDouble(), item.image!.height.toDouble()),
      rect,
      Paint(),
    );
    canvas.restore();
    item.updatePointsPosition();
    drawPoint(item.leftPoint, canvas, globalOffset, totalScale);
    drawPoint(item.rightPoint, canvas, globalOffset, totalScale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // print('绘制');
    var imagesBoardManager = ImagesBoardManager();
    var globalOffset = imagesBoardManager.globalOffset;
    var mousePosition = imagesBoardManager.mousePosition - globalOffset;

    var scale = imagesBoardManager.scale;
    var oldScale = imagesBoardManager.oldScale;

    // 绘制背景网格
    final gridSpacing = 50.0 * scale; // 网格间距
    var backgroundLine = imagesBoardManager.backgroundLine;

    // 添加圆角矩形裁切
    final borderRadius = BorderRadius.circular(10); // 圆角半径
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      borderRadius.topLeft,
    );
    canvas.clipRRect(rrect);

// 绘制相同形状的边框
    final borderPaint = Paint()
      ..color = Colors.grey // 边框颜色
      ..strokeWidth = 2 // 边框宽度
      ..style = PaintingStyle.stroke; // 设置为描边样式
    canvas.drawRRect(rrect, borderPaint);

    final gridPaint = Paint()
      ..color = const Color.fromARGB(255, 198, 198, 198)
      ..strokeWidth = 1;
    double x1 = (backgroundLine.dx) % gridSpacing + globalOffset.dx;
    double y1 = (backgroundLine.dy) % gridSpacing + globalOffset.dy;
    while (x1 > 0) {
      x1 -= gridSpacing;
    }
    while (y1 > 0) {
      y1 -= gridSpacing;
    }
    for (double x = x1; x < size.width; x += gridSpacing) {
      for (double y = y1; y < size.height; y += gridSpacing) {
        canvas.drawCircle(
          Offset(x, y),
          3 * scale, // 格点半径
          gridPaint,
        );
      }
    }

    for (var line in imagesBoardManager.lines) {
      drawLine(line, canvas, globalOffset, scale);
    }
    for (var item in ImagesBoardManager().imageItems) {
      if (item.image != null) {
        drawImg(item, canvas, mousePosition, globalOffset, scale * item.scale,
            scale / oldScale);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //todo: 优化性能
    return true;
  }
}
