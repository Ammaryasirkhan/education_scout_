// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:education_scout_/Classes/app_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io' if (dart.library.html) 'dart:html'; //

class Teacher {
  final String name;
  final String designation;
  final String qualification;

  Teacher({
    required this.name,
    required this.designation,
    required this.qualification,
  });
}

class Newfeeds extends StatefulWidget {
  final String email;

  const Newfeeds({Key? key, required this.email}) : super(key: key);

  @override
  _NewfeedsState createState() => _NewfeedsState();
}

class _NewfeedsState extends State<Newfeeds> {
  String updatedDescription = '';
  String updatedProspectusData = '';
  String updatehod = '';
  String updateteacher1 = '';
  String updateteacher2 = '';
  String updateimage = '';
  final descriptionController = TextEditingController();
  final hodController = TextEditingController();
  final teacherController = TextEditingController();
  final teacher1Controller = TextEditingController();
  final teacherDesignationController = TextEditingController();
  final teacherDesignation1Controller = TextEditingController();
  final teacherQualificationController = TextEditingController();
  final teacherQualification1Controller = TextEditingController();
  final hodqualificationController = TextEditingController();
  String schoolName = '';

  String schoolAddress = '';
  String contactNumber = '';
  File? prospectusDocument;
  File? admissionForm;
  List<File> buildingPhotos = [];
  String teacherName = '';
  String teacherDesignation = '';
  String teacherQualification = '';
  String Description = '';
  List<Teacher> teachers = [];
  int teacherCounter = 0;
  bool showTeacherForm = false;
  bool showphotos = false;

