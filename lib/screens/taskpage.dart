import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/database_helper.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/models/todo.dart';
import '../widgets.dart';
class Taskpage extends StatefulWidget {
  final Task task;
  Taskpage({@required this.task});

  @override
  _TaskpageState createState() => _TaskpageState();
}

class _TaskpageState extends State<Taskpage> {
  DatabaseHelper _dbHelper = DatabaseHelper();

  int _taskId = 0;
  String _taskTitle = "";
  String _taskDescription = "";

  FocusNode _titleFocus;
  FocusNode _descriptionFocus;
  FocusNode _todoFocus;

  bool _ContentVisile = false;
  @override
  void initState() {
    // TODOo implement initState
    if(widget.task != null){
      //Set visibility to true
      _ContentVisile = true;


      _taskTitle = widget.task.title;
      _taskDescription = widget.task.description;
      _taskId = widget.task.id;
    }

    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _todoFocus = FocusNode();


    super.initState();
  }

  @override
  void dispose() {

    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _todoFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child:Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Padding(
                padding:EdgeInsets.only(
                  top: 24.0,
                  bottom: 6.0,
              ),
                child: Row(
                children: [
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Image(
                          image: AssetImage(
                'assets/images/back_arrow_icon.png'
                          ),
                          ),
                      ),
                    ),
                  Expanded(
                    child: TextField(
                    focusNode: _titleFocus,
                    onSubmitted: (value) async{
                      // check if the field is null
                      if(value != "") {
                        //check if the field is null
                        if (widget.task == null) {
                          Task _newTask = Task(title: value);
                        _taskId = await _dbHelper.insertTask(_newTask);
                        setState(() {
                          _ContentVisile = true;
                          _taskTitle = value;
                        });
                        } else {
                          await _dbHelper.UpdateTaskTitle(_taskId, value);
                          print("Task Updated");
                        }
                        _descriptionFocus.requestFocus();
                      }
                    },
                    controller: TextEditingController()..text = _taskTitle,
                    decoration: InputDecoration(
                      hintText: "Enter Task Title",
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF211551),
                    ),
                  ),)
                ],
    ),
              ),
                Visibility(
                  visible: _ContentVisile,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 12.0,
                    ),
                    child: TextField(
                      focusNode: _descriptionFocus,
                      onSubmitted: (value) async {
                        if(value != ""){
                          if(_taskId != 0){
                           await _dbHelper.UpdateTaskDescription(_taskId,value);
                           _taskDescription = value;
                          }
                        }
                        _todoFocus.requestFocus();

                      },
                      controller: TextEditingController()..text = _taskDescription,
                      decoration: InputDecoration(
                        hintText: 'Enter Description for the Task...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 24.0,
                        )
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _ContentVisile,
                  child: FutureBuilder(
                    initialData: [],
                    future: _dbHelper.getTodo(_taskId),
                    builder: (context,snapshot){
                      return Expanded(
                        child: ListView.builder (
                          itemCount: snapshot.data.length,
                        itemBuilder: (context,index){
                            return GestureDetector(
                              onTap: () async {
                                //Switch the todoo completion state
                                if(snapshot.data[index].isDone == 0){
                                 await  _dbHelper.UpdateTodoDone(snapshot.data[index].id,1);
                                }else {
                                await  _dbHelper.UpdateTodoDone(snapshot.data[index].id,0);
                                }
                                setState(() {});
                              },
                              child: TodoWidget(
                                text: snapshot.data[index].title,
                                isDone: snapshot.data[index].isDone == 0 ? false : true,
                              ),
                            );
                        },
                        ),
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: _ContentVisile,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,

                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            right: 12.0,
                          ),
                          width: 20.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                              color:  Colors.transparent,
                              borderRadius: BorderRadius.circular(6.0),
                              border:Border.all(
                                color: Color(0XFF868290),
                                width: 1.5,
                              )
                          ),
                          child: Image(
                            image: AssetImage(
                                'assets/images/check_icon.png'
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            focusNode: _todoFocus,
                            controller:  TextEditingController()..text = "",
                            onSubmitted: (value) async  {
                              // check if the field is not empty
                              if(value != "") {
                                //check if the task is null
                                if (_taskId != 0) {
                                  DatabaseHelper _dbHelper = DatabaseHelper();
                                  Todo _newTodo = Todo(
                                      title: value,
                                      isDone: 0,
                                      taskId: _taskId,
                                  );
                                  await _dbHelper.insertTodo(_newTodo);
                                    setState(() {});
                                    _todoFocus.requestFocus();
                                }else{
                                  print("Task doesn't exist FOR TODO |");
                                }
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Enter Todo item....",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

    ],
    ),
              Visibility(
                visible: _ContentVisile,
                child: Positioned(
                  bottom: 24.0,
                  right: 24.0,
                  child: GestureDetector(
                    onTap: () async{
                    if(_taskId != 0){
                      await _dbHelper.deleteTask(_taskId);
                      Navigator.pop(context);
                    }
                    },
                    child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Color(0XFFFE3577),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child:Image(
                          image: AssetImage(
                            "assets/images/delete_icon.png",
                          ),
                        )
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
