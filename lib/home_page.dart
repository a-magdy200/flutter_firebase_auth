import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_refresh/bloc/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:http/http.dart" as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _email = "admin@anchorz.com";
  String _password = "123123";
  String _name = "";
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = _email;
    _passwordController.text = _password;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, String>(
      builder: (context, token) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (email) {
                    setState(() {
                      _email = email;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  controller: _passwordController,
                  onChanged: (password) {
                    _password = password;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Get the current user from firebase or authenticate
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        UserCredential userCredentials = await FirebaseAuth
                            .instance
                            .signInWithEmailAndPassword(
                          email: _email,
                          password: _password,
                        );
                        user = userCredentials.user;
                      }
                      IdTokenResult? idTokenResult =
                          await user?.getIdTokenResult();
                      if (idTokenResult != null) {
                        String idToken = idTokenResult.token ?? "";
                        context.read<AuthCubit>().signIn(idToken);
                      }
                    } on FirebaseAuthException catch (error) {}
                  },
                  child: const Text("Get Token"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      http.Response response = await http.post(
                          Uri.parse("http://10.0.2.2:3000/graphql"),
                          headers: {
                            // "Authorization": "Bearer $token",
                            "Content-Type": "application/json"
                          },
                          body: jsonEncode({"query": "{countries{id}}"}));
                      print(response.body);
                    } catch (e) {
                      // handle error
                      print(e);
                    }
                  },
                  child: const Text("Get Countries"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Example on register user
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                              email: _email, password: _password);
                      String? uid = userCredential.user?.uid;
                      if (uid != null) {
                        http.Response response = await http.post(
                            Uri.parse("http://10.0.2.2:3000/graphql"),
                            headers: {
                              // "Authorization": "Bearer $token",
                              "Content-Type": "application/json"
                            },
                            body: jsonEncode({
                              "query":
                                  "mutation CreateUser(\$createUserInput: CreateUserInput!){createUser(createUserInput:\$createUserInput){id uid}}",
                              "variables": {
                                "createUserInput": {
                                  "uid": uid,
                                  "phone": "12345678912345",
                                  "countryId": 1
                                }
                              }
                            }));
                        print(response.body);
                      }
                    } catch (e) {
                      // handle error
                      print(e);
                    }
                  },
                  child: const Text("Register New User"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Example on getting user profile
                    try {
                      http.Response response = await http.post(
                          Uri.parse("http://10.0.2.2:3000/graphql"),
                          headers: {
                            "Authorization": "Bearer $token",
                            "Content-Type": "application/json"
                          },
                          body: jsonEncode({
                            "query":
                                "query GetProfile{profile{id moto firstName lastName photo phone country{ id name } bestStreak dayRun totalSmiles initiated_streaks {id} received_streaks {id} reported_users{id } reporter_users{id}blocked_users{id}blocker_users{id}}}",
                          }));
                      Map<String, dynamic> d = jsonDecode(response.body);
                      // Map<String, Map<String, Map<String, Map<String, dynamic>>>> d =jsonDecode(response.body);
                      String firstName = d['data']?['profile']?['firstName'];
                      setState(() {
                        _name = firstName;
                      });
                      _nameController.text = firstName;
                      print(response.body);
                    } catch (e) {
                      // handle error
                      print(e);
                    }
                  },
                  child: const Text("Get Profile"),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  controller: _nameController,
                  onChanged: (name) {
                    setState(() {
                      _name = name;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Example on updating profile
                    try {
                      http.Response response = await http.post(
                          Uri.parse("http://10.0.2.2:3000/graphql"),
                          headers: {
                            "Authorization": "Bearer $token",
                            "Content-Type": "application/json"
                          },
                          body: jsonEncode({
                            "query":
                                "mutation EditProfile(\$updateUserInput: UpdateUserInput!){updateProfile(updateUserInput: \$updateUserInput){id moto firstName lastName photo phone country{ id name } bestStreak dayRun totalSmiles initiated_streaks {id} received_streaks {id} reported_users{id } reporter_users{id}blocked_users{id}blocker_users{id}}}",
                            "variables": {
                              "updateUserInput": {"firstName": _name}
                            }
                          }));
                      print(response.body);
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text("Update Profile"),
                ),
              ],
            ),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}
