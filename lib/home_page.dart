import 'dart:convert';
import 'dart:typed_data';

// import 'package:education_scout/utilities/showcase.dart';
import 'package:education_scout_/Classes/app_constant.dart';
import 'package:education_scout_/Routes/routes.dart';
import 'package:education_scout_/utilities/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'Classes/ColoRar.dart';
import 'Classes/snack_bar.dart';
import 'Routes/controller.dart';
import 'utilities/chatbox.dart';
import 'utilities/myaccount.dart';
import 'utilities/newfeeds.dart';
import 'utilities/restricted_page.dart';

class SchoolProfile {
  final String name;
  final String contact;
  final String address;
  final String headofinstitution;
  final String headqualification;
  final String teacher1;
  final String teacher1designation;
  final String teacher1qualification;
  final String teacher2;
  final String description;
  final String teacher2designation;
  final String teacher2qualification;
  final ProfileImage profileImage;
  final ProfileImage prospectus;
  final ProfileImage admission;

  SchoolProfile(
      {required this.name,
      required this.contact,
      required this.address,
      required this.headofinstitution,
      required this.headqualification,
      required this.teacher1,
      required this.description,
      required this.teacher1designation,
      required this.teacher1qualification,
      required this.teacher2,
      required this.teacher2designation,
      required this.teacher2qualification,
      required this.profileImage,
      required this.prospectus,
      required this.admission});

  factory SchoolProfile.fromJson(Map<String, dynamic> json) {
    return SchoolProfile(
        name: json['School_Name'] ?? '',
        contact: json['Contact'] ?? '',
        address: json['address'] ?? '',
        description: json['Description'] ?? '',
        headofinstitution: json['head'] ?? '',
        headqualification: json['head_qualification'] ?? '',
        teacher1: json['teacher1'] ?? '',
        teacher1designation: json['teacher1_designation'] ?? '',
        teacher1qualification: json['teacher1_qualification'] ?? '',
        teacher2: json['teacher2'] ?? '',
        teacher2designation: json['teacher2_designation'] ?? '',
        teacher2qualification: json['teacher2_qualification'] ?? '',
        profileImage: ProfileImage.fromJson(json['Profile_image']),
        prospectus: json['prospectus'] != null
            ? ProfileImage.fromJson(json['prospectus'])
            : ProfileImage(type: "", data: []),
        admission: json['admission'] != null
            ? ProfileImage.fromJson(json['admission'])
            : ProfileImage(type: "", data: []));
  }
}

class ProfileImage {
  final String type;
  final List<int> data;

  ProfileImage({
    required this.type,
    required this.data,
  });

  factory ProfileImage.fromJson(Map<String, dynamic> json) {
    return ProfileImage(
      type: json['type'],
      data: List<int>.from(json['data']),
    );
  }
}

class HomePage extends StatefulWidget {
  final String email;
  // final String schoolID; // Add the 'email' argument to the HomePage class

  const HomePage({
    Key? key,
    required this.email,
  }) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SchoolProfile> schoolProfiles = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
  List<SchoolProfile> filteredSchoolProfiles = [];

  @override
  void initState() {
    super.initState();
    fetchSchoolProfiles();
  }

  Widget getProfileImageWidget(profileImage) {
    Uint8List imageData = Uint8List.fromList(profileImage.data);
    return Image.memory(imageData);
  }

