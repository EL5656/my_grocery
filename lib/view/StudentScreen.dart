import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/Student.dart';
import '../shared/Config.dart';
import 'SubmissionForm.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  List<Student> _students = [];
  String _errorMessage = '';
  final String getAllStudent = Config.server + "8081/api/v1/student/getAll";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubmissionForm(
                isEditing: false,
                student: null, // No student data when adding a new student
                onSubmitSuccess:
                    _handleSubmissionSuccess, // Pass callback function
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _handleSubmissionSuccess(Student student, bool isEditing) {
    setState(() {
      if (isEditing) {
        // Update the existing student in the list
        updateStudent(student);
      } else {
        // Add the new student to the list
        saveStudent(student); //backend
        _students.add(student); //ui
      }
    });
  }

  Widget _buildBody() {
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    } else if (_students.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${student.studentName}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Address: ${student.studentAddress}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Mobile: ${student.mobile}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubmissionForm(
                                  isEditing: true,
                                  student: student,
                                  onSubmitSuccess:
                                      _handleSubmissionSuccess, // Pass callback function
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 8.0),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            // int selectedIndex =
                            //     index; // Store index in a variable

                            // print(
                            //     'Stored Index: $selectedIndex'); // Print stored index

                            // // Check if the stored index is within valid range
                            // if (selectedIndex >= 0 &&
                            //     selectedIndex < _students.length) {
                            //   Student student = _students[selectedIndex];
                            //   print(
                            //       'Selected Student: $student'); // Print selected student for debugging

                            //   // Show delete confirmation dialog if needed

                            // } else {
                            //   print(
                            //       'Invalid index or student data not available.');
                            // }
                            _showDeleteConfirmationDialog(student);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(getAllStudent));
      if (response.statusCode == 200) {
        setState(() {
          _students = (jsonDecode(response.body) as List)
              .map((data) => Student.fromJson(data))
              .toList();
          _errorMessage = ''; // Clear any previous error messages
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  void _showDeleteConfirmationDialog(Student student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content:
              Text("Are you sure you want to delete ${student.studentName}?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteStudent(student);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStudent(Student student) async {
    final studentId = student.id;
    final searchStudentUrl =
        '${Config.server}8081/api/v1/student/search/$studentId';

    print('Student ID: $studentId was deleted');

    try {
      final searchResponse = await http.get(Uri.parse(searchStudentUrl));

      if (searchResponse.statusCode == 200) {
        final studentData = jsonDecode(searchResponse.body);
        final studentToDelete = Student.fromJson(studentData);

        final deleteStudentUrl =
            '${Config.server}8081/api/v1/student/delete/$studentId';
        final deleteResponse = await http.delete(Uri.parse(deleteStudentUrl));

        if (deleteResponse.statusCode == 200) {
          setState(() {
            _students.removeWhere((s) => s.id == studentId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${studentToDelete.studentName} has been deleted successfully'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          throw Exception(
              'Failed to delete student: ${deleteResponse.statusCode}');
        }
      } else {
        throw Exception(
            'Failed to fetch student details: ${searchResponse.statusCode}');
      }
    } catch (e) {
      print('Error deleting student: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Failed to delete student'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> saveStudent(Student student) async {
    final url = Uri.parse('${Config.server}8081/api/v1/student/save');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(student.toJson()),
    );

    if (response.statusCode == 200) {
      String studentId = response.body;
      print('Student saved with ID: $studentId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student saved successfully'),
          duration: Duration(seconds: 3),
        ),
      );
      // Handle success, e.g., navigate to another page or show a success message
    } else {
      print(
          'Failed to save student. Error ${response.statusCode}: ${response.body}');
      // Handle error, e.g., show an error message
    }
  }

  void updateStudent(Student student) async {
    String apiUrl = '${Config.server}8081/api/v1/student/edit/${student.id}';
    Uri uri = Uri.parse(apiUrl);

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json', // Set content-type header
        },
        body: jsonEncode(student.toJson()), // Convert student object to JSON
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student updated successfully'),
            duration: Duration(seconds: 3),
          ),
        );

        // Check if it's safe to navigate before doing so
        if (!Navigator.of(context).canPop()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudentScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to update student. Status code: ${response.statusCode}'),
            duration: Duration(seconds: 3),
          ),
        );
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Failed to update student. Exception: $e');
    }
  }
}
