import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:typed_data';

// import 'package:education_scout/utilities/showcase.dart';
import 'package:education_scout_/Classes/app_constant.dart';
import 'package:http/http.dart' as http;

class SchoolProfile {
  final String name;
  final ProfileImage profileImage;
  final ProfileImage license;

  SchoolProfile(
      {required this.name,
      required this.profileImage,
      required this.license});

  factory SchoolProfile.fromJson(
      Map<String, dynamic> json) {
    return SchoolProfile(
        name: json['School_Name'] ?? '',
        profileImage: ProfileImage.fromJson(
            json['Profile_image']),
        license: json['License'] != null
            ? ProfileImage.fromJson(
                json['License'])
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

  factory ProfileImage.fromJson(
      Map<String, dynamic> json) {
    return ProfileImage(
      type: json['type'],
      data: List<int>.from(json['data']),
    );
  }
}

class PendingSchoolsDetails
    extends StatefulWidget {
  // final String email;
  //  final SchoolProfile profile;
  // final String schoolID; // Add the 'email' argument to the HomePage class

  const PendingSchoolsDetails({
    Key? key,
    // required this.email, required this.profile,
  }) : super(key: key);
  @override
  State<PendingSchoolsDetails> createState() =>
      _PendingSchoolsDetailsState();
}

class _PendingSchoolsDetailsState
    extends State<PendingSchoolsDetails> {
  List<SchoolProfile> schoolProfiles = [];

  List<SchoolProfile> filteredSchoolProfiles = [];

  @override
  void initState() {
    super.initState();
    fetchSchoolProfiles();
  }

  Widget getProfileImageWidget(profileImage) {
    Uint8List imageData =
        Uint8List.fromList(profileImage.data);
    return Image.memory(imageData);
  }

  void _filterSchools(String query) {
    List<SchoolProfile> tempList = [];
    if (query.isNotEmpty) {
      for (var profile in schoolProfiles) {
        if (profile.name
            .toLowerCase()
            .contains(query.toLowerCase())) {
          tempList.add(profile);
        }
      }
    } else {
      tempList = schoolProfiles;
    }
    setState(() {
      filteredSchoolProfiles = tempList;
    });
  }

  Future<void> fetchSchoolProfiles() async {
    final response = await http
        .get(Uri.parse(AppConstant.getPending));

    if (response.statusCode == 200) {
      final List<dynamic> data =
          json.decode(response.body);
      setState(() {
        schoolProfiles = data
            .map((profileData) =>
                SchoolProfile.fromJson(
                    profileData))
            .toList();
      });
      _filterSchools("");
    } else {
      throw Exception(
          'Failed to fetch school profiles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Pending SCHOOLS details")),
      body: Container(
        child: Column(children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
              children: filteredSchoolProfiles
                  .map((profile) {
                return GestureDetector(
                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) =>
                  //           PendingSchoolsDetails(
                  //               email: widget.email,
                  //               profile: profile),
                  //     ),
                  //   );
                  // },
                  child: Container(
                    padding:
                        const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 8,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        13.0),
                          ),
                          color: Colors.white,
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          40.0),
                              child: Padding(
                                padding:
                                    const EdgeInsets
                                        .all(8.0),
                                child: getProfileImageWidget(
                                    profile
                                        .profileImage),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Flexible(
                          child: Text(
                            profile.name,
                            textAlign:
                                TextAlign.start,
                            overflow:
                                TextOverflow.clip,
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
        ]),
      ),
    );
  }
}
