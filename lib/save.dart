// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart'; // 新增导入
// import 'dart:ui' as ui;

// import 'package:provider/provider.dart';

// class ImagesBoardManager with ChangeNotifier {
//   static final ImagesBoardManager _instance = ImagesBoardManager._internal();

//   ImagesBoardManager._internal();

//   factory ImagesBoardManager() => _instance;

//   Offset globalOffset = Offset.zero;

//   Offset boardOffset = Offset.zero;

//   var mousePosition = Offset.zero;

//   double boardWidth = 0;

//   double boardHeight = 0;

//   double scale = 1;

//   double minScale = 1;

//   double maxScale = 3;

//   List<ImageItem> imageItems = [];

//   Offset global2Local(Offset point) {
//     return point - boardOffset;
//   }

//   void updateBoardOffset(Offset offset) {
//     boardOffset = offset;
//     notifyListeners();
//   }

//   void updateView() {
//     notifyListeners();
//   }

//   void addImageItem(ImageItem item) {
//     imageItems.add(item);
//     notifyListeners();
//   }

//   void addScale(double s, Offset mousePosition) {
//     double oldScale = scale;
//     scale += s;
//     scale = min(max(scale, minScale), maxScale);

//     double scaleFactor = scale / oldScale;

    

//     // 更新图像的全局位置
//     for (var item in imageItems) {
//       double dx = item.globalPosition.dx - mousePosition.dx;
//       double dy = item.globalPosition.dy - mousePosition.dy;

//       double newDx = dx * scaleFactor;
//       double newDy = dy * scaleFactor;

//       item.globalPosition = Offset(
//         mousePosition.dx + newDx,
//         mousePosition.dy + newDy,
//       );
//       item.updateLocalPosition(item.globalPosition);
//     }

//     notifyListeners();
//   }

//   bool inBoardArea(Offset globalPoint) {
//     var localPoint = global2Local(globalPoint);
//     return localPoint.dx >= 0 &&
//         localPoint.dx <= boardWidth &&
//         localPoint.dy >= 0 &&
//         localPoint.dy <= boardHeight;
//   }

//   Future<ui.Image> loadImage(String imagePath) async {
//     final image = FileImage(File(imagePath));
//     final completer = Completer<ui.Image>();
//     final listener = ImageStreamListener((ImageInfo info, _) {
//       completer.complete(info.image);
//     });
//     final stream = image.resolve(ImageConfiguration.empty);
//     stream.addListener(listener);
//     return completer.future.whenComplete(() => stream.removeListener(listener));
//   }

//   void showAll() {
//     print('boardOffset: $boardOffset');
//     print('boardWidth: $boardWidth');
//     print('boardHeight: $boardHeight');
//     print('scale: $scale');
//   }
// }

// class BoardItem {
//   ///全局坐标
//   Offset globalPosition;
//   late Offset localPosition;
//   double scale;
//   double width;
//   double height;
//   BoardItem(this.globalPosition, this.scale, this.width, this.height) {
//     localPosition = ImagesBoardManager().global2Local(globalPosition);
//   }

//   bool withinArea(Offset globalPoint) {
//     // 将全局坐标转换为局部坐标
//     var localOffset = ImagesBoardManager().global2Local(globalPoint);

//     // 应用缩放因子计算缩放后的宽度和高度
//     double scaledWidth = width * scale;
//     double scaledHeight = height * scale;

//     // 计算图片矩形的边界
//     double left = localPosition.dx - scaledWidth / 2;
//     double top = localPosition.dy - scaledHeight / 2;
//     double right = localPosition.dx + scaledWidth / 2;
//     double bottom = localPosition.dy + scaledHeight / 2;

//     // 检查局部坐标是否在图片矩形范围内
//     return localOffset.dx >= left &&
//         localOffset.dx <= right &&
//         localOffset.dy >= top &&
//         localOffset.dy <= bottom;
//   }

//   void updateLocalPosition(Offset globalPoint) {
//     var localPoint = ImagesBoardManager().global2Local(globalPoint);
//     localPosition = localPoint;
//     ImagesBoardManager().updateView();
//   }
// }

