import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:simple_canvas/images_board.dart';
import 'package:simple_canvas/images_board_item.dart';

class ImageItem extends BoardItem {
  String imgPath;
  ui.Image? image;
  ui.Color sideColor = Colors.white;
  late BoardPoint leftPoint;
  late BoardPoint rightPoint;

  ImageItem(
      {required Offset globalPosition,
      double scale = 1,
      required double width,
      required double height,
      required this.imgPath,
      this.image,
      required int code})
      : super(globalPosition, scale, width, height, code) {
    if (image == null) {
      ImagesBoardManager().loadImage(imgPath).then((value) {
        image = value;
        ImagesBoardManager().updateView();
      });
    }
    updateLocalPosition(globalPosition);
    double sideWidth = 0.03 * (width > height ? width : height);
    leftPoint = BoardPoint(
        Offset(localPosition.dx - width * scale / 2 - sideWidth * 1.5,
            localPosition.dy),
        DateTime.now().millisecondsSinceEpoch);
    leftPoint.scale = scale;
    leftPoint.parent = this;
    rightPoint = BoardPoint(
        Offset(localPosition.dx + width * scale / 2 + sideWidth * 1.5,
            localPosition.dy),
        DateTime.now().millisecondsSinceEpoch);
    rightPoint.scale = scale;
    rightPoint.parent = this;
  }

  factory ImageItem.fromJson(String jsonStr) {
    var itemMap = json.decode(jsonStr) as Map<String, dynamic>;
    String imgPath = itemMap['imgPath'];
    var globalPosition = Offset(
        itemMap['globalPosition']['dx'], itemMap['globalPosition']['dy']);
    double scale = itemMap['scale'];
    double width = itemMap['width'];
    double height = itemMap['height'];
    int code = itemMap['code'];
    return ImageItem(
        imgPath: imgPath,
        globalPosition: globalPosition,
        scale: scale,
        width: width,
        height: height,
        image: null,
        code: code);
  }

  String toJson() {
    return json.encode({
      'imgPath': imgPath,
      'globalPosition': {
        'dx': globalPosition.dx,
        'dy': globalPosition.dy,
      },
      'localPosition': {
        'dx': localPosition.dx,
        'dy': localPosition.dy,
      },
      'scale': scale,
      'width': width,
      'height': height,
    });
  }

  @override
  void click() {
    super.click();
    if (isSelected == 1) {
      sideColor = Colors.blue;
    } else if (isSelected == 2) {
      sideColor = Colors.red;
    }
  }

  @override
  void unclick() {
    super.unclick();
    // ImagesBoardManager().currentItem = null;
    sideColor = Colors.white;
  }

  @override
  bool checkInArea(Offset globalPoint, bool isClicked) {
    if (isClicked) {
      unclick();
      return false;
    }
    bool result = inArea(globalPoint);
    if (result) {
      // ImagesBoardManager().currentItem = this;
      click();
    } else {
      unclick();
    }
    return result;
  }

  bool enableBoardDragging() {
    return isSelected == 1;
  }

  @override
  void addScale(double s) {
    super.addScale(s);

    leftPoint.addScale(s);
    rightPoint.addScale(s);
    updatePosition();
  }

  void updatePosition() {
    var manager = ImagesBoardManager();
    var deltaScale = manager.scale / manager.oldScale;
    var mousePosition = manager.mousePosition - manager.globalOffset;
    localPosition =
        mousePosition + (localPosition - mousePosition) * deltaScale;
    updatePointsPosition();
  }

  void updatePointsPosition(){
    var manager = ImagesBoardManager();
    double totalScale = scale * manager.scale;
    double sideWidth = 0.03 * (width > height ? width : height) * totalScale;
    leftPoint.position = localPosition +
        Offset(-width * totalScale / 2 - sideWidth * 1.5, 0);
    rightPoint.position = localPosition +
        Offset(width * totalScale / 2 + sideWidth * 1.5, 0);
  }

  double getLeft(double totalScale) =>
      localPosition.dx - width * totalScale / 2;

  double getTop(double totalScale) =>
      localPosition.dy + height * totalScale / 2;

  double getRight(double totalScale) =>
      localPosition.dx + width * totalScale / 2;

  double getBottom(double totalScale) =>
      localPosition.dy - height * totalScale / 2;

  bool checkPointsOnTap(Offset position) {
    //todo: 后续可能要加上完整的四个点的点击判断
    bool result1 = leftPoint.checkInArea(position);
    bool result2 = rightPoint.checkInArea(position);

    return result1 || result2;
  }

  bool canBeLinked() {
    return leftPoint.isSelected == 2 || rightPoint.isSelected == 2;
  }

  BoardPoint getLinkedPoint() {
    //todo: 后续可能要加上完整的四个点判断逻辑
    return leftPoint.isSelected == 2 ? leftPoint : rightPoint;
  }
}
