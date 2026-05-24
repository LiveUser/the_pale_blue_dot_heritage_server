import 'package:flutter/material.dart';
import 'package:the_pale_blue_dot_heritage_server/access_control_panel.dart';
import 'database_manager.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({
    super.key,
    required this.databaseLocation,
    required this.authDatabaseLocation,
  });
  final String databaseLocation;
  final String authDatabaseLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //Keep alive warning
            Container(
              color: Colors.red,
              padding: EdgeInsets.all(10),
              width: double.infinity,
              child: Row(
                spacing: 20,
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      "Server is running. Do not close the window.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //TODO: Access Control Panel
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => AccessControlPanel(
                    authDatabaseLocation: authDatabaseLocation,
                  ),
                ));
              },
              child: Container(
                color: Colors.orange,
                padding: EdgeInsets.all(10),
                width: double.infinity,
                child: Row(
                  spacing: 20,
                  children: [
                    Icon(
                      Icons.school,
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Text(
                        "Access Control Panel",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Data Entry
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => DatabaseManager(
                    databaseLocation: databaseLocation,
                  ),
                ));
              },
              child: Container(
                color: Colors.orange,
                padding: EdgeInsets.all(10),
                width: double.infinity,
                child: Row(
                  spacing: 20,
                  children: [
                    Icon(
                      Icons.storage,
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Text(
                        "Data Entry",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}