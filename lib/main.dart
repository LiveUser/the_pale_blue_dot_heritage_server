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
                getHandler: GetHandler(
                  handler: (path)async{
                    if(path == "/default-model"){
                      return (await rootBundle.load("models/mural_de_petroglifos_de_salto_arriba_low_poly_compressed.glb")).buffer.asUint8List();
                    }else if(path.startsWith("/3d-model")){
                      String uuid = path.substring(path.lastIndexOf("/") + 1);
                      Entry entry = Entry(dbPath: databaseLocation);
                      for(DbObject object in entry.select().selectMultiple(key: "objects")){
                        if(object.uuid == uuid){
                          String modelUUID = object.view()["model"];
                          DbObject dbObject = DbObject(
                            uuid: modelUUID, 
                            dbPath: entry.dbPath, 
                            cipherKeys: entry.cipherKeys,
                          );
                          return Uint8List.fromList(dbObject.view()["bytes"]);
                        }
                      }
                      return Uint8List.fromList("Model not found".codeUnits);
                    }else{
                      return Uint8List.fromList("Invalid Request".codeUnits);
                    }
                  },
                ),
                query: GrapheneQuery(
                  resolver: {

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