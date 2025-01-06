import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map> todoList = [
    {
      "id": "",
      "title": "",
      "description": "",
      "status": "",
      "priority": "",
      "dueDate": "",
      "createdAt": "",
      "completedAt": "",
      "progress": "",
      "comments": "",
      "attachments": ""
    }
  ];

  Map<String, dynamic>? user;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  getUser() async {
    try {
      var docs = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      setState(() {
        user = docs.data();
      });
    } on FirebaseException {
      getUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    const CircleAvatar(
                      radius: 60,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${user?['name']}"),
                            Text("${user?['email']}"),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "LogOut",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Column(
              children: [
                ListTile(
                  leading: CircleAvatar(),
                  title: Text("Complete Task"),
                ),
                ListTile(
                  leading: CircleAvatar(),
                  title: Text("ongoing Task"),
                ),
                ListTile(
                  leading: CircleAvatar(),
                  title: Text("Pending Task"),
                ),
                ListTile(
                  leading: CircleAvatar(),
                  title: Text(
                    "LogOut",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const CreateTaskWidget());
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 110,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.add_box_sharp),
              Text(
                "Add Task",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .collection("task")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              );
            } else if (snapshot.hasData) {
              var task = snapshot.data!.docs;
              return ListView.builder(
                itemCount: task.length,
                itemBuilder: (context, index) {
                  var tasks = task[index].data();
                  return Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text("${tasks['title']}",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    )),
                                Text("${tasks['description']}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    )),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text("Are You Sure?"),
                                          actionsOverflowButtonSpacing: 10,
                                          actions: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                height: 45,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: Colors.green)),
                                                child: Center(
                                                  child: Text("Cancel"),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser?.uid)
                                                    .collection("task")
                                                    .doc(tasks["id"])
                                                    .delete();
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                height: 45,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: Colors.red)),
                                                child: Center(
                                                  child: Text("Delete"),
                                                ),
                                              ),
                                            )
                                          ],
                                        ));
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Column(
                  children: [Icon(Icons.no_accounts), Text("No Task Found")],
                ),
              );
            }
          }),
    );
  }
}

class CreateTaskWidget extends StatefulWidget {
  const CreateTaskWidget({
    super.key,
  });

  @override
  State<CreateTaskWidget> createState() => _CreateTaskWidgetState();
}

class _CreateTaskWidgetState extends State<CreateTaskWidget> {
  final titleEditingController = TextEditingController();
  final descriptionEditingController = TextEditingController();
  TextEditingController dateTimecontroller = TextEditingController();
  final commentsEditingController = TextEditingController();
  File? image;
  DateTime? pickedDate;
  String status = "Pending";
  String priority = "Low";
  bool isprocessing = false;
  final validationkey = GlobalKey<FormState>();

  List ListOfStatus = ["Pending", "Ongoing", "Completed"];
  List ListOfPriority = ["Low", "Medium", "High"];

  List<Map> todoList = [
    {
      "id": "",
      "title": "",
      "description": "",
      "status": "",
      "priority": "",
      "dueDate": "",
      "createdAt": "",
      "completedAt": "",
      "progress": "",
      "comments": "",
      "attachments": ""
    }
  ];

