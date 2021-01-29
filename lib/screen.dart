import 'package:db_display/emp.dart';
import 'package:flutter/material.dart';

//import 'employee.dart';
import 'dart:async';
import 'db_helper.dart';

class DBTestPage extends StatefulWidget {
  final String title;

  DBTestPage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DBTestPageState();
  }
}

class _DBTestPageState extends State<DBTestPage> {
  //
  Future<List<Employee>> employees;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  String name;
  String age;
  int curUserId;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }

  refreshList() {
    setState(() {
      employees = dbHelper.getEmployees();
    });
  }

  clearName() {
    namecontroller.text = '';
    agecontroller.text = '';
  }

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        Employee e = Employee(curUserId, name, age);
        dbHelper.update(e);
        setState(() {
          isUpdating = false;
        });
      } else {
        Employee e = Employee(null, name, age);
        dbHelper.save(e);
      }
      clearName();
      refreshList();
    }
  }

  form() {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 30),
              child: TextFormField(
                controller: namecontroller,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(fontSize: 22, color: Colors.blue)),
                validator: (val) => val.length == 0 ? 'Enter Name' : null,
                onSaved: (val) => name = val,
              ),
            ),
            TextFormField(
              controller: agecontroller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  labelText: 'Age',
                  labelStyle: TextStyle(fontSize: 22, color: Colors.blue)),
              validator: (val1) => val1.length == 0 ? 'Enter Age' : null,
              onSaved: (val1) => age = val1,
            ),
            Container(
              padding: const EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    color: Colors.green,
                    onPressed: validate,
                    child: Text(isUpdating ? 'UPDATE' : 'ADD'),
                  ),
                  FlatButton(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    color: Colors.pink,
                    onPressed: () {
                      setState(() {
                        isUpdating = false;
                      });
                      clearName();
                    },
                    child: Text('CANCEL'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataTable(List<Employee> employees) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        //color: Colors.lightBlueAccent,
        margin: const EdgeInsets.only(top: 40),
          child: Card(
            elevation: 20,
            child: ListTile(
              title: DataTable(
                columnSpacing: 150.0,
                columns: [
                  DataColumn(
                    label: Text('NAME'),
                  ),
                  DataColumn(
                    label: Text('AGE'),
                  ),
                  DataColumn(
                    label: Text('DELETE'),
                  ),
                ],
                rows: employees
                    .map(
                      (employee) => DataRow(cells: [
                        DataCell(
                          Text(employee.name),
                          onTap: () {
                            setState(() {
                              isUpdating = true;
                              curUserId = employee.id;
                            });
                            namecontroller.text = employee.name;
                           //agecontroller.text = employee.name;
                          },
                        ),
                        DataCell(
                          Text(employee.age),
                          onTap: () {
                            setState(() {
                              isUpdating = true;
                              curUserId = employee.id;
                            });
                            //namecontroller.text = employee.age;
                            agecontroller.text = employee.age;
                          },
                        ),
                        DataCell(IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            dbHelper.delete(employee.id);
                            refreshList();
                          },
                        )),
                      ]),
                    )
                    .toList(),
              ),
            ),
          ),

      ),
    );
  }



  list() {
    return Expanded(
      child: FutureBuilder(
        future: employees,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          }

          if (null == snapshot.data || snapshot.data.length == 0) {
            return Text("No Data Found");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('LIST VIEW'),
        centerTitle: true,
      ),
      body: new Container(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            form(),
            list(),
          ],
        ),
      ),
    );
  }
}