// class ImageItem extends BoardItem {
//   String imgPath;
//   ui.Image? image;
//   Color sideColor = Colors.white;
//   bool isSelected = false;

//   ImageItem(
//       {required Offset globalPosition,
//       double scale = 1,
//       required double width,
//       required double height,
//       required this.imgPath,
//       this.image})
//       : super(globalPosition, scale, width, height) {
//     if (image == null) {
//       ImagesBoardManager().loadImage(imgPath).then((value) {
//         image = value;
//         ImagesBoardManager().updateView();
//       });
//     }
//     updateLocalPosition(globalPosition);
//   }

//   factory ImageItem.fromJson(String jsonStr) {
//     var itemMap = json.decode(jsonStr) as Map<String, dynamic>;
//     var imgPath = itemMap['imgPath'];
//     var globalPosition = Offset(
//         itemMap['globalPosition']['dx'], itemMap['globalPosition']['dy']);
//     var scale = itemMap['scale'];
//     var width = itemMap['width'];
//     var height = itemMap['height'];
//     return ImageItem(
//         imgPath: imgPath,
//         globalPosition: globalPosition,
//         scale: scale,
//         width: width,
//         height: height,
//         image: null);
//   }

//   String toJson() {
//     return json.encode({
//       'imgPath': imgPath,
//       'globalPosition': {
//         'dx': globalPosition.dx,
//         'dy': globalPosition.dy,
//       },
//       'localPosition': {
//         'dx': localPosition.dx,
//         'dy': localPosition.dy,
//       },
//       'scale': scale,
//       'width': width,
//       'height': height,
//     });
//   }
// }

// class ImagesBoard extends StatefulWidget {
//   const ImagesBoard({super.key, required this.width, required this.height});
//   final double width;
//   final double height;

//   @override
//   State<ImagesBoard> createState() => _ImagesBoardState();
// }

// class _ImagesBoardState extends State<ImagesBoard> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       final renderBox = context.findRenderObject() as RenderBox?;
//       if (renderBox != null) {
//         ImagesBoardManager().boardWidth = renderBox.size.width;
//         ImagesBoardManager().boardHeight = renderBox.size.height;
//         ImagesBoardManager().boardOffset = renderBox.localToGlobal(Offset.zero);
//       } else {
//         print('renderBox is null');
//       }
//     });
//     return Listener(
//       onPointerSignal: (PointerSignalEvent event) {
//         if (event is PointerScrollEvent) {
//           // 检测到滚轮滚动事件
//           // print('滚轮滚动: dx = ${event.scrollDelta.dx}, dy = ${event.scrollDelta.dy}');
//           // 处理滚轮滚动事件
//           ImagesBoardManager().mousePosition = event.localPosition;
//           ImagesBoardManager()
//               .addScale(event.scrollDelta.dy * 0.003, event.position);
//         }
//       },
//       onPointerDown: (event) {
//         ImagesBoardManager().mousePosition = event.localPosition;
//       },
//       child: Selector<ImagesBoardManager, (int, double)>(
//         selector: (context, imagesBoardManager) =>
//             (imagesBoardManager.imageItems.length, imagesBoardManager.scale),
//         builder: (context, _, child) {
//           return CustomPaint(
//             painter: ImagesBoardPainter(),
//             size: Size(widget.width, widget.height),
//           );
//         },
//       ),
//     );
//   }
// }

// class ImagesBoardPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     // 绘制背景网格
//     final gridSpacing = 50.0;// 网格间距
//     final globalOffset = ImagesBoardManager().globalOffset;

//     // 添加圆角矩形裁切
//     final borderRadius = BorderRadius.circular(10); // 圆角半径
//     final rrect = RRect.fromRectAndRadius(
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       borderRadius.topLeft,
//     );
//     canvas.clipRRect(rrect);

//     final gridPaint = Paint()
//       ..color = Colors.grey.withOpacity(0.5)
//       ..strokeWidth = 1;

