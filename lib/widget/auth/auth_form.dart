import 'dart:io';

import '/widget/picker/user_image_picker.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  bool isLoading;

  AuthForm(this.submitFn, this.isLoading);

  final void Function(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formkey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _userEmail = '';
  String _userName = '';
  String _passsword = '';
  File _userImageFile = File('');

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    final isValid = _formkey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null && !_isLogin) {
      Scaffold.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick an image'),
        ),
      );
      return;
    }

    if (isValid) {
      _formkey.currentState!.save();
      widget.submitFn(
        _userEmail.trim(),
        _passsword.trim(),
        _userName.trim(),
        _userImageFile,
        _isLogin,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedContainer(
          // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          height: _isLogin ? 310 : 500,
          child: Card(
            margin: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isLogin) UserImagePicker(_pickedImage),
                      TextFormField(
                        autocorrect: true,
                        enableSuggestions: true,
                        key: const ValueKey('Email'),
                        validator: ((value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        }),
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(labelText: 'Email address'),
                        onSaved: (value) {
                          _userEmail = value!;
                        },
                      ),
                      if (!_isLogin)
                        TextFormField(
                          autocorrect: true,
                          enableSuggestions: true,
                          key: const ValueKey('UserName'),
                          validator: ((value) {
                            if (value!.isEmpty || value.length < 4) {
                              return 'User is very short.';
                            }
                            return null;
                          }),
                          decoration: const InputDecoration(
                            labelText: 'UserName',
                          ),
                          onSaved: (value) {
                            _userName = value!;
                          },
                        ),
                      TextFormField(
                        key: const ValueKey('Password'),
                        validator: ((value) {
                          if (value!.isEmpty || value.length < 7) {
                            return 'Please enter at least 7 corrector.';
                          }
                          return null;
                        }),
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        onSaved: (value) {
                          _passsword = value!;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (widget.isLoading) CircularProgressIndicator(),
                      if (!widget.isLoading)
                        ElevatedButton(
                          onPressed: _trySubmit,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(_isLogin ? 'Login' : 'Signup'),
                        ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                          _isLogin
                              ? 'Create new account'
                              : 'I already have an account',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
