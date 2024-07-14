import 'package:flutter/material.dart';
import '../model/Student.dart';

class SubmissionForm extends StatefulWidget {
  final bool isEditing;
  final Student? student;
  final Function(Student, bool) onSubmitSuccess;

  SubmissionForm({
    required this.isEditing,
    required this.student,
    required this.onSubmitSuccess,
  });

  @override
  _SubmissionFormState createState() => _SubmissionFormState();
}

class _SubmissionFormState extends State<SubmissionForm> {
  final _formKey = GlobalKey<FormState>();
  late String _studentName;
  late String _studentAddress;
  late String _mobile;

  @override
  void initState() {
    super.initState();
    // Initialize fields based on whether editing an existing student or adding a new one
    if (widget.isEditing && widget.student != null) {
      _studentName = widget.student!.studentName;
      _studentAddress = widget.student!.studentAddress;
      _mobile = widget.student!.mobile;
    } else {
      _studentName = '';
      _studentAddress = '';
      _mobile = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Student' : 'Add Student'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _studentName,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _studentName = value!;
                },
              ),
              TextFormField(
                initialValue: _studentAddress,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _studentAddress = value!;
                },
              ),
              TextFormField(
                initialValue: _mobile,
                decoration: InputDecoration(labelText: 'Mobile'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a mobile number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _mobile = value!;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a new Student object based on form data
      final newStudent = Student(
        studentName: _studentName,
        studentAddress: _studentAddress,
        mobile: _mobile,
      );

      // Pass the new student and whether it's editing or adding to the callback function
      widget.onSubmitSuccess(newStudent, widget.isEditing);

      // Navigate back to the previous screen
      Navigator.pop(context);
    }
  }
}
