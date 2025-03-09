import 'package:flutter/material.dart';
import 'package:flutter_http_demo/models/user.dart';
import 'package:flutter_http_demo/services/user_service.dart';

class UserForm extends StatefulWidget {
  final User? user;

  const UserForm({super.key, this.user});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  late String _firstName, _lastName, _email;

  @override
  void initState() {
    super.initState();
    _firstName = widget.user?.firstName ?? '';
    _lastName = widget.user?.lastName ?? '';
    _email = widget.user?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Add user' : 'Edit user'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _firstName,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _firstName = value!;
                },
              ),
              TextFormField(
                initialValue: _lastName.toString(),
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _lastName = value!;
                },
              ),
              TextFormField(
                initialValue: _lastName.toString(),
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    User user;
                    if (widget.user == null) {
                      // Add new user
                      user = await createUser(User(firstName: _firstName, lastName: _lastName, email: _email));
                    } else {
                      // Update existing user
                      user = await updateUser(widget.user!.id, User(firstName: _firstName, lastName: _lastName, email: _email));
                    }
                    if (context.mounted) Navigator.pop(context, {"status": true, "user": user});
                  }
                },
                child: Text(widget.user == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}