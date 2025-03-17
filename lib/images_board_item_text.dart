import 'package:flutter/material.dart';
import 'package:simple_canvas/images_board_item.dart';

class BoardText extends BoardItem {
  String text = "";
  Color textColor = Colors.black;
  Color bgColor = Colors.white;
  int leftMDCodePoint = 0;
  int rightMDCodePoint = 0;
  int topMDCodePoint = 0;
  int bottomMDCodePoint = 0;
  BoardText(super.globalPosition, super.scale, super.width, super.height,
      super.code, this.text, this.bgColor, this.textColor,
      {int leftMDCodePoint = 0,
      int rightMDCodePoint = 0,
      int topMDCodePoint = 0,
      int bottomMDCodePoint = 0});

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

  @override
  void click() {
    super.click();
    if (isSelected == 1) {
      setBgColor(Colors.black);
    }
    if (isSelected == 2) {
      setBgColor(Colors.white);
    }
  }

  @override
  void unclick() {
    super.unclick();
    setBgColor(Colors.white);
  }

  @override
  bool checkInArea(Offset globalPoint, bool isClicked) {
    // if (isClicked) {
    //   unclick();
    //   return false;
    // }
    var result = inArea(globalPoint);
    if (result) {
      click();
    } else {
      unclick();
    }
    return result;
  }
}
