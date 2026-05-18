import 'package:flutter/material.dart';

AppBar appBar({
  List<Widget>? actions,
}){
  return AppBar(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
    centerTitle: true,
    title: Text(
      "The Pale Blue Dot Heritage Server",
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    actions: actions,
  );
}
class HorizontalRule extends StatelessWidget {
  const HorizontalRule({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      width: double.infinity,
      height: 3,
    );
  }
}