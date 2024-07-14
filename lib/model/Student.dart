class Student {
  String? id; // Optional if your server response has '_id'
  String studentName;
  String studentAddress;
  String mobile;

  // Constructor with named parameters
  Student({
    required this.studentName,
    required this.studentAddress,
    required this.mobile,
    this.id, // Optional ID parameter
  });

  // Regular constructor to create a Student object from JSON data
  Student.fromJson(Map<String, dynamic> json)
      : studentName = json['studentName'],
        studentAddress = json['studentAddress'],
        mobile = json['mobile'],
        id = json['_id'];

  // Method to convert Student object to JSON format
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['studentName'] = studentName;
    data['studentAddress'] = studentAddress;
    data['mobile'] = mobile;
    data['_id'] = id; 
    return data;
  }

  @override
  String toString() {
    return 'Student{id: $id, studentName: $studentName, studentAddress: $studentAddress, mobile: $mobile}';
  }
}