//     // 绘制垂直网格线
//     for (double x = -globalOffset.dx % gridSpacing;
//         x < size.width;
//         x += gridSpacing) {
//       canvas.drawLine(
//         Offset(x, 0),
//         Offset(x, size.height),
//         gridPaint,
//       );
//     }

//     // 绘制水平网格线
//     for (double y = -globalOffset.dy % gridSpacing;
//         y < size.height;
//         y += gridSpacing) {
//       canvas.drawLine(
//         Offset(0, y),
//         Offset(size.width, y),
//         gridPaint,
//       );
//     }
//         for (var item in ImagesBoardManager().imageItems) {
//       var scale = ImagesBoardManager().scale;
//       var width = item.width;
//       var height = item.height;
//       // 获取全局偏移量
//       var globalOffset = ImagesBoardManager().globalOffset; 

//       // 应用全局偏移量到图像的局部位置
//       var left = item.localPosition.dx - width * scale * item.scale / 2 + globalOffset.dx;
//       var top = item.localPosition.dy - height * scale * item.scale / 2 + globalOffset.dy;
//       var rect = Rect.fromLTWH(left * item.scale, top * item.scale,
//           width * scale * item.scale, height * scale * item.scale);
//       var rrect = RRect.fromRectAndRadius(rect, Radius.circular(10));
//       var paint = Paint()..color = Colors.black;

//       // 应用全局偏移量到阴影的位置
//       var shadowRect = Rect.fromLTWH(left * item.scale, top * item.scale,
//           width * scale * item.scale, height * scale * item.scale);
//       var shadowRRect =
//           RRect.fromRectAndRadius(shadowRect, Radius.circular(10));
//       canvas.drawRRect(
//         shadowRRect,
//         Paint()
//           ..color = Colors.black.withAlpha(100)
//           ..style = PaintingStyle.fill
//           ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4),
//       );

//       if (item.image != null) {
//         // print('draw image ${item.imgPath} localPosition: ${item.localPosition}');
//         ImagesBoardManager().showAll();
//         canvas.save();
//         canvas.clipRRect(rrect);
//         canvas.drawImageRect(
//             item.image!,
//             Rect.fromLTWH(0, 0, item.image!.width.toDouble(),
//                 item.image!.height.toDouble()),
//             rect,
//             paint);
//         canvas.restore();
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     //todo: 优化性能
//     return true;
//   }
// }

// class DraggableImage extends StatefulWidget {
//   const DraggableImage(
//       {super.key,
//       required this.width,
//       required this.height,
//       required this.imgPath});

//   final double width;
//   final double height;
//   final String imgPath;

//   @override
//   State<StatefulWidget> createState() {
//     return _DraggableImageState();
//   }
// }

// class _DraggableImageState extends State<DraggableImage> {
//   bool isDragging = false;
//   Offset draggingPosition = Offset.zero;
//   Offset globalDraggingPosition = Offset.zero;
//   Offset firstDraggingPosition = Offset.zero;
//   Offset globalFirstDraggingPosition = Offset.zero;
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: ImagesBoardManager().loadImage(widget.imgPath),
//       builder: (BuildContext context, AsyncSnapshot img) {
//         if (img.hasData) {
//           return Listener(
//             onPointerDown: (event) {
//               setState(() {
//                 isDragging = true;
//                 draggingPosition = event.localPosition;
//                 globalDraggingPosition = event.position;
//                 firstDraggingPosition = event.localPosition;
//                 globalFirstDraggingPosition = event.position;
//               });
//             },
//             onPointerUp: (event) {
//               setState(() {
//                 isDragging = false;
//                 double scale = min((widget.width - 15) / img.data.width,
//                     (widget.height - 15) / img.data.height);
//                 var scaleImgWidth = img.data.width.toDouble() * scale;
//                 var scaleImgHeight = img.data.height.toDouble() * scale;
//                 var centerXOffset = (widget.width - scaleImgWidth) / 2;
//                 var centerYOffset = (widget.height - scaleImgHeight) / 2;
//                 Offset center = Offset(
//                     globalDraggingPosition.dx -
//                         firstDraggingPosition.dx +
//                         centerXOffset +
//                         scaleImgWidth / 2,
//                     globalDraggingPosition.dy -
//                         firstDraggingPosition.dy +
//                         centerYOffset +
//                         scaleImgHeight / 2);
//                 var inBoardArea =
//                     ImagesBoardManager().inBoardArea(event.position);
//                 if (inBoardArea) {
//                   var imageItem = ImageItem(
//                     imgPath: widget.imgPath,
//                     globalPosition: center,
//                     scale: 1,
//                     width: scaleImgWidth,
//                     height: scaleImgHeight,
//                     image: img.data,
//                   );
//                   ImagesBoardManager().addImageItem(imageItem);
//                 }
//               });
//             },
//             onPointerMove: (event) {
//               if (isDragging) {
//                 setState(() {
//                   draggingPosition = event.localPosition;
//                   globalDraggingPosition = event.position;
//                 });
//               }
//             },
//             child: CustomPaint(
//               painter: DraggableImagePainter(
//                   image: img.data,
//                   isDragging: isDragging,
//                   draggingPosition: draggingPosition,
//                   imgWidth: widget.width,
//                   imgHeight: widget.height,
//                   firstDraggingPositon: firstDraggingPosition),
//               size: Size(widget.width, widget.height),
//             ),
//           );
//         }
//         return Container();
//       },
//     );
//   }
// }