  void _filterSchools(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredSchoolProfiles = schoolProfiles.where((profile) {
        final nameMatches =
            searchByName && profile.name.toLowerCase().contains(searchQuery);
        final addressMatches = searchByAddress && // Use 'address' field here
            profile.address
                .toLowerCase()
                .contains(searchQuery); // Use 'address' field here
        return nameMatches || addressMatches;
      }).toList();
    });
  }

  Future<void> fetchSchoolProfiles() async {
    final response = await http.get(Uri.parse(AppConstant.homePage));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        schoolProfiles = data
            .map((profileData) => SchoolProfile.fromJson(profileData))
            .toList();
      });
      _filterSchools("");
    } else {
      throw Exception('Failed to fetch school profiles');
    }
  }

  int _currentIndex = 0;
  String searchQuery = '';
  bool searchByName = true;
  bool searchByAddress = true;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(
          context,
          MyRoutes.HomeRoute,
          arguments: {'email': widget.email},
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              final userController = Get.find<UserController>();
              final userRole = userController.userRole.value;

              if (userRole == 'school') {
                // Allow access to "Newfeeds" for schools
                return Newfeeds(email: widget.email);
              } else {
                // Handle restrictions for students or other roles
                return YourRestrictedPage(); // Create a restricted page for students
              }
            },
          ),
        );

        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              final userController = Get.find<UserController>();
              final userRole = userController.userRole.value;
              final loggedIn = userController.loggedIn.value;

              if (userRole == 'student' && loggedIn) {
                return Chatbox(email: widget.email);
              } else {
                // Handle restrictions for students or other roles
                return YourRestrictedPage(); // Create a restricted page for students
              }
            },
          ),
        );

        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              final userController = Get.find<UserController>();
              final userRole = userController.userRole.value;
              final loggedIn = userController.loggedIn.value;

              if ((userRole == 'student' || userRole == 'school') && loggedIn) {
                return Myaccount(email: widget.email);
              } else if ((userRole == 'student' || userRole == 'school') &&
                  !loggedIn) {
                // Handle restrictions for students or other roles
                return YourRestrictedPage(); // Create a restricted page for students
              }

              // You may want to return a default page or handle other cases here.
              return Login(
                  // email: widget.email,
                  );
            },
          ),
        );

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => Myaccount(email: widget.email)),
        // );
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.admin_panel_settings), // Your button icon
              onPressed: () {
                double sheetHeight = MediaQuery.of(context).size.height * 1.6;

                // Show the bottom sheet with a text field
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return Material(
                      // Wrap with Material
                      color: Colors
                          .transparent, // Set background color to transparent
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                              'Enter password:',
                              style: TextStyle(
                                  fontSize: 18, color: ColorRes.white),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Type your password',
                                hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight
                                        .normal // Set the hint text color to white
                                    ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors
                                        .white, // Set the border color to white
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors
                                        .white, // Set the border color to white
                                  ),
                                ),
                              ),
                              controller:
                                  _textEditingController, // Create a TextEditingController
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () {
                                  String enteredText =
                                      _textEditingController.text.trim();
                                  if (enteredText == 'ammar') {
                                    Navigator.pushNamed(
                                        context, MyRoutes.adminside);
                                  }
                                },
                                child: const Text('Submit'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(
            //   'images/logo.png', // Replace with your image path
            //   fit: BoxFit.contain,
            //   height: 32,
            //   width: 60, // Adjust the height as needed
            // ),
            SizedBox(width: 2),
            Text('Education Scout'),
          ],
        ),
        centerTitle: true,
        // leading: Tooltip(
        //   message: 'Login',
        //   child: IconButton(
        //     icon: const Icon(Icons.person_2),
        //     onPressed: () {
        //       Navigator.pushNamed(context, MyRoutes.login_page);
        //     },
        //   ),
        // ),
      ),
      drawer: Drawer(
          backgroundColor: const Color(0xFF667EE2).withOpacity(0.4),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 30),
            children: [
              ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title: Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Icon(Icons.person, color: Colors.white),
                onTap: () {
                  Navigator.pushNamed(context, MyRoutes.login_page);
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_page, color: Colors.white),
                title: Text(
                  'Contact Us',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pushNamed(context, MyRoutes.contact);
                },
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip_outlined, color: Colors.white),
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pushNamed(context, MyRoutes.privacy);
                },
              ),
            ],
          )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(35.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Search by:'),
                      const SizedBox(width: 10),
                      ToggleButtons(
                        isSelected: [searchByName, searchByAddress],
                        onPressed: (index) {
                          setState(() {
                            if (index == 0) {
                              searchByName = true;
                              searchByAddress = false;
                            } else {
                              searchByName = false;
                              searchByAddress = true;
                            }
                            _filterSchools(_searchController.text);
                          });
                        },
                        children: const [
                          Icon(Icons.school),
                          Icon(Icons.location_on),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  onChanged: _filterSchools,
                  decoration: InputDecoration(
                    hintText: searchByName ? 'School Name' : 'Location',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ), // Change border color here
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Color(0xFF667EE2)),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: filteredSchoolProfiles.isEmpty
                ? Center(
                    child: searchQuery.isNotEmpty
                        ? Text(
                            'No schools found with the  "$searchQuery"',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        : const CircularProgressIndicator(
                            color: ColorRes.app,
                          ),
                  )
                : GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                    children: filteredSchoolProfiles.map((profile) {
                      final profileName = profile.name.toLowerCase();
                      final profileAddress = profile.address.toLowerCase();

                      if (searchQuery.isNotEmpty &&
                          !(profileName.contains(searchQuery) ||
                              profileAddress.contains(searchQuery))) {
                        return Container();
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SchoolDetailsPage(
                                  email: widget.email, profile: profile),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            children: [
                              Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13.0),
                                ),
                                color: Colors.white,
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: getProfileImageWidget(
                                          profile.profileImage),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Flexible(
                                child: Text(
                                  profile.name,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.clip,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF667EE2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: GNav(
              gap: 8,
              backgroundColor: const MaterialColor(
                0xFF667EE2, // Replace with your desired color value
                <int, Color>{
                  50: Color(0xFF667EE2),
                  100: Color(0xFF667EE2),
                  200: Color(0xFF667EE2),
                  300: Color(0xFF667EE2),
                  400: Color(0xFF667EE2),
                  500: Color(0xFF667EE2),
                  600: Color(0xFF667EE2),
                  700: Color(0xFF667EE2),
                  800: Color(0xFF667EE2),
                  900: Color(0xFF667EE2),
                },
              ),
              // tabActiveBorder: Border.all(color: Colors.white, width: 1),
              selectedIndex: _currentIndex,
              activeColor: Colors.white,
              onTabChange: _onTabTapped,
              // onTabChange: (index) => setState(() => this.index = index),
              color: Colors.white,
              tabBackgroundColor: Colors.transparent,
              padding: const EdgeInsets.all(16),
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                  textStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                GButton(
                  icon: Icons.upload_file,
                  text: 'New Feeds',
                  textStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                GButton(
                  icon: Icons.chat_bubble,
                  text: 'Chat Box',
                  textStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                GButton(
                  icon: Icons.account_circle,
                  text: 'My Account',
                  textStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

class SchoolDetailsPage extends StatefulWidget {
  final SchoolProfile profile;
  final String email;

  const SchoolDetailsPage(
      {Key? key, required this.email, required this.profile})
      : super(key: key);

  @override
  State<SchoolDetailsPage> createState() => _SchoolDetailsPageState();
}

class _SchoolDetailsPageState extends State<SchoolDetailsPage> {
  Widget getProfileImageWidget(profileImage) {
    Uint8List imageData = Uint8List.fromList(profileImage.data);
    return Image.memory(imageData);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.profile.name),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                  icon: Icon(
                    Icons.account_circle,
                    size: 20,
                  ),
                  text: 'Profile'),
              Tab(
                  icon: Icon(
                    Icons.people,
                    size: 20,
                  ),
                  text: 'Teachers'),
              Tab(
                  icon: Icon(
                    Icons.description,
                    size: 20,
                  ),
                  text: 'Documents'),
              Tab(
                  icon: Icon(
                    Icons.feedback,
                    size: 20,
                  ),
                  text: 'Feedback'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ProfileSection(widget.profile),
            _TeachersSection(widget.profile),
            _DocumentsSection(widget.profile),
            _FeedbackSection(
              email: widget.email,
              profile: widget.profile,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatefulWidget {
  final SchoolProfile profile;

  const _ProfileSection(this.profile);

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<_ProfileSection> {
  Widget getProfileImageWidget(profileImage) {
    Uint8List imageData = Uint8List.fromList(profileImage.data);
    return Image.memory(imageData);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          SizedBox(
              width: 160,
              height: 160,
              child: getProfileImageWidget(widget.profile.profileImage)),
          const SizedBox(
            height: 15,
          ),
          Text(
            "ABOUT ME",
            style: GoogleFonts.roboto(color: Colors.black87),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: 450,
              height: 200,
              margin: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  border: Border.all(color: Colors.black54)),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.profile.description,
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.black,
              ),
              const SizedBox(width: 5),
              Text(
                'Location: ${widget.profile.address}',
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.phone_android,
                color: Colors.black,
              ),
              const SizedBox(width: 5),
              Text(
                'Contact: ${widget.profile.contact}',
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TeachersSection extends StatelessWidget {
  final SchoolProfile profile;

  const _TeachersSection(this.profile);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Center(child: _SectionHeader(text: 'Institution Leadership')),
          const SizedBox(height: 20),
          _TeacherInfo(
            name: profile.headofinstitution,
            qualification: profile.headqualification,
            designation: 'Head of Institution',
          ),
          Divider(height: 40, color: Colors.grey[400]),
          const Center(child: _SectionHeader(text: 'Teaching Staff')),
          const SizedBox(height: 20),
          _TeacherInfo(
            name: profile.teacher1,
            qualification: profile.teacher1qualification,
            designation: profile.teacher1designation,
          ),
          Divider(height: 20, color: Colors.grey[400]),
          const SizedBox(height: 25),
          _TeacherInfo(
            name: profile.teacher2,
            qualification: profile.teacher2qualification,
            designation: profile.teacher2designation,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;

  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.indigo,
      ),
    );
  }
}

class _TeacherInfo extends StatelessWidget {
  final String name;
  final String qualification;
  final String designation;

  const _TeacherInfo({
    required this.name,
    required this.qualification,
    required this.designation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.black),
            const SizedBox(width: 5),
            Text(
              "Name: $name",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.work, size: 20, color: Colors.black),
            const SizedBox(width: 5),
            Text(
              " Designation:      $designation",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.school, size: 20, color: Colors.black),
            const SizedBox(width: 5),
            Text(
              " Qualification:  $qualification",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PdfViewerPage extends StatefulWidget {
  final Uint8List pdfBytes;
  final String pdfName;

  const PdfViewerPage(
      {super.key, required this.pdfBytes, required this.pdfName});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? _pdfFilePath;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.pdfName),
        ),
        body: SfPdfViewer.memory(widget.pdfBytes));
  }
}

class _DocumentsSection extends StatelessWidget {
  final SchoolProfile profile;

  const _DocumentsSection(this.profile);

  Future<void> _generateAndDownloadPdf(
      Uint8List pdfByteData, String pdfName, BuildContext mContext) async {
    Navigator.push(
      mContext,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(
            pdfBytes: pdfByteData,
            pdfName: pdfName // Replace with your PDF bytes
            ),
      ),
    );

    // final pdfBytes = pdfByteData;
    // final blob = html.Blob([pdfBytes]);
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor = html.AnchorElement(href: url)
    //   ..setAttribute("download", pdfName)
    //   ..click();
    // html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "If you're interested in exploring more about our school and what it has to offer, we invite you to take a closer look at our prospectus. The prospectus provides a comprehensive overview of our institution, including our mission, values, academic programs, extracurricular activities, faculty, facilities, and much more.",
              style: GoogleFonts.roboto(fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 35,
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () {
                if (profile.prospectus.data.isNotEmpty) {
                  _generateAndDownloadPdf(
                      Uint8List.fromList(profile.prospectus.data),
                      "${profile.name} Prospectus.pdf",
                      context);
                }
              },
              icon: const Icon(Icons.file_open),
              label: const Text('Prospectus'),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "If you want to further look on our admission criteria and requirments you can check our admission form to further relate with our services",
              style: GoogleFonts.roboto(fontSize: 20),
            ),
          ),
          const SizedBox(height: 15),

          SizedBox(
            height: 35,
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement logic for opening the admission form document
                if (profile.admission.data.isNotEmpty) {
                  _generateAndDownloadPdf(
                      Uint8List.fromList(profile.admission.data),
                      "${profile.name} Admission Form.pdf",
                      context);
                }
              },
              icon: const Icon(Icons.file_open),
              label: const Text('Admission Form'),
            ),
          ),
          //           Text(
          //             'Head of Institution: ${widget.profile.headofinstitution}',
          //             style: TextStyle(color: Colors.blue),
          //           ),
          //           Text(
          //             'Qualification: ${widget.profile.headqualification}',
          //           ),
          // ... Documents content ...
        ],
      ),
    );
  }
}

class _FeedbackSection extends StatefulWidget {
  final String email;
  final profile;

  const _FeedbackSection({Key? key, required this.email, required this.profile})
      : super(key: key);
  @override
  _FeedbackSectionState createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<_FeedbackSection> {
  final TextEditingController feedbackController = TextEditingController();
  List<String> submittedFeedback = [];
  bool loggedIn = false; // Track whether the user is logged in

  Future<void> submitFeedback(String feedbackText) async {
    if (!loggedIn) {
      // Check if the user is logged in (student)
      Get.snackbar(
          "Feedback", "You must be logged in as a student to submit feedback");
      return;
    }

    Get.snackbar("Feedback", "Your Feedback is submitted");
    // You can use the http package or any other package to make the API request
    final response = await http.post(
      Uri.parse(
          'http://192.168.100.66:1000/Feedback'), // Replace with your API endpoint
      body: jsonEncode({
        'Feedback_text': feedbackController.text,
        'Student_Email':
            widget.email, // Use 'Student_Email' instead of 'Student_ID'
        'School_Name': widget.profile.name, // Replace with the school ID
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Feedback submitted successfully');
      setState(() {
        submittedFeedback.add(feedbackController.text);
        feedbackController.clear();
      });
    } else {
      print('Error submitting feedback: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final CustomSnackBarController customSnackBarController =
        CustomSnackBarController();

    final UserController userController = Get.find<UserController>();
    final userRole = userController.userRole.value;

    // Check if the user is a student and logged in
    if (userRole == 'student') {
      loggedIn = true;
    } else {
      loggedIn = false;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  'Provide Feedback',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Icon(
                  Icons.feedback,
                  size: 60,
                  color: Color(0xFF667EE2),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your feedback',
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                if (loggedIn) // Show the button only for logged-in students
                  ElevatedButton(
                    onPressed: () {
                      // Call the showSnackBar method with the feedback text
                      customSnackBarController.showSnackBar(
                          'Feedback submitted: ${feedbackController.text}');
                      submitFeedback(feedbackController.text);
                    },
                    child: const Text('Submit Feedback'),
                  ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Submitted Feedback:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (var feedback in submittedFeedback)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(feedback),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
