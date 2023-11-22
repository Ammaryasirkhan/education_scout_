import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Classes/app_constant.dart';

class Chatbox extends StatefulWidget {
  // const Chatbox({super.key});
  final String email;

  const Chatbox({super.key, required this.email});

  @override
  State<Chatbox> createState() => _ChatboxState();
}

class _ChatboxState extends State<Chatbox> {
  final List<Map<String, dynamic>> _messages = [];
  late TextEditingController
      _textEditingController;
  String _username = ''; // Holds the Student_Name

  @override
  void initState() {
    super.initState();
    fetchUsername(widget.email).then((username) {
      setState(() {
        _username = username;
      });
    });

    _textEditingController =
        TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _sendMessage(String message) async {
    // Fetch the Student_Name using the user's email
    final username =
        await fetchUsername(widget.email);

    setState(() {
      _messages.add({
        'sender': username,
        'message': message,
        'timestamp': DateTime.now(),
      });
    });
    _textEditingController.clear();
  }

  Future<String> fetchUsername(
      String email) async {
    final response = await http.get(
      Uri.parse(
          '${AppConstant.chatBox}${widget.email}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body);
      return data['username'];
    } else {
      throw Exception('Failed to fetch username');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat Box",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Colors.deepPurple,
                  ),
                ),
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        _messages[index];
                    return ListTile(
                      title: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Text(
                                message['timestamp']
                                    .toString(),
                                style:
                                    const TextStyle(
                                  fontSize: 10,
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons
                                  .person_2_rounded),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                child: Text(
                                  message[
                                      'sender'],
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height: 4),
                          Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                                    left: 25.0),
                            child: Container(
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.blue,
                                // border: Border.all(color: Colors.grey),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            30.0), // Adjust the radius as needed
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets
                                        .all(
                                        8.0), // Add padding to give space between text and border
                                child: Text(
                                  message[
                                      'message'],
                                  style: const TextStyle(
                                      color: Colors
                                          .white),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                              height: 2),
                          // Text(
                          //   message['timestamp'].toString(),
                          //   style: TextStyle(
                          //     fontSize: 10,
                          //     color: Colors.grey,
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        _textEditingController,
                    decoration:
                        const InputDecoration(
                      hintText:
                          'type your message.....',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(
                                Radius.circular(
                                    15.0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty
                        .all<OutlinedBorder>(
                      const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.only(
                          topLeft:
                              Radius.circular(
                                  8.0),
                          bottomLeft:
                              Radius.circular(
                                  8.0),
                          topRight:
                              Radius.circular(
                                  20.0),
                          bottomRight:
                              Radius.circular(
                                  20.0),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    _sendMessage(
                        _textEditingController
                            .text);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0),
                    child: Text(
                      'Send',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
