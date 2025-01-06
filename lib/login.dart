import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/forgetpass.dart';
import 'package:todo_list/home.dart';
import 'package:todo_list/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObCure = true;
  final _validationKey = GlobalKey<FormState>();
  bool isProcessing = false;

  Future signInUsingEmailPassword() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (_validationKey.currentState!.validate()) {
      try {
        setState(() {
          isProcessing = true;
        });
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Login Sucessful..."),
          backgroundColor: Colors.green,
        ));

        setState(() {
          isProcessing = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (v) => false);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided.');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("${e.message}"),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 48),
          child: Center(
            child: SizedBox(
              width: 300,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Form(
                  key: _validationKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Welcome Back Please Login To Continue",
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
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Forgetpass()));
                        },
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "Forget password?",
                            style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.green),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 70,
                      ),
                      isProcessing
                          ? CircularProgressIndicator()
                          : GestureDetector(
                              onTap: signInUsingEmailPassword,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Login",
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
                            "Don't have an Account?",
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
                                      builder: (context) => RegisterScreen()));
                            },
                            child: Text("Sign Up",
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
        ));
  }
}
