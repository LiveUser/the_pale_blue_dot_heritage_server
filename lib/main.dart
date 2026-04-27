// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphene_server/graphene_server.dart';
import 'package:objective_db/objective_db.dart';
import 'package:the_pale_blue_dot_heritage_server/database_manager.dart';
import 'package:the_pale_blue_dot_heritage_server/widgets.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Pale Blue Dot Heritage - Server',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Center(
        child: GestureDetector(
          onTap: ()async{
            //Open file picker for database location so it can be a different git project
            String? databaseLocation = await FilePicker.getDirectoryPath();
            if(databaseLocation != null){
              //Run server to handle API calls
              startServer(
                server: await HttpServer.bind(InternetAddress.loopbackIPv4, 8080), 
                isolateVariables: {
                  "databaseLocation": databaseLocation,
                },
                redirectHandler: (queryParameters){
                  return Redirect(
                    mimeType: "model/gltf-binary", 
                    url: queryParameters["url"],
                  );
                },
                getHandler: GetHandler(
                  handler: (arguments)async{
                    if(arguments["path"] == "/3d-model/default-model"){
                      return await File("${arguments["databaseLocation"]}/models/default.glb").readAsBytes();
                    }else if(arguments["path"].startsWith("/3d-model")){
                      String uuid = arguments["path"].substring(arguments["path"].lastIndexOf("/") + 1);
                      //Error is referencing a global variable from within an isolate
                      return await File("${arguments["databaseLocation"]}/models/$uuid.glb").readAsBytes();
                    }else{
                      return Uint8List.fromList("Invalid Request".codeUnits);
                    }
                  },
                ),
                query: GrapheneQuery(
                  resolver: {
                    "get-object-list": (arguments)async{
                      List<Map<String,dynamic>> objects = [];
                      Entry entry = Entry(dbPath: arguments["databaseLocation"]);
                      if(entry.select().view()["objects"] != null){
                        for(DbObject dbObject in entry.select().selectMultiple(key: "objects")){
                          objects.add(dbObject.view());
                        }
                        return objects;
                      }else{
                        return [];
                      }
                    },
                  },
                ),
                mutations: GrapheneMutation(
                  resolver: {

                  },
                ),
              );
              //Navigate to next screen
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => DatabaseManager(
                  databaseLocation: databaseLocation,
                ),
              ));
            }
          },
          child: Container(
            color: Colors.orange,
            margin: EdgeInsets.symmetric(
              horizontal: 20,
            ),
            padding: EdgeInsets.all(20),
            child: Text(
              "Pick Database Location",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}