import 'package:flutter/material.dart';
import 'package:the_pale_blue_dot_heritage_server/widgets.dart';

class AccessControlPanel extends StatelessWidget {
  const AccessControlPanel({
    super.key,
    required this.databaseLocation,
  });
  final String databaseLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        onPressed: (){
          //TODO: Navigate to add institution page
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}