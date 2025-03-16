import 'package:flutter/material.dart';
import 'package:simple_canvas/images_board_item.dart';

class BoardText extends BoardItem{
  String text = "";
  Color textColor = Colors.black;
  Color bgColor = Colors.white;
  BoardText(super.globalPosition, super.scale, super.width, super.height, super.code, this.text);



}