  pickingOfImage(ImageSource imageSource) async {
    XFile? pickedImage = await ImagePicker().pickImage(source: imageSource);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    } else {}
  }

  Future<void> saveTaskToDb() async {
    try {
      if (validationkey.currentState!.validate()) {
        String taskId = Uuid().v4();

        setState(() {
          isprocessing = true;
        });

        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection("task")
            .doc(taskId)
            .set({
          "id": taskId,
          "title": titleEditingController.text,
          "description": descriptionEditingController.text,
          "status": status,
          "priority": priority,
          "dueDate": pickedDate!.toIso8601String(),
          "createdAt": DateTime.now().toIso8601String(),
          "updatedAt": DateTime.now().toIso8601String(),
          "completedAt": null,
          "progress": 0,
          "comments": commentsEditingController.text,
          "attachments": ''
        });
        setState(() {
          isprocessing = false;
        });
        Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
    } finally {
      setState(() {
        isprocessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.85,
      width: double.infinity,
      child: isprocessing
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Create New Task",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Colors.green)),
                        Text("Efficently manage your time and responsibilities",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10),
                    child: Form(
                        key: validationkey,
                        child: Column(
                          spacing: 15,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Title is Requred";
                                      } else {
                                        return null;
                                      }
                                    },
                                    controller: titleEditingController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      hintText: "Enter Your Title",
                                      labelText: "Title",
                                    ))
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Description is Requred";
                                      } else {
                                        return null;
                                      }
                                    },
                                    controller: descriptionEditingController,
                                    maxLines: 2,
                                    minLines: 2,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      hintText: "Enter Your Description",
                                      labelText: "Description",
                                    ))
                              ],
                            ),
                            Row(
                              spacing: 15,
                              children: [
                                Expanded(
                                    child: Column(
                                  children: [
                                    DropdownButtonFormField(
                                        items: ListOfStatus.map(
                                            (staus) => DropdownMenuItem(
                                                  child: Text(staus),
                                                  value: staus,
                                                )).toList(),
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            hintText: "Select Status",
                                            labelText: "Status"),
                                        onChanged: (value) {
                                          setState(() {
                                            status = value as String;
                                          });
                                        })
                                  ],
                                )),
                                Expanded(
                                    child: Column(
                                  children: [
                                    DropdownButtonFormField(
                                        items: ListOfPriority.map(
                                            (priority) => DropdownMenuItem(
                                                  child: Text(priority),
                                                  value: priority,
                                                )).toList(),
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            hintText: "Select priority",
                                            labelText: "priority"),
                                        onChanged: (value) {
                                          setState(() {
                                            priority = value as String;
                                          });
                                        })
                                  ],
                                ))
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                    validator: (value) {
                                      if (pickedDate == null) {
                                        return "Kindly Pick your Date";
                                      }
                                      if (pickedDate == null ||
                                          dateTimecontroller.text.isEmpty) {
                                        return "Date is Requred";
                                      } else {
                                        return null;
                                      }
                                    },
                                    controller: dateTimecontroller,
                                    readOnly: true,
                                    onTap: () async {
                                      pickedDate = await showDatePicker(
                                          context: context,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 730)));
                                      setState(() {
                                        dateTimecontroller.text =
                                            pickedDate == null
                                                ? ""
                                                : DateFormat("EEE, M/d/y")
                                                    .format(pickedDate!);
                                        pickedDate?.toIso8601String() ?? "";
                                      });
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      hintText: "Pick the Due Date",
                                      labelText: "Due Date",
                                    ))
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                    controller: commentsEditingController,
                                    maxLines: 4,
                                    minLines: 4,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      hintText: "Enter Your Comments",
                                      labelText: "Comments",
                                    ))
                              ],
                            ),
                            Container(
                              height: 250,
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 30),
                              decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(8),
                                  image: image != null
                                      ? DecorationImage(
                                          image: FileImage(image!),
                                          fit: BoxFit.cover)
                                      : null),
                              child: image != null
                                  ? Align(
                                      alignment: Alignment.topRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            image = null;
                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  actionsOverflowButtonSpacing:
                                                      10,
                                                  title:
                                                      const Text("Pick Image"),
                                                  actions: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        pickingOfImage(
                                                            ImageSource
                                                                .gallery);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.green),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: const Center(
                                                            child: Text(
                                                                "Gallery")),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);

                                                        pickingOfImage(
                                                            ImageSource.camera);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.green,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.green),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: const Center(
                                                            child: Text(
                                                          "Camera",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.red,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.red),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: const Center(
                                                            child: Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                      },
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              border: Border.all(
                                                  color: Colors.green)),
                                          child: const Text("Pick Image"),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        )),
                  ),
                  GestureDetector(
                    onTap: saveTaskToDb,
                    child: Container(
                      height: 48,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Center(
                        child: Text(
                          "Create Task",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
