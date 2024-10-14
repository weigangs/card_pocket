import 'dart:async';
import 'package:flutter/material.dart';
import '../model/model.dart';
import '../util/dbhelper.dart';
import '../util/utils.dart' as card_utils;
import './docdetail.dart';

// Menu item
const menuReset = "Reset Local Data";
List<String> menuOptions = const <String>[menuReset];

class DocList extends StatefulWidget {
  const DocList({super.key});

  @override
  State<StatefulWidget> createState() => DocListState();
}

class DocListState extends State<DocList> {
  DbHelper dbh = DbHelper();
  List<Doc> docs = <Doc>[];
  int count = 0;
  DateTime cDate = DateTime.now();
  @override
  void initState() {
    super.initState();
  }

  Future getData() async {
    
    final dbFuture = dbh.initializeDb();
    dbFuture.then(
        // result here is the actual reference to the database object
        (result) {
      final docsFuture = dbh.getDocs();
      docsFuture.then((result) {

        List<Doc> docList = <Doc>[];
        var count = result.length;
        for (int i = 0; i <= count - 1; i++) {
          docList.add(Doc.fromOject(result[i]));
        }
        setState(() {
          if (docs.isNotEmpty) {
            docs.clear();
          }
          docs = docList;
          this.count = count;
        });
      });
    });
  }

  void _checkDate() {
    const secs = Duration(hours: 6);
    new Timer.periodic(secs, (Timer t) {
      DateTime nw = DateTime.now();
      if (cDate.day != nw.day ||
          cDate.month != nw.month ||
          cDate.year != nw.year) {
        getData();
        cDate = DateTime.now();
      }
    });
  }

  void navigateToDetail(Doc doc) async {
    bool r = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => DocDetail(doc)));
    if (r == true) {
      getData();
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset"),
          content: const Text("Do you want to delete all local data?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Future f = _resetLocalData();
                f.then((result) {
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future _resetLocalData() async {
    final dbFuture = dbh.initializeDb();
    dbFuture.then((result) {
      final dDocs = dbh.deleteRows(DbHelper.tblDocs);
      dDocs.then((result) {
        setState(() {
          docs.clear();
          count = 0;
        });
      });
    });
  }

  void _selectMenu(String value) async {
    switch (value) {
      case menuReset:
        _showResetDialog();
    }
  }

  ListView docListItems() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        String dd = card_utils.Val.getExpiryStr(docs[position].expiration);
        String dl = (dd != "1") ? " days left" : " day left";
        return Card(
          color: Colors.white,
          elevation: 1.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _computeAvatarColorByExpiryStr(docs[position]),
              child: Text(
                docs[position].id.toString(),
              ),
            ),
            title: Text(docs[position].title),
            subtitle: Text(
                "${card_utils.Val.getExpiryStr(docs[position].expiration)}$dl\nExp: ${card_utils.DateUtils.convertToDateFull(
                        docs[position].expiration)}"),
            onTap: () {
              navigateToDetail(docs[position]);
            },
          ),
        );
      },
    );
  }

  Color _computeAvatarColorByExpiryStr(Doc doc) {
    String remainDays = card_utils.Val.getExpiryStr(doc.expiration);
    int intRemainDays = int.parse(remainDays);
    if (intRemainDays == 0) {
      return Colors.red;
    }
    if (card_utils.Val.intToBool(doc.fqMonth)) {
      if (intRemainDays < 30) {
        return Colors.orange;
      }
    }
    if (card_utils.Val.intToBool(doc.fqQuarter)) {
      if (intRemainDays < 60) {
        return Colors.orange;
      }
    }
    if (card_utils.Val.intToBool(doc.fqHalfYear)) {
      if (intRemainDays < 180) {
        return Colors.orange;
      }
    }
    if (card_utils.Val.intToBool(doc.fqYear)) {
      if (intRemainDays < 365) {
        return Colors.orange;
      }
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    cDate = DateTime.now();
    if (docs.isEmpty) {
      getData();
    }
    _checkDate();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("DocExpire"), actions: <Widget>[
        PopupMenuButton(
          onSelected: _selectMenu,
          itemBuilder: (BuildContext context) {
            return menuOptions.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ]),
      body: Center(
        child: Scaffold(
          body: Stack(children: <Widget>[
            docListItems(),
          ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              navigateToDetail(Doc.withId(-1, "", "", 1, 1, 1, 1));
            },
            tooltip: "Add new doc",
            shape: const CircleBorder(),
            child: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}
