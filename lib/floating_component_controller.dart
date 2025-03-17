import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class FloatingComponentController {
  // 静态私有实例变量
  static final FloatingComponentController _instance = FloatingComponentController._internal();

  FloatingComponent? _floatingComponent;
  OverlayEntry? _entry;

  // 私有构造函数
  FloatingComponentController._internal();

  // 静态访问方法
  static FloatingComponentController get instance => _instance;

  void showOverlay(OverlayState overlay, double left, double top,
      void Function(String) onTextChanged, void Function(Color) onBgColorChanged, void Function(Color) onTextColorChanged) {
    _floatingComponent = FloatingComponent(
      left: left,
      top: top,
      onTextChanged: onTextChanged,
      onBgColorChanged: onBgColorChanged, 
      onTextColorChanged: onTextColorChanged,
    );
    _entry = OverlayEntry(
      builder: (context) {
        return _floatingComponent!;
      },
    );
    overlay.insert(_entry!);
  }

  void hideOverlay() {
    _entry?.remove();
    _entry = null;
    _floatingComponent = null;
  }
}

class FloatingComponent extends StatefulWidget {
  final double left;
  final double top;
  final void Function(String) onTextChanged;
  final void Function(Color) onBgColorChanged;
  final void Function(Color) onTextColorChanged;

  const FloatingComponent({
    super.key,
    required this.left,
    required this.top,
    required this.onTextChanged,
    required this.onBgColorChanged,
    required this.onTextColorChanged,
  });

  @override
  FloatingComponentState createState() => FloatingComponentState();
}

class FloatingComponentState extends State<FloatingComponent> {
  double left;
  double top;
  Color textColor = Colors.black;
  Color bgColor = const Color.fromARGB(255, 235, 235, 235);
  TextEditingController textEditingController = TextEditingController();
  FloatingComponentState()
      : left = 0.0,
        top = 0.0;

  @override
  void initState() {
    super.initState();
    left = widget.left;
    top = widget.top;
  }

  void _onBGColorChanged(Color color) {
    setState(() {
      bgColor = color;
    });
    widget.onBgColorChanged(color);
  }

  void _onTextColorChanged(Color color) {
    setState(() {
      textColor = color;
    });
    widget.onTextColorChanged(color);
  }

  // 弹出颜色选择器的函数
  Future<void> _showColorPicker(void Function(Color) onColorCHanged) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择颜色'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Colors.blue,
              onColorChanged: onColorCHanged,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              }, 
            ),
            ElevatedButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(context) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textEditingController,
                onChanged: (value) {
                  widget.onTextChanged(value);
                },
                onSubmitted: (value) {
                  widget.onTextChanged(value);
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                onPressed: () {
                  _showColorPicker(_onTextColorChanged);
                },
                icon: Icon(
                  Icons.text_format,
                  color: textColor,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(0.0, 0.0), 
                    )
                  ],
                ),
                tooltip: '文字颜色',
                
              ),
              IconButton(
                onPressed: () {
                  _showColorPicker(_onBGColorChanged);
                },
                icon: Icon(
                  Icons.format_color_fill,
                  color: bgColor,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(0.0, 0.0),
                    ) 
                  ]
                ),
                tooltip: '背景颜色',
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              widget.onTextChanged(textEditingController.text);
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('取消'),
          )
        ],
      ),
    );
  }
}
