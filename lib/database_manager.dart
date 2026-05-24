// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:the_pale_blue_dot_heritage_server/create_object.dart';
import 'package:the_pale_blue_dot_heritage_server/widgets.dart';
import 'package:objective_db/objective_db.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:lost/lost.dart';
import 'package:sortero/sortero.dart';
import 'package:quickie/quickie.dart';

class DatabaseManager extends StatefulWidget {
  const DatabaseManager({
    super.key,
    required this.databaseLocation,
  });
  final String databaseLocation;

  @override
  State<DatabaseManager> createState() => _DatabaseManagerState();
}

class _DatabaseManagerState extends State<DatabaseManager> {
  TextEditingController searchQuery = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        actions: [
          //Sync button to cache data from zenodo API using the zenodo digital object identifier
          GestureDetector(
            onTap: ()async{
              CherryToast.info(
                title: Text(
                  "Sync in progress",
                ),
              ).show(context);
              try{
                Entry entry = Entry(dbPath: widget.databaseLocation);
                for(DbObject dbObject in entry.select().selectMultiple(key: "objects")){
                  String doi = dbObject.view()["zenodoDOI"].substring(dbObject.view()["zenodoDOI"].lastIndexOf(".") + 1);
                  Uri uri = Uri.parse('https://zenodo.org/api/records/$doi');
                  //print(uri.toString());
                  Response response = await get(uri);
                  Map<String, dynamic> data = json.decode(response.body);
                  //print(data);
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
              }catch(error){
                //Do nothing
              }
              CherryToast.success(
                title: Text(
                  "Sync complete",
                ),
              ).show(context);
            },
            child: Container(
              padding: EdgeInsets.all(20),
              child: Icon(
                Icons.sync,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          //Navigate to the create object page
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) => CreateObject(
              databaseLocation: widget.databaseLocation,
            ),
          ));
          setState(() {
            
          });
        },
        backgroundColor: Colors.orange,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 10,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      controller: searchQuery,
                      leading: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      trailing: [
                        GestureDetector(
                          onTap: (){
                            //Clear text field
                            searchQuery.clear();
                          },
                          child: Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      backgroundColor: WidgetStatePropertyAll(Colors.orange),
                      textStyle: WidgetStatePropertyAll(TextStyle(
                        color: Colors.white,
                      )),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ObjectsDispayingWidget(
                    searchQuery: searchQuery,
                    databaseLocation: widget.databaseLocation,
                    reload: (){
                      setState(() {
                        
                      });
                    },
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
class ObjectDisplayingWidget extends StatelessWidget {
  const ObjectDisplayingWidget({
    super.key,
    required this.databaseLocation,
    required this.uuid,
    required this.zenodoDOI,
    required this.description,
    required this.zenodoDownloadLink,
    required this.title,
    required this.instances,
    required this.reload,
  });
  final String databaseLocation;
  final String uuid;
  final String zenodoDOI;
  final String description;
  final String zenodoDownloadLink;
  final String title;
  //For sorting using search query
  final int instances;
  final Function reload;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      padding: EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Title: $title",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          Text(
            "Description: $description",
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Zenodo DOI: $zenodoDOI",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: ()async{
                  //Change zenodo DOI
                  String? newDOI = await quickString(
                    context: context,
                    title: Text(
                      "New DOI",
                    ),
                    backgroundColor: Colors.orange,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                    inputFieldPadding: EdgeInsets.all(10),
                  );
                  if(newDOI != null && newDOI.isNotEmpty){
                    DbObject dbObject = DbObject(uuid: uuid, dbPath: databaseLocation, cipherKeys: null);
                    dbObject.insert(key: "zenodoDOI", value: newDOI);
                    reload();
                  }
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Modify",
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Zenodo Download Link: $zenodoDownloadLink",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: ()async{
                  //Change zenodo Download Link
                  String? newDownloadLink = await quickString(
                    context: context,
                    title: Text(
                      "New Zenodo Download Link",
                    ),
                    backgroundColor: Colors.orange,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                    inputFieldPadding: EdgeInsets.all(10),
                  );
                  if(newDownloadLink != null && newDownloadLink.isNotEmpty){
                    DbObject dbObject = DbObject(uuid: uuid, dbPath: databaseLocation, cipherKeys: null);
                    dbObject.insert(key: "zenodoDownloadLink", value: newDownloadLink);
                    reload();
                  }
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Modify",
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: ()async{
              //Delete button
              bool? shouldDelete = await quickConfirm(
                context: context,
                title: Text(
                  "Delete entry with title $title",
                ),
                backgroundColor: Colors.orange,
                textStyle: TextStyle(
                  color: Colors.white,
                ),
              );
              if(shouldDelete){
                DbObject dbObject = Entry(
                  dbPath: databaseLocation,
                  cipherKeys: null,
                ).select();
                dbObject.delete(key: "objects", uuid: uuid);
                reload();
              }
            },
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Text(
                "Delete Entry",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class ObjectsDispayingWidget extends StatefulWidget {
  const ObjectsDispayingWidget({
    super.key,
    required this.searchQuery,
    required this.databaseLocation,
    required this.reload,
  });
  final TextEditingController searchQuery;
  final String databaseLocation;
  final Function reload;

  @override
  State<ObjectsDispayingWidget> createState() => _ObjectsDispayingWidgetState();
}

class _ObjectsDispayingWidgetState extends State<ObjectsDispayingWidget> {

  @override
  void initState(){
    super.initState();
    widget.searchQuery.addListener((){
      setState(() {
        
      });
    });
  }
  @override
  void dispose(){
    super.dispose();
    widget.searchQuery.dispose();
  }

  List<Widget> loadAndWidgetizeAccounts(){
    List<Widget> widgets = [];
    //Load data and widgetize it
    Entry entry = Entry(dbPath: widget.databaseLocation);
    try{
      List<DbObject> objects = entry.select().selectMultiple(key: "objects");
      
      for(DbObject dbObject in objects){
        Map<String,dynamic> objectContent = dbObject.view();
        String zenodoDOI = objectContent["zenodoDOI"];
        String description = objectContent["description"] ?? "No description available";
        String zenodoDownloadLink = objectContent["zenodoDownloadLink"];
        String title = objectContent["title"] ?? "Untitled";

        int instances = 0;

        if(widget.searchQuery.text.isEmpty){
          instances = -1;
        }else{
          instances += zenodoDOI.instancesOf(widget.searchQuery.text);
          instances += zenodoDownloadLink.instancesOf(widget.searchQuery.text);
          instances += title.instancesOf(widget.searchQuery.text);
          instances += description.instancesOf(widget.searchQuery.text);
        }

        if(0 < instances || instances == -1){
          widgets.add(ObjectDisplayingWidget(
            databaseLocation: widget.databaseLocation,
            uuid: dbObject.uuid,
            zenodoDOI: zenodoDOI,
            description: description,
            zenodoDownloadLink: zenodoDownloadLink,
            title: title,
            instances: instances,
            reload: widget.reload,
          ));
        }
      }
    }catch(error){
      //Do nothing
      //print(error.toString());
    }
    //Sort
    if(widget.searchQuery.text.isNotEmpty){
      widgets.bubbleSort(
        compare: (object){
          return (object as ObjectDisplayingWidget).instances;
        },
        reverseOrder: true,
      );
    }
    
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: loadAndWidgetizeAccounts(),
    );
  }
}