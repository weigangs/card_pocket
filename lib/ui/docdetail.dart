import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as datatTimePicker;
import '../model/model.dart';
import '../util/utils.dart' as card_utils;
import '../util/dbhelper.dart';

// Menu item
const menuDelete = "Delete";
final List<String> menuOptions = const <String>[menuDelete];

class DocDetail extends StatefulWidget {
  Doc doc;
  final DbHelper dbh = DbHelper();
  DocDetail(this.doc);
  @override
  State<StatefulWidget> createState() => DocDetailState();
}

class DocDetailState extends State<DocDetail> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = new GlobalKey<ScaffoldMessengerState>();
  final int daysAhead = 5475; // 15 years in the future
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController expirationCtrl =
      MaskedTextController(mask: '2000-00-00');
  bool fqYearCtrl = true;
  bool fqHalfYearCtrl = true;
  bool fqQuarterCtrl = true;
  bool fqMonthCtrl = true;
  bool fqLessMonthCtrl = true;
  // Initialization code
  void _initCtrls() {
    titleCtrl.text = widget.doc.title != null ? widget.doc.title : "";
    expirationCtrl.text =
        widget.doc.expiration != null ? widget.doc.expiration : "";
    fqYearCtrl =
        widget.doc.fqYear != null ? card_utils.Val.intToBool(widget.doc.fqYear) : false;
    fqHalfYearCtrl = widget.doc.fqHalfYear != null
        ? card_utils.Val.intToBool(widget.doc.fqHalfYear)
        : false;
    fqQuarterCtrl = widget.doc.fqQuarter != null
        ? card_utils.Val.intToBool(widget.doc.fqQuarter)
        : false;
    fqMonthCtrl =
        widget.doc.fqMonth != null ? card_utils.Val.intToBool(widget.doc.fqMonth) : false;
  }

  // Date Picker & Date functions
  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = card_utils.DateUtils.convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= now.year && initialDate.isAfter(now)
        ? initialDate
        : now);
    datatTimePicker.DatePicker.showDatePicker(context, showTitleActions: true,
        onConfirm: (date) {
      setState(() {
        DateTime dt = date;
        String r = card_utils.DateUtils.ftDateAsStr(dt);
        expirationCtrl.text = r;
      });
    }, currentTime: initialDate);
  }

  // Upper Menu
  void _selectMenu(String value) async {
    switch (value) {
      case menuDelete:
        if (widget.doc.id == -1) {
          return;
        }
        _deleteDoc(widget.doc.id);
    }
  }

  // Delete doc
  void _deleteDoc(int id) async {
    int r = await widget.dbh.deleteDoc(widget.doc.id);
    Navigator.pop(context, true);
  }

  // Save doc
  void _saveDoc() {
    widget.doc.title = titleCtrl.text;
    widget.doc.expiration = expirationCtrl.text;
    widget.doc.fqYear = card_utils.Val.boolToInt(fqYearCtrl);
    widget.doc.fqHalfYear = card_utils.Val.boolToInt(fqHalfYearCtrl);
    widget.doc.fqQuarter = card_utils.Val.boolToInt(fqQuarterCtrl);
    widget.doc.fqMonth = card_utils.Val.boolToInt(fqMonthCtrl);
    if (widget.doc.id > -1) {
      debugPrint("_update->Doc Id: " + widget.doc.id.toString());
      widget.dbh.updateDoc(widget.doc);
      Navigator.pop(context, true);
    } else {
      Future<int?> idd = widget.dbh.getMaxId();
      idd.then((result) {
        debugPrint("_insert->Doc Id: " + widget.doc.id.toString());
        widget.doc.id = (result != null) ? result + 1 : 1;
        widget.dbh.insertDoc(widget.doc);
        Navigator.pop(context, true);
      });
    }
  }

  void _submitForm() {
    final FormState? form = _formKey.currentState;
    if (!form!.validate()) {
      showMessage('Some data is invalid. Please correct.');
    } else {
      _saveDoc();
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState?.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _initCtrls();
  }

  @override
  Widget build(BuildContext context) {
    const String cStrDays = "Enter a number of days";
    TextStyle? tStyle = Theme.of(context).textTheme.titleMedium;
    String ttl = widget.doc.title;
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Text(ttl != "" ? widget.doc.title : "New Document"),
            actions: (ttl == "")
                ? <Widget>[]
                : <Widget>[
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
        body: Form(
            autovalidateMode: AutovalidateMode.always, key: _formKey,
            child: SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp("[a-zA-Z0-9]"), allow: true)
                    ],
                    controller: titleCtrl,
                    style: tStyle,
                    validator: (val) => card_utils.Val.validateTitle(val),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.title),
                      hintText: 'Enter the document name',
                      labelText: 'Document Name',
                    ),
                  ),
                  Row(children: <Widget>[
                    Expanded(
                        child: TextFormField(
                      controller: expirationCtrl,
                      maxLength: 10,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.calendar_today),
                          hintText: 'Expiry date (i.e. ' +
                              card_utils.DateUtils.daysAheadAsStr(daysAhead) +
                              ')',
                          labelText: 'Expiry Date'),
                      keyboardType: TextInputType.number,
                      validator: (val) => card_utils.DateUtils.isValidDate(val!)
                          ? null
                          : 'Not a valid future date',
                    )),
                    IconButton(
                      icon: new Icon(Icons.more_horiz),
                      tooltip: 'Choose date',
                      onPressed: (() {
                        _chooseDate(context, expirationCtrl.text);
                      }),
                    )
                  ]),
                  const Row(children: <Widget>[
                    Expanded(child: Text(' ')),
                  ]),
                  Row(children: <Widget>[
                    const Expanded(child: Text('Alert less than a year')),
                    Switch(
                        value: fqYearCtrl,
                        onChanged: (bool value) {
                          setState(() {
                            fqYearCtrl = value;
                          });
                        }),
                  ]),
                  Row(children: <Widget>[
                    const Expanded(child: Text('Alert less than six months')),
                    Switch(
                        value: fqHalfYearCtrl,
                        onChanged: (bool value) {
                          setState(() {
                            fqHalfYearCtrl = value;
                          });
                        }),
                  ]),
                  Row(children: <Widget>[
                    const Expanded(child: Text('Alert less than three months')),
                    Switch(
                        value: fqQuarterCtrl,
                        onChanged: (bool value) {
                          setState(() {
                            fqQuarterCtrl = value;
                          });
                        }),
                  ]),
                  Row(children: <Widget>[
                    const Expanded(child: Text('Alert less than a month')),
                    Switch(
                        value: fqMonthCtrl,
                        onChanged: (bool value) {
                          setState(() {
                            fqMonthCtrl = value;
                          });
                        }),
                  ]),
                  Container(
                      padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                      child: FilledButton(
                  onPressed: _submitForm,
                  child: const Text('Save'),
                )),
                ],
              ),
            )));
  }
}
