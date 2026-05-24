import 'package:flutter/material.dart';
import 'package:graphene_server/auth.dart';
import 'package:raw_context/raw_context.dart';
import 'package:the_pale_blue_dot_heritage_server/account_creator.dart';
import 'package:the_pale_blue_dot_heritage_server/widgets.dart';
import 'package:objective_db/objective_db.dart';
import 'package:graphene_server/auth.dart';
import 'package:quickie/quickie.dart';

class AccessControlPanel extends StatefulWidget {
  const AccessControlPanel({
    super.key,
    required this.authDatabaseLocation,
  });
  final String authDatabaseLocation;

  @override
  State<AccessControlPanel> createState() => _AccessControlPanelState();
}

class _AccessControlPanelState extends State<AccessControlPanel> {
  TextEditingController searchQuery = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        onPressed: ()async{
          //Navigate to Account Creator
          await Navigator.push(context, MaterialPageRoute(
            builder: (context)=> AccountCreator(
              authDatabaseLocation: widget.authDatabaseLocation,
            ),
          ));
          setState(() {
            
          });
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Column(
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
              //TODO: Display Accounts
              AccountsDisplayer(
                authDatabaseLocation: widget.authDatabaseLocation,
                reload: (){
                  setState(() {
                    
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class StoredAccount extends StatelessWidget {
  const StoredAccount({
    super.key,
    required this.authDatabaseLocation,
    required this.username,
    required this.password,
    required this.reload,
  });
  final String authDatabaseLocation;
  final String username;
  final String password;
  final Function reload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.orange,
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Username: $username",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Password: $password",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          RawContext(
            iconColor: Colors.white,
            items: [
              RawContextItem(
                onPressed: ()async{
                  //Change password
                  String? newPassword = await quickString(
                    context: context,
                    title: Text(
                      "New Password",
                    ),
                    inputFieldPadding: EdgeInsets.all(10),
                    backgroundColor: Colors.orange,
                  );
                  if(newPassword != null && newPassword.isNotEmpty){
                    Entry entry = Entry(
                      dbPath: authDatabaseLocation,
                    );
                    updatePassword(
                      authDatabase: entry, 
                      username: username, 
                      password: password, 
                      newPassword: newPassword,
                    );
                    reload();
                  }
                }, 
                item: Text(
                  "Change password",
                ),
              ),
              RawContextItem(
                onPressed: ()async{
                  //TODO: Delete account
                  bool shouldDelete = await quickConfirm(
                    context: context,
                    title: Text(
                      "Are you sure you want to delete $username?",
                    ),
                    confirmButton: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Text(
                        "Delete",
                      ),
                    ),
                  );
                  if(shouldDelete){
                    Entry entry = Entry(
                      dbPath: authDatabaseLocation,
                    );
                    deleteAccount(
                      authDatabase: entry, 
                      username: username,
                    );
                    reload();
                  }
                }, 
                item: Text(
                  "Delete account",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class AccountsDisplayer extends StatelessWidget {
  const AccountsDisplayer({
    super.key,
    required this.authDatabaseLocation,
    required this.reload,
  });
  final String authDatabaseLocation;
  final Function reload;

  List<Widget> widgetizeAccounts(){
    List<Widget> widgets = [];
    Entry entry = Entry(
      dbPath: authDatabaseLocation,
    );
    List<Map<String,dynamic>> allAccounts = getAllAccounts(
      authDatabase: entry,
    );
    for(Map<String,dynamic> account in allAccounts){
      widgets.add(StoredAccount(
        authDatabaseLocation: authDatabaseLocation,
        username: account["username"],
        password: account["password"],
        reload: reload,
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 10,
        children: widgetizeAccounts(),
      ),
    );
  }
}