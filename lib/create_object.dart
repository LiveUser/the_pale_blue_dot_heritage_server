// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:objective_db/objective_db.dart';
import 'package:the_pale_blue_dot_heritage_server/widgets.dart';
import 'dart:io';
import 'package:cherry_toast/cherry_toast.dart';
import 'dart:convert';

//Creates and modifies entries
class CreateObject extends StatelessWidget {
  const CreateObject({
    super.key,
    required this.databaseLocation,
  });
  final String databaseLocation;
  @override
  Widget build(BuildContext context) {
    TextEditingController zenodoDigitalObjectIdentifier = TextEditingController();
    //3d model data
    String filePath = "";

    return Scaffold(
      appBar: appBar(
        actions: [
          //TODO: Sync button to cache data from zenodo API using the zenodo digital object identifier
          GestureDetector(
            onTap: ()async{
              CherryToast.info(
                title: Text(
                  "Sync in progress",
                ),
              ).show(context);
              try{
                Entry entry = Entry(dbPath: databaseLocation);
                for(DbObject dbObject in entry.select().selectMultiple(key: "objects")){
                  Uri uri = Uri.parse(dbObject.view()["zenodoDOI"]);
                  Response response = await get(uri);
                  if (response.statusCode == 200) {
                    Map<String, dynamic> data = json.decode(response.body);
                    Map<String,dynamic> metadata = data['metadata'];
                    String title = metadata['title'] ?? 'Untitled';
                    String description = metadata['description'] ?? 'No description available.';
                    dbObject.insert(
                      key: "title", 
                      value: title,
                    );
                    dbObject.insert(
                      key: "description", 
                      value: description,
                    );
                  }
                }
              }catch(error){
                //Do nothing
              }
              CherryToast.success(
                title: Text(
                  "Sync complete",
                ),
              ).show(context);
            },
            child: Icon(
              Icons.sync,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                "Zenodo Digital Object Identifier",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              TextField(
                controller: zenodoDigitalObjectIdentifier,
                decoration: InputDecoration(
                  fillColor: Colors.orange,
                  isDense: true,
                  filled: true,
                  contentPadding: EdgeInsets.all(20),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Colors.white,
                ),
                cursorColor: Colors.white,
              ),
              Text(
                "3d model",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              ModelPicker(
                onUpdate: (newFilePath){
                  filePath = newFilePath;
                },
              ),
              GestureDetector(
                onTap: ()async{
                  //On tap check if zenodo id already exists. if not, create object.
                  if(zenodoDigitalObjectIdentifier.text.isNotEmpty && filePath.isNotEmpty){
                    CherryToast.info(
                      title: Text(
                        "Adding to database",
                      ),
                    ).show(context);
                    Entry entry = Entry(dbPath: databaseLocation);
                    late List<DbObject> objects;
                    try{
                      objects = entry.select().selectMultiple(key: "objects");
                    }catch(err){
                      objects = [];
                    }
                    try{
                      for(DbObject object in objects){
                        if(object.view()["zenodoDOI"] == zenodoDigitalObjectIdentifier.text){
                          throw "Zenodo DOI already exists on the database";
                        }
                      }
                      //Inject object. No enties exists
                      List<String> uuid = entry.select().insert(
                        key: "objects", 
                        value: [
                          {
                            "zenodoDOI": zenodoDigitalObjectIdentifier.text,
                            "description": "",
                            "model": {
                              "file-name": filePath.substring(filePath.lastIndexOf("/") + 1),
                            },
                          },
                        ],
                      );
                      //Store glb
                      File databaseFile = File("$databaseLocation/models/${uuid.first}.glb");
                      await databaseFile.create(recursive: true);
                      await databaseFile.writeAsBytes(await File(filePath).readAsBytes());
                      CherryToast.success(
                        title: Text(
                          "Succesfully added",
                        ),
                      ).show(context);
                      //Delete file after adding it to database
                      File compressedFile = File(filePath);
                      await compressedFile.delete(); 
                      zenodoDigitalObjectIdentifier.clear();
                      filePath = "";
                    }catch(err){
                      CherryToast.error(
                        title: Text(
                          err.toString(),
                        ),
                      ).show(context);
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  color: Colors.orange,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Add entry",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class ModelPicker extends StatefulWidget {
  const ModelPicker({
    super.key,
    required this.onUpdate,
  });
  final Function(String pickedObject) onUpdate;
  @override
  State<ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<ModelPicker> {
  String filePath = "";

  @override
  Widget build(BuildContext context) {
    return filePath.isEmpty ? GestureDetector(
      onTap: ()async{
        FilePickerResult? filePickerResult = await FilePicker.pickFiles(
          allowMultiple: false,
          type: FileType.custom,
          allowedExtensions: ["glb"],
        );
        if(filePickerResult != null){
          Directory outputFile = Directory("${Directory.systemTemp.path}/${filePickerResult.xFiles.first.name}");
          await Process.run("gltf-transform", ["optimize", filePickerResult.xFiles.first.path, outputFile.path, "--compress", "draco"], runInShell: true);
          filePath = outputFile.path;
          setState(() {
            
          });
        }else{
          filePath = "";
        }
        widget.onUpdate(filePath);
      },
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            width: 3,
            color: Colors.orange,
          ),
        ),
        child: Center(
          child: Text(
            "Tap to pick .glb file",
          ),
        ),
      ),
    ) : Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 20,
      children: [
        GestureDetector(
          onTap: ()async{
            setState(() {
              filePath = "";
            });
          },
          child: Icon(
            Icons.cancel,
            color: Colors.red,
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 200,
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                width: 3,
                color: Colors.orange,
              ),
            ),
            child: Center(
              child: Text(
                filePath.substring(filePath.lastIndexOf("/") + 1),
              ),
            ),
          )
        ),
      ],
    );
  }
}