// class DraggableImagePainter extends CustomPainter {
//   ui.Image image;
//   bool isDragging;
//   Offset draggingPosition;
//   Offset firstDraggingPositon;
//   double imgWidth;
//   double imgHeight;
//   DraggableImagePainter(
//       {required this.image,
//       this.isDragging = false,
//       this.draggingPosition = Offset.zero,
//       this.imgWidth = 100,
//       this.imgHeight = 100,
//       this.firstDraggingPositon = Offset.zero});
//   @override
//   void paint(Canvas canvas, Size size) {
//     Rect src =
//         Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
//     double scale =
//         min((imgWidth - 15) / image.width, (imgHeight - 15) / image.height);
//     var scaleImgWidth = image.width.toDouble() * scale;
//     var scaleImgHeight = image.height.toDouble() * scale;
//     Rect dst = Rect.fromLTWH((imgWidth - scaleImgWidth) / 2,
//         (imgHeight - scaleImgHeight) / 2, scaleImgWidth, scaleImgHeight);
//     RRect rrect = RRect.fromRectAndRadius(dst, Radius.circular(10));

//     Rect shadowRec =
//         Rect.fromLTWH(dst.left, dst.top, scaleImgWidth, scaleImgHeight);
//     var shadowRRec = RRect.fromRectAndRadius(shadowRec, Radius.circular(10));
//     canvas.drawRRect(
//         shadowRRec,
//         Paint()
//           ..color = Colors.black.withAlpha(80)
//           ..style = PaintingStyle.fill
//           ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4));

//     canvas.save();
//     canvas.clipRRect(rrect);
//     canvas.drawImageRect(image, src, dst, Paint());
//     canvas.restore();

//     if (isDragging) {
//       var draggingDx = draggingPosition.dx;
//       var draggingDy = draggingPosition.dy;

//       // print('dst img width: ${dst.width} height: ${dst.height}');

//       dst = Rect.fromLTWH(
//           draggingDx - firstDraggingPositon.dx + dst.left,
//           draggingDy - firstDraggingPositon.dy + dst.top,
//           dst.width,
//           dst.height);
//       RRect rrect = RRect.fromRectAndRadius(dst, Radius.circular(10));

//       Rect shadowRec = Rect.fromLTWH(dst.left, dst.top, dst.width, dst.height);
//       var shadowRRec = RRect.fromRectAndRadius(shadowRec, Radius.circular(10));
//       canvas.drawRRect(
//           shadowRRec,
//           Paint()
//             ..color = Colors.black.withAlpha(100)
//             ..style = PaintingStyle.fill
//             ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4));

//       canvas.save();

//       canvas.clipRRect(rrect);
//       canvas.drawImageRect(image, src, dst, Paint());
//       canvas.restore();
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     // TODO: implement shouldRepaint
//     return true;
//   }
// }
