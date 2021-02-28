import 'package:flutter/material.dart';

import 'db_helper.dart';
import 'employee_model.dart';

class EmployeePage extends StatefulWidget {
  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();

  Future<List<Employee>> employees;

  String _employeeName;
  String _employeePhone;

  bool isUpdate = false;
  int employeeIdForUpdate;
  DBHelper dbHelper;

  final _employeeNameController = TextEditingController();
  final _employeePhoneController = TextEditingController();

  @override
  void initState() {
    dbHelper = DBHelper();
    refreshemployeeList();
    super.initState();
  }

  refreshemployeeList() {
    setState(() {
      employees = dbHelper.getEmployee();
    });
  }

  SingleChildScrollView generateList(List<Employee> employees) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          columns: [
            DataColumn(
              label: Text('Name'),
            ),
            DataColumn(
              label: Text('Description'),
            ),
            DataColumn(
              label: Text(''),
            )
          ],
          rows: employees
              .map(
                (employee) => DataRow(
              cells: [
                DataCell(
                  Text(employee.name),
                  onTap: () {
                    setState(() {
                      isUpdate = true;
                      employeeIdForUpdate = employee.id;
                    });
                    _employeeNameController.text = employee.name;
                    _employeePhoneController.text = employee.phone;
                  },
                ),
                DataCell(
                  Text(employee.phone),
                  onTap: () {
                    setState(() {
                      isUpdate = true;
                      employeeIdForUpdate = employee.id;
                    });
                    _employeeNameController.text = employee.name;
                    _employeePhoneController.text = employee.phone;
                  },
                ),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      dbHelper.delete(employee.id);
                      refreshemployeeList();
                    },
                  ),
                )
              ],
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite'),
        actions: <Widget>[
          RaisedButton(
            color: Colors.blue,
            child: Text(
              (isUpdate ? 'UPDATE' : 'ADD'),
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (isUpdate) {
                if (_formStateKey.currentState.validate()) {
                  _formStateKey.currentState.save();
                  dbHelper
                      .update(Employee(
                          employeeIdForUpdate, _employeeName, _employeePhone))
                      .then((data) {
                    setState(() {
                      isUpdate = false;
                    });
                  });
                }
              } else {
                if (_formStateKey.currentState.validate()) {
                  _formStateKey.currentState.save();
                  dbHelper.add(Employee(null, _employeeName, _employeePhone));
                }
              }
              _employeeNameController.text = '';
              _employeePhoneController.text = '';
              refreshemployeeList();
            },
          ),
          RaisedButton(
            color: Colors.blue,
            child: Text(
              (isUpdate ? 'CANCEL' : 'CLEAR'),
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              _employeeNameController.text = '';
              _employeePhoneController.text = '';
              setState(() {
                isUpdate = false;
                employeeIdForUpdate = null;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Form(
            key: _formStateKey,
            autovalidate: true,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    onSaved: (value) {
                      _employeeName = value;
                    },
                    keyboardType: TextInputType.text,
                    controller: _employeeNameController,
                    decoration: InputDecoration(
                        focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                                color: Colors.blue,
                                width: 2,
                                style: BorderStyle.solid)),
                        // hintText: "employee Name",
                        labelText: "Name",
                        fillColor: Colors.white,
                        labelStyle: TextStyle(
                          color: Colors.blue,
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    onSaved: (value) {
                      _employeePhone = value;
                    },
                    controller: _employeePhoneController,
                    decoration: InputDecoration(
                        focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                                color: Colors.blue,
                                width: 2,
                                style: BorderStyle.solid)),
                        // hintText: "employee Name",
                        labelText: "Description",
                        fillColor: Colors.white,
                        labelStyle: TextStyle(
                          color: Colors.blue,
                        )),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 5.0,
          ),
          Expanded(
            child: FutureBuilder(
              future: employees,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return generateList(snapshot.data);
                }
                if (snapshot.data == null || snapshot.data.length == 0) {
                  return Text('No Employee Found');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}
