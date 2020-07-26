import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sql_lite_app/model/task.dart';
import 'package:sql_lite_app/services/db_helper.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter SQLITE TODO LIST'),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Task>> tasks;
  TextEditingController controller = TextEditingController();
  String desc;
  int currUserId;

  final formKey = new GlobalKey<FormState>();
  DbHelper dbHelper;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    isUpdating = false;
    refreshList();
  }

  refreshList() {
    setState(() {
      tasks = dbHelper.getTasks();
    });
  }

  clearDesc() {
    controller.text = '';
  }

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        dbHelper.update(Task(id: currUserId, description: desc));
        setState(() => isUpdating = false);
      } else
        dbHelper.save(Task(id: null, description: desc));

      clearDesc();
      refreshList();
    }
  }

  form() {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Task',
              ),
              validator: (val) => val.length == 0 ? 'Add a Task' : null,
              onSaved: (val) => desc = val,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  onPressed: validate,
                  child: Text(isUpdating ? 'Update' : 'Add'),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() => isUpdating = false);
                    clearDesc();
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataTable(List<Task> Tasks) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('Description'),
          ),
          DataColumn(
            label: Text('Delete'),
          ),
        ],
        rows: Tasks.map(
          (task) => DataRow(
            cells: [
              DataCell(
                Text(task.description),
                onTap: () {
                  setState(() {
                    isUpdating = true;
                    currUserId = task.id;
                  });
                  controller.text = task.description;
                },
              ),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    dbHelper.delete(task.id);
                    refreshList();
                    clearDesc();
                    setState(() => isUpdating = false);
                  },
                ),
              ),
            ],
          ),
        ).toList(),
      ),
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: tasks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          } else if (snapshot.data == null || snapshot.data.length == 0) {
            return Text('No Data Found');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            form(),
            list(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
