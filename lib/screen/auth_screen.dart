import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat_app/utils/app_layout.dart';
import 'package:simple_chat_app/widget/user_image_picker.dart';
import 'package:string_validator/string_validator.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  var _email;
  var _password;
  var _selectedImage;
  var _username;
  var _isAuthenticating = false;

  void _submit() async {
    if (!_formKey.currentState!.validate() ||
        (!_isLogin && _selectedImage == null)) {
      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${userCredentials.user!.uid}.jpg");
        await storageRef.putFile(_selectedImage);
        setState(() {
          _isAuthenticating = false;
        });
        final imageUrl = await storageRef.getDownloadURL();

        FirebaseFirestore.instance
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set(
                {"username": _username, "email": _email, "imageUrl": imageUrl});
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? "Authentication failed"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayWidth = AppLayout.displayWidth(context);
    final displayHeight = AppLayout.displayHeightWithoutAppBar(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: displayWidth * 0.01,
                    vertical: displayHeight * 0.07),
                width: displayWidth * 0.4,
                child: Image.asset("assets/images/chat.png"),
              ),
              Card(
                margin: EdgeInsets.all(displayWidth * 0.07),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(displayWidth * 0.05),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickedImage: (imageFile) {
                                _selectedImage = imageFile;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                                label: Text("Email address")),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null) {
                                return "Email mustn't be null";
                              }
                              if (!isEmail(value)) {
                                return "You must provide a valid email";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                  label: Text("Username")),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.trim().length < 4) {
                                  return "Enter a valid username";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _username = value;
                              },
                            ),
                          TextFormField(
                            decoration:
                                const InputDecoration(label: Text("Password")),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 8) {
                                return "Enter a valid password";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value;
                            },
                          ),
                          SizedBox(
                            height: displayHeight * 0.03,
                          ),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                              ),
                              child: Text(
                                _isLogin ? "Login" : "Sign up",
                              ),
                            ),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? "Create an account"
                                  : "Already have an account ? "),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
