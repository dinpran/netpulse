import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:netpulse/auth/login_page.dart';
import 'package:netpulse/helper/helper_functions.dart';
import 'package:netpulse/pages/home_page.dart';
import 'package:netpulse/service/auth_service.dart';
import 'package:netpulse/widgets/widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String email = "";
  String password = "";
  String fullName = "";
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool _isloading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                child: Form(
                  key: formkey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Become a Pulsian!",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Image.asset("assets/register.png"),
                        TextFormField(
                          decoration: textinputdecoration.copyWith(
                              label: Text("Enter your name"),
                              prefixIcon: Icon(Icons.person)),
                          onChanged: (value) {
                            setState(() {
                              fullName = value;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Name cannot be empty");
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: textinputdecoration.copyWith(
                              label: Text("Enter your email"),
                              prefixIcon: Icon(Icons.email)),
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                          validator: (value) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value!)
                                ? null
                                : "Please enter a valid email";
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: textinputdecoration.copyWith(
                              label: Text("Enter your password"),
                              prefixIcon: Icon(Icons.password)),
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                          validator: (value) {
                            if (value!.length < 6) {
                              return "password should be at least 6 charcters";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              register();
                            },
                            child: Text("Register"),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Alreadt have an account? ",
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(color: Colors.orange),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navigate to Sign Up page
                                    Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                      builder: (context) {
                                        return LoginPage();
                                      },
                                    ));
                                  },
                              )
                            ],
                          ),
                        ),
                      ]),
                ),
              ),
            ),
    );
  }

  register() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });
      await authService
          .registerUserWithEmailAndPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          await HelperFunctions.saveUserLoggedInKey(true);
          await HelperFunctions.saveUserNamenKey(fullName);
          await HelperFunctions.saveUserEmailKey(email);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              return HomePage();
            },
          ));
        } else {
          setState(() {
            _isloading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("${value.toString()}")));
        }
      });
    }
  }
}
