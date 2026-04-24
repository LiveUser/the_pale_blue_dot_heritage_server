import 'package:flutter/material.dart';
import 'package:the_pale_blue_dot_heritage_server/create_object.dart';
import 'package:the_pale_blue_dot_heritage_server/widgets.dart';

class DatabaseManager extends StatelessWidget {
  const DatabaseManager({
    super.key,
    required this.databaseLocation,
  });
  final String databaseLocation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          //Navigate to the create object page
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => CreateObject(
              databaseLocation: databaseLocation,
            ),
          ));
        },
        backgroundColor: Colors.orange,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}