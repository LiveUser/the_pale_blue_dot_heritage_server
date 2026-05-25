// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphene_server/auth.dart';
import 'package:graphene_server/graphene_server.dart';
import 'package:objective_db/objective_db.dart';
import 'package:the_pale_blue_dot_heritage_server/main_menu.dart';
import 'package:the_pale_blue_dot_heritage_server/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'dart:convert';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  String authDatabaseLocation = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          GestureDetector(
            onTap: ()async{
              //Enter auth database password
              String? folderLocation = await FilePicker.getDirectoryPath();
              if(folderLocation != null && folderLocation.isNotEmpty){
                setState(() {
                  authDatabaseLocation = folderLocation;
                });
              }
            },
            child: Container(
              width: double.infinity,
              color: Colors.orange,
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              padding: EdgeInsets.all(20),
              child: Text(
                authDatabaseLocation.isEmpty ? "Pick Auth Database Location" : authDatabaseLocation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: ()async{
              //Open file picker for database location so it can be a different git project
              String? databaseLocation = await FilePicker.getDirectoryPath();
              if(databaseLocation != null && authDatabaseLocation.isNotEmpty){
                //Run server to handle API calls
                startServer(
                  server: await HttpServer.bind(InternetAddress.loopbackIPv4, 8080), 
                  isolateVariables: {
                    "databaseLocation": databaseLocation,
                    "authDatabaseLocation": authDatabaseLocation,
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
                      //Server functionality--------------------------------------------------------
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
                      //User functionality-----------------------------------------------------------
                      "login": (arguments)async{
                        //Login and return token
                        Entry authDatabase = Entry(dbPath: arguments["authDatabaseLocation"]);
                        return login(
                          authDatabase: authDatabase, 
                          username: arguments["username"], 
                          password: arguments["password"],
                        );
                      },
                      
                    },
                  ),
                  mutations: GrapheneMutation(
                    resolver: {
                      //User functionality-----------------------------------------------------------
                      "logout": (arguments)async{
                        Entry authDatabase = Entry(dbPath: arguments["authDatabaseLocation"]);
                        return logOutFromEverywhere(
                          authDatabase: authDatabase, 
                          username: arguments["username"], 
                          password: arguments["password"],
                        );
                      },
                      "createObject": (arguments)async{
                        Entry authDatabase = Entry(dbPath: arguments["authDatabaseLocation"]);
                        Entry objectsDatabase = Entry(dbPath: arguments["databaseLocation"]);
                        bool userHasAccess = tokenIsValid(
                          authDatabase: authDatabase, 
                          accessToken: arguments["accessToken"],
                        );
                        if(userHasAccess){
                          String zenodoDOI = arguments["zenodoDOI"];
                          String zenodoDownloadLink = arguments["zenodoDownloadLink"];
                          if(zenodoDOI.isNotEmpty && zenodoDownloadLink.isNotEmpty){
                            objectsDatabase.select().insert(
                              key: "objects",
                              value: [
                                {
                                  "zenodoDOI": zenodoDOI,
                                  "description": "",
                                  "zenodoDownloadLink": zenodoDownloadLink,
                                },
                              ],
                            );
                            return "Object added succesfully to database";
                          }else{
                            throw "Zenodo DOI and Download Link cannot be empty";
                          }
                        }else{
                          throw "You do not have access";
                        }
                      },
                      //Modify 
                      "modifyObject": (arguments)async{
                        Entry authDatabase = Entry(dbPath: arguments["authDatabaseLocation"]);
                        Entry objectsDatabase = Entry(dbPath: arguments["databaseLocation"]);
                        bool userHasAccess = tokenIsValid(
                          authDatabase: authDatabase, 
                          accessToken: arguments["accessToken"],
                        );
                        if(userHasAccess){
                          String zenodoDOI = arguments["zenodoDOI"];
                          String zenodoDownloadLink = arguments["zenodoDownloadLink"];
                          String uuid = arguments["uuid"];
                          if(zenodoDOI.isNotEmpty && zenodoDownloadLink.isNotEmpty){
                            DbObject objectToModify = DbObject(
                              uuid: uuid, 
                              dbPath: objectsDatabase.dbPath, 
                              cipherKeys: null,
                            );
                            objectToModify.insert(
                              key: "zenodoDOI", 
                              value: zenodoDOI,
                            );
                            objectToModify.insert(
                              key: "zenodoDownloadLink", 
                              value: zenodoDownloadLink,
                            );
                            return "Object modified succesfully";
                          }else{
                            throw "Zenodo DOI and Download Link cannot be empty";
                          }
                        }else{
                          throw "You do not have access";
                        }
                      },
                      //Delete Object
                      "delete": (arguments)async{
                        Entry authDatabase = Entry(dbPath: arguments["authDatabaseLocation"]);
                        Entry objectsDatabase = Entry(dbPath: arguments["databaseLocation"]);
                        bool userHasAccess = tokenIsValid(
                          authDatabase: authDatabase, 
                          accessToken: arguments["accessToken"],
                        );
                        if(userHasAccess){
                          String uuid = arguments["uuid"];
                          objectsDatabase.select().delete(
                            key: "objects", 
                            uuid: uuid,
                          );
                          return "Object deleted succesfully";
                        }else{
                          throw "You do not have access";
                        }
                      },
                      //Sync changes
                      "sync": (arguments)async{
                        Entry authDatabase = Entry(dbPath: arguments["authDatabaseLocation"]);
                        Entry objectsDatabase = Entry(dbPath: arguments["databaseLocation"]);
                        bool userHasAccess = tokenIsValid(
                          authDatabase: authDatabase, 
                          accessToken: arguments["accessToken"],
                        );
                        if(userHasAccess){
                          String uuid = arguments["uuid"];
                          if(uuid.isNotEmpty){
                            DbObject objectToModify = DbObject(
                              uuid: uuid, 
                              dbPath: objectsDatabase.dbPath, 
                              cipherKeys: null,
                            );
                            //Fetch data
                            String doi = objectToModify.view()["zenodoDOI"].substring(objectToModify.view()["zenodoDOI"].lastIndexOf(".") + 1);
                            Uri uri = Uri.parse('https://zenodo.org/api/records/$doi');
                            //print(uri.toString());
                            Response response = await get(uri);
                            Map<String, dynamic> data = json.decode(response.body);
                            //print(data);
                            Map<String,dynamic> metadata = data['metadata'];
                            String title = metadata['title'] ?? 'Untitled';
                            String description = metadata['description'] ?? 'No description available.';
                            objectToModify.insert(
                              key: "title", 
                              value: title,
                            );
                            objectToModify.insert(
                              key: "description", 
                              value: description,
                            );
                            return "Object synced succesfully";
                          }else{
                            throw "Zenodo DOI and Download Link cannot be empty";
                          }
                        }else{
                          throw "You do not have access";
                        }
                      },
                    },
                  ),
                );
                //Navigate to next screen
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MainMenu(
                    databaseLocation: databaseLocation,
                    authDatabaseLocation: authDatabaseLocation,
                  ),
                ));
              }
            },
            child: Container(
              width: double.infinity,
              color: Colors.orange,
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              padding: EdgeInsets.all(20),
              child: Text(
                "Pick Objects Database Location",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}