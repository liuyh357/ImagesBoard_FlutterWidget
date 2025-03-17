// images_board_item_button.dart
// 描述: 定义了 BoardDeleteButton 和 BoardArea 类，分别用于删除按钮和区域的管理，支持删除元素和区域的绘制。
// 关键功能: 删除交互和区域的定义。

import 'package:flutter/material.dart';
import 'package:simple_canvas/images_board.dart';
import 'package:simple_canvas/images_board_item.dart';
import 'package:simple_canvas/images_board_item_img.dart';

class BoardDeleteButton extends BoardItem {
  int leftMDCodePoint = 0;
  Color leftMDIconColor = Colors.white;
  int rightMDCodePoint = 0;
  Color rightMDIconColor = Colors.white;
  int topMDCodePoint = 0;
  Color topMDIconColor = Colors.white;
  int bottomMDCodePoint = 0;
  Color bottomMDIconColor = Colors.white;
  Color bgColor = Colors.white;
  Color textColor = Colors.black;
  Color? sideColor = Colors.white;
  BoardDeleteButton(
      super.globalPosition, super.scale, super.width, super.height, super.code);

  void setLeftMDCodePoint(int codePoint, {Color color = Colors.white}) {
    leftMDCodePoint = codePoint;
    leftMDIconColor = color;
  }

  void setRightMDCodePoint(int codePoint, {Color color = Colors.white}) {
    rightMDCodePoint = codePoint;
    rightMDIconColor = color;
  }

  void setTopMDCodePoint(int codePoint, {Color color = Colors.white}) {
    topMDCodePoint = codePoint;
    topMDIconColor = color;
  }

  void setBottomMDCodePoint(int codePoint, {Color color = Colors.white}) {
    bottomMDCodePoint = codePoint;
    bottomMDIconColor = color;
  }

  @override
  bool inArea(Offset globalPoint) {
    // 将全局坐标转换为局部坐标
    var localOffset = ImagesBoardManager().global2Local(globalPoint) +
        ImagesBoardManager().globalOffset;

    var totalScale = 1;
    // 应用缩放因子计算缩放后的宽度和高度
    double scaledWidth = width * totalScale;
    double scaledHeight = height * totalScale;

    // 计算图片矩形的边界
    double left = localPosition.dx - scaledWidth / 2;
    double top = localPosition.dy - scaledHeight / 2;
    double right = localPosition.dx + scaledWidth / 2;
    double bottom = localPosition.dy + scaledHeight / 2;

    // 检查局部坐标是否在图片矩形范围内
    return localOffset.dx >= left &&
        localOffset.dx <= right &&
        localOffset.dy >= top &&
        localOffset.dy <= bottom;
  }

  @override
  void click() {
    var mng = ImagesBoardManager();
    if (mng.lastItemCode != 0) {
      for (var item in mng.imageItems) {
        if (item.code == mng.lastItemCode) {
          var leftPoint = item.leftPoint;
          var rightPoint = item.rightPoint;
          List<BoardLine> toDelLines = [];
          for (var line in mng.lines) {
            if (line.points.contains(leftPoint)) {
              toDelLines.add(line);
            }
            if (line.points.contains(rightPoint)) {
              toDelLines.add(line);
            }
          }
          mng.lines.removeWhere((element) => toDelLines.contains(element));
          mng.imageItems.remove(item);
          break;
        }
      }
      for (var line in mng.lines) {
        if (line.code == mng.lastItemCode) {
          mng.lines.remove(line);
          break;
        }
      }
      mng.lastItemCode = 0;
    }
  }

  @override
  bool checkInArea(Offset globalPoint, bool isClicked) {
    var result = inArea(globalPoint);
    if (result) {
      print('delete button click');
      click();
    }
    ImagesBoardManager().showDeleteButton = false;
    return result;
  }
}

class BoardArea extends BoardItem {
  List<ImageItem> items = [];
  Color bgColor = const Color.fromARGB(161, 255, 255, 255);
  Color sideColor = const Color.fromARGB(255, 174, 174, 174);
  BoardArea(
      super.globalPosition, super.scale, super.width, super.height, super.code);
}
