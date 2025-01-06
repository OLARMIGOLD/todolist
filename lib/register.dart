import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  bool isObCure = true;
  final _validationKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future register() async {
    if (_validationKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });
        var cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        await FirebaseFirestore.instance
            .collection("users")
            .doc(cred.user?.uid)
            .set({
          "name": nameController.text.trim(),
          "age": ageController.text.trim(),
          "email": emailController.text.trim(),
          "uid": cred.user?.uid
        });
        setState(() {
          isLoading = false;
        });
      } on FirebaseException catch (e) {
        print(e.message);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("${e.message}")));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          width: 300,
          height: double.infinity,
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                )
              : SingleChildScrollView(
                  child: Form(
                    key: _validationKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Welcome! Please Register To Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is Required";
                            } else if (value.length < 6 ||
                                !value.contains(".") && !value.contains("@")) {
                              return "Enter a Valid Email";
                            } else {
                              return null;
                            }
                          },
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "Enter Email",
                            prefixIcon: Icon(Icons.email_rounded),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is Required";
                            } else if (value.length < 8) {
                              return "Password must not be less than 8";
                            } else {
                              return null;
                            }
                          },
                          controller: passwordController,
                          obscureText: isObCure,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "**********",
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isObCure = !isObCure;
                                });
                              },
                              child: Icon(isObCure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is Required";
                            } else if (!(value == passwordController.text)) {
                              return "Your Password is not Match";
                            } else {
                              return null;
                            }
                          },
                          controller: passwordController,
                          obscureText: isObCure,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            hintText: "**********",
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isObCure = !isObCure;
                                });
                              },
                              child: Icon(isObCure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Name is Required";
                            } else if (value.length < 3) {
                              return "Enter a Valid Name";
                            } else {
                              return null;
                            }
                          },
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Name",
                            hintText: "Enter Name",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Age is Required";
                            } else if (value.length < 2) {
                              return "Enter a Valid Age";
                            } else {
                              return null;
                            }
                          },
                          controller: ageController,
                          decoration: InputDecoration(
                            labelText: "Age",
                            hintText: "Enter Age",
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(
                          height: 70,
                        ),
                        GestureDetector(
                          onTap: register,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Register",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "You Already have an Account?",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              },
                              child: Text("Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  )),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
