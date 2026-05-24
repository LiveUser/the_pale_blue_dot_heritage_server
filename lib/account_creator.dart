import 'package:flutter/material.dart';
import 'package:objective_db/objective_db.dart';
import 'package:the_pale_blue_dot_heritage_server/widgets.dart';
import 'package:graphene_server/auth.dart';
import 'package:cherry_toast/cherry_toast.dart';

class AccountCreator extends StatefulWidget {
  const AccountCreator({
    super.key,
    required this.authDatabaseLocation,
  });
  final String authDatabaseLocation;
  @override
  State<AccountCreator> createState() => _AccountCreatorState();
}

class _AccountCreatorState extends State<AccountCreator> {

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Username:",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            TextField(
              controller: username,
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
              "Password:",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            TextField(
              controller: password,
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
              onTap: (){
                //TODO: Create account
                if(username.text.isNotEmpty && password.text.isNotEmpty){
                  try{
                    Entry entry = Entry(
                      dbPath: widget.authDatabaseLocation,
                    );
                    createAccount(
                      authDatabase: entry,
                      username: username.text,
                      password: password.text,
                    );
                    Navigator.pop(context);
                    CherryToast.success(
                      title: Text(
                        "${username.text} added",
                      ),
                    ).show(context);
                  }catch(error){
                    CherryToast.error(
                    title: Text(
                        error.toString(),
                      ),
                    ).show(context);
                  }
                }else{
                  CherryToast.error(
                    title: Text(
                      "Username and password cannot be empty",
                    ),
                  );
                }
              },
              child: Container(
                  width: double.infinity,
                  color: Colors.orange,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Add Account",
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
    );
  }
}