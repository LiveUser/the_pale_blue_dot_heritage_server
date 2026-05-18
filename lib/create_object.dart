// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:objective_db/objective_db.dart';
import 'package:the_pale_blue_dot_heritage_server/widgets.dart';
import 'package:cherry_toast/cherry_toast.dart';

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
    TextEditingController zenodoDownloadLink = TextEditingController();

    return Scaffold(
      appBar: appBar(),
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
                "Zenodo model download URL",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              TextField(
                controller: zenodoDownloadLink,
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
              GestureDetector(
                onTap: ()async{
                  //On tap check if zenodo id already exists. if not, create object.
                  if(zenodoDigitalObjectIdentifier.text.isNotEmpty && zenodoDownloadLink.text.isNotEmpty){
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
                      entry.select().insert(
                        key: "objects", 
                        value: [
                          {
                            "zenodoDOI": zenodoDigitalObjectIdentifier.text,
                            "description": "",
                            "zenodoDownloadLink": zenodoDownloadLink.text,
                          },
                        ],
                      );
                      CherryToast.success(
                        title: Text(
                          "Succesfully added",
                        ),
                      ).show(context);
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