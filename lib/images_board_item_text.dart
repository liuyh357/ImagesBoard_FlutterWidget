import 'package:flutter/material.dart';
import 'package:simple_canvas/floating_component_controller.dart';
import 'package:simple_canvas/images_board.dart';
import 'package:simple_canvas/images_board_item.dart';
import 'package:simple_canvas/images_board_item_img.dart';

class BoardText extends BoardItem {
  String text = "";
  Color textColor = Colors.black;
  Color bgColor = Colors.white;
  late Color oriTextColor;
  late Color oriBgColor;
  int leftMDCodePoint = 0;
  int rightMDCodePoint = 0;
  int topMDCodePoint = 0;
  int bottomMDCodePoint = 0;
  ImageItem? parent;
  BoardText(super.globalPosition, super.scale, super.width, super.height,
      super.code, this.text, this.bgColor, this.textColor, this.parent,
      {int leftMDCodePoint = 0,
      int rightMDCodePoint = 0,
      int topMDCodePoint = 0,
      int bottomMDCodePoint = 0}) {
    oriTextColor = textColor;
    oriBgColor = bgColor;
  }

  void setLeftMDCodePoint(int codePoint) {
    leftMDCodePoint = codePoint;
  }

  void setRightMDCodePoint(int codePoint) {
    rightMDCodePoint = codePoint;
  }

  void setTopMDCodePoint(int codePoint) {
    topMDCodePoint = codePoint;
  }

  void setBottomMDCodePoint(int codePoint) {
    bottomMDCodePoint = codePoint;
  }

  void setTextColor(Color color) {
    textColor = color;
  }

  void setBgColor(Color color) {
    bgColor = color;
  }

  void setText(String text) {
    this.text = text;
  }

  // @override
  // bool inArea(Offset globalPoint) {
  //   // 将全局坐标转换为局部坐标
  //   var localOffset = ImagesBoardManager().global2Local(globalPoint);
  //   double scaledWidth = width;
  //   double scaledHeight = height;

  //   // 计算图片矩形的边界
  //   double left = localPosition.dx - scaledWidth / 2;
  //   double top = localPosition.dy - scaledHeight / 2;
  //   double right = localPosition.dx + scaledWidth / 2;
  //   double bottom = localPosition.dy + scaledHeight / 2;

  //   // 检查局部坐标是否在图片矩形范围内
  //   return localOffset.dx >= left &&
  //       localOffset.dx <= right &&
  //       localOffset.dy >= top &&
  //       localOffset.dy <= bottom;
  // }

  @override
  void click({BuildContext? context, Offset globalPoint = Offset.zero}) {
    if (text != '添加标签') {
      super.click();
      if (isSelected == 1) {
        var temp = bgColor;
        setBgColor(textColor);
        setTextColor(temp);
      }
      if (isSelected == 2) {
        parent?.toDeletLabels.add(this);
      }
    } else {
      print('添加标签');
      if (context == null) {
        return;
      }
      void onSubmitted(String text, Color bgColor, Color textColor) {
        parent?.addLabel(text, bgColor, textColor);
        ImagesBoardManager().updateView();
      }

      var ft = FloatingComponentController.instance
          .showAddLabelDialog(context, onSubmitted);
      ft.then((e) {
        // Future.delayed(Duration(milliseconds: 100), () {
        //   ImagesBoardManager().updateView();
        // });
      });
    }
  }

  @override
  void unclick() {
    super.unclick();
    setBgColor(oriBgColor);
    setTextColor(oriTextColor);
  }

  @override
  bool checkInArea(Offset globalPoint, bool isClicked,
      {BuildContext? context}) {
    // if (isClicked) {
    //   unclick();
    //   return false;
    // }

    var result = inArea(globalPoint);
    if (result) {
      click(context: context, globalPoint: globalPoint);
    } else {
      unclick();
    }
    return result;
  }
}
