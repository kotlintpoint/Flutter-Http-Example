
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_http_demo/models/user.dart';

Future<User> createUser(User user) async {
  final response = await http.post(
    Uri.parse('https://dummyjson.com/users/add'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(user)
  );

  if(response.statusCode == 201){
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create user.');
  }
}

Future<List<User>> fetchUsers() async {
  final response = await http.get(
    Uri.parse('https://dummyjson.com/users')
  );
  if(response.statusCode == 200){
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List users = jsonResponse["users"];
    return users.map((user) => User.fromJson(user)).toList();
  } else {
    throw Exception('Failed to load users.');
  }
}

Future<User> updateUser(int? id, User user) async {
  final response = await http.put(
    Uri.parse('https://dummyjson.com/users/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(user.toJson())
  );

  if(response.statusCode == 200){
    return User.fromJson(jsonDecode(response.body));
  }else {
    throw Exception('Failed to updated user.');
  }
}

Future<User> deleteUser(int id) async {
  final response = await http.delete(
    Uri.parse('https://dummyjson.com/users/$id'),
    headers: {'Content-Type': 'application/json'}
  );

  if(response.statusCode == 200){
    return User.fromJson(jsonDecode(response.body));
  }else {
    throw Exception('Failed to delete user.');
  }
}

Future<List<User>> addOrUpdateUser(Future<List<User>> futureUsers, User newUser, int? index) async {
  // Await the completion of the original future to get the list of users
  List<User> users = await futureUsers;
  // Add the new user to the list
  if(index == null){
    users.insert(0, newUser);
  }else{
    users[index] = newUser;
  }
  // Return a new future with the updated list
  return users;
}

Future<List<User>> removeUser(Future<List<User>> futureUsers, int? index) async {
  // Await the completion of the original future to get the list of users
  List<User> users = await futureUsers;
  // Add the new user to the list
  users.removeAt(index!);
  // Return a new future with the updated list
  return users;
}

