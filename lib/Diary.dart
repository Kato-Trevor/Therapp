import 'dart:async';
import 'package:flutter/material.dart';
import 'package:therapp/Pallete.dart';
import 'Message.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:bubble/bubble.dart';
import 'DiaryPage.dart';
import 'package:openai_client/openai_client.dart';
import 'package:openai_client/src/model/openai_chat/chat_message.dart';
import 'Languages.dart';
import 'package:xen_popup_card/xen_card.dart';
import 'translate_text.dart';
import 'package:google_fonts/google_fonts.dart';

class Diary extends StatefulWidget {
  Diary({Key? key}) : super(key: key);
  _WidgetState createState() => _WidgetState();
}

class _WidgetState extends State<Diary> {
  bool _Diary = true;
  bool _isloading = false;
  String bot_target = "English";
  String bot_source = "English";
  String user_target = "English";
  String user_source = "English";
  String token = "";
  String input = "";
  String response = "";

  var inputController = TextEditingController();

  int Limit = 7;

  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text(
              'Changing language...',
              style: TextStyle(color: Pallete.dark_purple),
            ),
            content: const LinearProgressIndicator(
              backgroundColor: Pallete.light_purple,
              valueColor: AlwaysStoppedAnimation(Pallete.dark_purple),
            ));
      },
    );
  }

  List<ChatMessage> SharedMessages = [
    ChatMessage(
        role: "system",
        content:
            "You are called \'Therapp Bot\' you're a virtual therapist with the aim of making the user feel better")
  ];

  List<Message> messages = [
    const Message(
        text: "Hello, Welcome to Lets Chat by TherApp. ", isFromMe: false),
    const Message(
        text:
            "Here you will be able to interact with our virtual Therapist built with AI. ",
        isFromMe: false),
    const Message(
        text:
            "Non of the information you share here will be recorded. please note that the model is still in development and some output might not be accurate.",
        isFromMe: false)
  ];

  void AddMessage(String message, String role) {
    if (SharedMessages.length > Limit) {
      SharedMessages.removeAt(1);
    }
    SharedMessages.add(ChatMessage(role: role, content: message));
  }

  @override
  void initState() async {
    super.initState();

    await getAuthenticationKey().then((value) => {token = value});
  }

  final conf = OpenAIConfiguration(
      apiKey: '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');

  Future<void> generate(String message) async {
    String response = "";
    final client = OpenAIClient(
      configuration: conf,
      enableLogging: true,
    );
    if (user_source != "English") {
      String conte = "";
      await generate_translation(message, user_target, user_source, token)
          .then((value) => {conte = value});

      message = conte;
    }

    AddMessage(message, "user");

    final chat = await client.chat
        .create(
          model: 'gpt-3.5-turbo',
          messages: SharedMessages,
        )
        .data;

    response = chat.choices[0].message.content;

    if (bot_target != "English") {
      String conte = "";
      await generate_translation(response, bot_target, bot_source, token)
          .then((value) => {conte = value});

      response = conte;
    }

    AddMessage(response, "assistant");

    Message ms = Message(text: response, isFromMe: false);

    setState(() {
      messages.add(ms);
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //This gives us the bar at the top of the layout
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
                child: GestureDetector(
              onTap: (() {
                setState(
                  () {
                    _Diary = true;
                  },
                );
              }),
              child: Text(
                'Your Diary',
                style: TextStyle(
                  color: _Diary ? Pallete.dark_purple : Pallete.text_color1,
                ),
              ),
            )),
            Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  _Diary = false;
                });
              },
              child: Text(
                "Let's talk",
                style: TextStyle(
                  color: !_Diary ? Pallete.dark_purple : Pallete.text_color1,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _Diary ? DiaryPage() : buildChat(),
    );
  }

  Column buildChat() {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.topRight,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.translate_rounded,
                  color: Colors.grey,
                  size: 30.0,
                ),
                label: Text(
                  'Response : ' + bot_target + ", Input : " + user_source,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                onPressed: () {
                  buildTranslateDialog(context, true);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
            ),
          ),
        ),
        Expanded(
          child: GroupedListView<Message, DateTime>(
            padding: const EdgeInsets.all(10),
            useStickyGroupSeparators: true,
            elements: messages,
            groupBy: (message) => DateTime(2022),
            groupHeaderBuilder: (Message message) => SizedBox(),
            itemBuilder: (context, Message message) => Bubble(
              color: message.isFromMe ? Pallete.dark_purple : Colors.white,
              margin: const BubbleEdges.only(top: 10),
              alignment:
                  message.isFromMe ? Alignment.topRight : Alignment.topLeft,
              child: Text(
                message.text,
                style: TextStyle(
                    color:
                        message.isFromMe ? Colors.white : Pallete.dark_purple),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Pallete.dark_purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: GestureDetector(
                onTap: (() {
                  buildTranslateDialog(context, true);
                }),
                child: const Icon(
                  Icons.translate_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 100,
              child: TextField(
                cursorColor: Pallete.dark_purple,
                controller: inputController,
                decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Pallete.light_purple),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Pallete.light_purple),
                    ),
                    contentPadding: EdgeInsets.all(12),
                    hintText: "Express your feelings here"),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 1,
                onSubmitted: (value) {
                  if (!_isloading) {
                    final mess = Message(text: value, isFromMe: true);
                    print("subm");
                    setState(() {
                      inputController.text = "";
                      messages.add(mess);
                      _isloading = true;
                      generate(mess.text);
                    });
                  }
                },
              ),
            ),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: Pallete.dark_purple,
                  borderRadius: BorderRadius.circular(20)),
              child: GestureDetector(
                onTap: (() {
                  if (!_isloading) {
                    final mess = Message(
                        text: inputController.text.trim(), isFromMe: true);
                    setState(() {
                      inputController.text = "";
                      messages.add(mess);
                      _isloading = true;
                      generate(mess.text);
                    });
                  }
                }),
                child: (!_isloading)
                    ? const Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: Colors.white,
                      )
                    : const CircularProgressIndicator(color: Colors.white),
              ),
            )
          ],
        ),
      ],
    );
  }

  // void getMessage(String text) async {
  //   var response = await getResponse(text);
  //   if (response != null) {
  //     Map<String, dynamic> output = json.decode(response.body);
  //     String message = output["output"];
  //     int lindex = message.lastIndexOf("-->");
  //     message = message.substring(lindex);
  //     message = message.replaceAll("<|endoftext|>", "");
  //     message = message.replaceAll("&nbsp;", ".");
  //     message = message.replaceAll("\n", " ");
  //     Message ms = Message(text: message, isFromMe: false);
  //     setState(() {
  //       messages.add(ms);
  //       _isloading = false;
  //     });
  //   } else {
  //     setState(() {
  //       messages.add(Message(
  //           text: "Failed to get response. check your internet connection",
  //           isFromMe: false));
  //       _isloading = false;
  //     });
  //   }
  //   print("done");
  // }

  // Future<http.Response?> getResponse(String text) async {
  //   var url = 'https://therapp-prediction-n5yjitcc5q-lm.a.run.app/predict';
  //   text = text + " -->";

  //   Map data = {'text': text};
  //   //encode Map to JSON
  //   var body = json.encode(data);
  //   print("here");
  //   var response = await http.post(Uri.parse(url),
  //       headers: {"Content-Type": "application/json"}, body: body);

  //   return response;
  // }
  Future<dynamic> buildTranslateDialog(BuildContext context, bool isChat) {
    return showDialog(
      context: context,
      builder: (builder) => XenPopupCard(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                color: Pallete.dark_purple,
                child: const Icon(Icons.translate_rounded, color: Colors.white),
              ),
            ),
            const Text(
              "Language Preference",
              style: TextStyle(
                fontSize: 25,
                color: Pallete.dark_purple,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Response language",
              style: TextStyle(
                fontSize: 20,
                color: Pallete.dark_purple,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.all(8),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: Languages.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    response = value!;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            if (isChat) ...[
              // ignore: prefer_const_constructors
              const Text(
                "Input Language",
                style: TextStyle(fontSize: 20, color: Pallete.dark_purple),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                margin: const EdgeInsets.all(8),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: Languages.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    input = value!;
                  },
                ),
              ),
            ],
          ],
        ),
        gutter: XenCardGutter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: Text(
                "Change language",
                style: GoogleFonts.montserrat(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.dark_purple,
                textStyle: const TextStyle(
                  color: Pallete.dark_purple,
                  fontSize: 15,
                  fontStyle: FontStyle.normal,
                ),
                padding: const EdgeInsets.all(20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                processResponse(response);
                processInput(input);
              },
            ),
          ),
          shadow: const BoxShadow(
              color: Colors.transparent), // to remove shadow from appbar
        ),
      ),
    );
  }

  processLanguage(String? input, String? response) {
    _showPopup();
  }

  processResponse(String response) {
    bot_target = response;
  }

  processInput(String input) {
    user_source = input;
  }
}