  Future<void> chooseFile(String fileType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [fileType],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        for (var file in result.files) {
          File selectedFile =
              File(file.path!); // Use file.path as the first argument
          if (fileType == 'pdf' && file.name == 'prospectus.pdf') {
            prospectusDocument = selectedFile;
          } else if (fileType == 'pdf' && file.name == 'admission_form.pdf') {
            admissionForm = selectedFile;
          } else if (fileType == 'png' && file.name == 'building_photo.png') {
            buildingPhotos.add(selectedFile);
          }
        }
      });
    } else {
      // Handle file selection cancellation or error
    }
  }

  void addTeacher() {
    setState(() {
      showTeacherForm = true;
    });
  }

  void addPhotos() {
    setState(() {
      showphotos = true;
    });
  }

  void submitTeacher() {
    if (teacherName.isNotEmpty &&
        teacherDesignation.isNotEmpty &&
        teacherQualification.isNotEmpty) {
      if (teacherCounter < 3) {
        setState(() {
          teachers.add(Teacher(
            name: teacherName,
            designation: teacherDesignation,
            qualification: teacherQualification,
          ));

          // Clear the input fields after adding the teacher
          teacherName = '';
          teacherDesignation = '';
          teacherQualification = '';
          teacherCounter++;
          showTeacherForm = false;
        });
      }
    }
  }

  void cancelTeacher() {
    setState(() {
      // Clear the input fields and hide the teacher form
      teacherName = '';
      teacherDesignation = '';
      teacherQualification = '';
      showTeacherForm = false;
    });
  }

  File? _document;
  File? _image1;
  File? admissionDocument;
  Uint8List? _imageUnintList;
  Uint8List? _documentUnintList;
  String? imagename;
  String? documentName; // Variable to hold the document name
  String? admissionDocumentName; // Variable to hold the admission document

  Future<void> _openAdmissionDocumentPicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          if (result.files.single.bytes != null) {
            _documentUnintList = Uint8List.fromList(result.files.single.bytes!);
          }
        } else {
          admissionDocument = File(result.files.single.path!);
          admissionDocumentName =
              result.files.single.name; // Store the admission document name
        }
      });
    }
  }

  Future<void> _openDocumentPicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          if (result.files.single.bytes != null) {
            // Handle file bytes for web
            _documentUnintList = Uint8List.fromList(result.files.single.bytes!);
          }
        } else {
          // Handle file for non-web (mobile) platforms
          _document = File(result.files.single.path!);
          documentName = result.files.single.name; // Store the document name
        }
      });
    }
  }

  Future<void> _openImagePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      if (result.count == 1) {
        setState(() {
          if (kIsWeb) {
            if (result.files.single.bytes != null) {
              // Handle image bytes for web
              _imageUnintList = Uint8List.fromList(result.files.single.bytes!);
            }
          } else {
            // Handle image for non-web (mobile) platforms
            if (result.files.single.path != null) {
              _image1 = File(result.files.single.path!);
            }
          }

          // Get the selected image name
          String imageName = result.files.single.name;

          imagename = imageName;
        });
      } else {
        // Multiple files were picked
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select a single image file.'),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } else {
      // File picking was canceled
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Canceled'),
          content: const Text('File picking was canceled.'),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  //Api connection

  Future<void> submitDataToBackend() async {
    var prospectusDocumentinfo = {
      'prospectus': prospectusDocument != null
          ? base64Encode(await prospectusDocument!.readAsBytes())
          : null,
    };
    var addmissionDocumentinfo = {
      'admission': admissionForm != null
          ? base64Encode(await admissionForm!.readAsBytes())
          : null,
    };

    var updatedFields = {
      'Description': descriptionController.text,
      'head': hodController.text,
      'head_qualification': hodqualificationController.text,
      'teacher1': teacherController.text,
      'teacher1_qualification': teacherQualificationController.text,
      'teacher1_designation': teacherDesignationController.text,
      'teacher2': teacher1Controller.text,
      'teacher2_qualification': teacherQualification1Controller.text,
      'teacher2_designation': teacherDesignation1Controller.text,
      'prospectus': prospectusDocumentinfo,
      'admission': addmissionDocumentinfo,
    };

    var requestPayload = {
      'email': widget.email, // Provide the user's email
      'updatedFields': updatedFields,
    };

    try {
      final response = await http.put(
        Uri.parse(AppConstant.newFeeds),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Successful Updated Profile',
            ),
          ),
        );

        // Fields updated successfully
        print('Fields updated successfully');
      } else {
        print('Error updating fields: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception updating fields: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Detailed INFORMATION'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 15.0),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Description (make a bio)",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLength: 300,
                maxLines: 8,
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          const Text(
                            "Add more details in the form of  Prospects ",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          SizedBox(
                            width: 220,
                            child: ElevatedButton(
                              onPressed: () {
                                _openDocumentPicker();
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(5)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Prospectus Document",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (documentName != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                const Text(
                                  "Selected Document:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight
                                        .bold, // Add bold weight for emphasis
                                    color: Colors.blue, // Use a distinct color
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  documentName!,
                                  style: const TextStyle(
                                    fontSize:
                                        14, // Increase font size for the document name
                                    color: Colors
                                        .black, // Use a professional color
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          const Text(
                            "Add Admission form to catch the students ",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          // ),
                          SizedBox(height: 8.0),
                          SizedBox(
                            width: 220,
                            child: ElevatedButton(
                              onPressed: () {
                                _openAdmissionDocumentPicker();
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(5)),
                                // backgroundColor: MaterialStateProperty.all(
                                //   Colors.blue,
                                // ),
                                // side: MaterialStateProperty.all(
                                //   BorderSide(
                                //     width: 1.0,
                                //     color: Colors.black.withOpacity(0.1),
                                //   ),
                                // ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Admission Form",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // if (admissionDocumentName != null)
                          //   Text(
                          //     "Selected Admission Document: $admissionDocumentName",
                          //     style: TextStyle(fontSize: 12),
                          //   ),
                          if (admissionDocumentName != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                const Text(
                                  "Selected Document:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight
                                        .bold, // Add bold weight for emphasis
                                    color: Colors.blue, // Use a distinct color
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  admissionDocumentName!,
                                  style: const TextStyle(
                                    fontSize:
                                        14, // Increase font size for the document name
                                    color: Colors
                                        .black, // Use a professional color
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              // Row(
              //   children: [
              //     Expanded(
              //       child: Center(
              //         child: Column(
              //           children: [
              //             // Text(
              //             //   "Upload Addmission Document",
              //             //   style: TextStyle(fontSize: 15),
              //             // ),
              //             Container(
              //               width: 220,
              //               child: ElevatedButton(
              //                 onPressed: () {
              //                   _openImagePicker();
              //                 },
              //                 style: ButtonStyle(
              //                   padding: MaterialStateProperty.all(
              //                       EdgeInsets.all(5)),
              //                   backgroundColor: MaterialStateProperty.all(
              //                     Colors.blue,
              //                   ),
              //                   // side: MaterialStateProperty.all(
              //                   //   BorderSide(
              //                   //     width: 1.0,
              //                   //     color: Colors.black.withOpacity(0.1),
              //                   //   ),
              //                   // ),
              //                 ),
              //                 child: Row(
              //                   mainAxisAlignment: MainAxisAlignment.center,
              //                   children: [
              //                     Icon(Icons.description),
              //                     SizedBox(
              //                       width: 8,
              //                     ),
              //                     Text(
              //                       "Building Photos",
              //                       style: TextStyle(fontSize: 14),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             ),
              //             // if (admissionDocumentName != null)
              //             //   Text(
              //             //     "Selected Admission Document: $admissionDocumentName",
              //             //     style: TextStyle(fontSize: 12),
              //             //   ),
              //             if (imagename != null)
              //               Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   SizedBox(height: 8),
              //                   Text(
              //                     "Selected Document:",
              //                     style: TextStyle(
              //                       fontSize: 12,
              //                       fontWeight: FontWeight
              //                           .bold, // Add bold weight for emphasis
              //                       color:
              //                           Colors.blue, // Use a distinct color
              //                     ),
              //                   ),
              //                   SizedBox(height: 4),
              //                   Text(
              //                     imagename!,
              //                     style: TextStyle(
              //                       fontSize:
              //                           14, // Increase font size for the document name
              //                       color: Colors
              //                           .black, // Use a professional color
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(
                height: 20.0,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Head Of Institution",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  // Other form fields...

                  const SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    controller: hodController,
                    decoration: const InputDecoration(
                      labelText: 'Head of Institution',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    controller: hodqualificationController,
                    decoration: const InputDecoration(
                      labelText: 'Qualification ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  // Other form fields...
                  const SizedBox(height: 20),
                  // ElevatedButton...
                  const SizedBox(height: 20),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Teacher ",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: teacherController,
                decoration: const InputDecoration(
                  labelText: 'Teacher Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextFormField(
                controller: teacherDesignationController,
                decoration: const InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextFormField(
                controller: teacherQualificationController,
                decoration: const InputDecoration(
                  labelText: 'qualification',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Teacher ",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: teacher1Controller,
                decoration: const InputDecoration(
                  labelText: 'Teacher Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextFormField(
                controller: teacherDesignation1Controller,
                decoration: const InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextFormField(
                controller: teacherQualification1Controller,
                decoration: const InputDecoration(
                  labelText: 'qualification',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                style: TextButton.styleFrom(fixedSize: const Size(150, 35)),
                onPressed: () {
                  submitDataToBackend();
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
