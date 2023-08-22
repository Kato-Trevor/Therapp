import 'package:flutter/material.dart';
import 'Pallete.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:xen_popup_card/xen_card.dart';
import 'Languages.dart';
import 'translate_text.dart';
import 'package:google_fonts/google_fonts.dart';

class Article extends StatefulWidget {
  String Web_link, Title, Img_cat, Author;

  Article(
      {required this.Web_link,
      required this.Title,
      required this.Img_cat,
      required this.Author});

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  bool isLoading = true;
  List<String> data = [];
  String source_lang = "English";
  String target_lang = "English";
  String token = "";
  String? selectedValue;
  @override
  void initState() async {
    super.initState();
    await getAuthenticationKey().then((value) => {token = value});

    extractData().then((value) {
      setState(() {
        data = value;
        isLoading = false;
      });
    });
  }

  Future<List<String>> extractData() async {
    // Getting the response from the targeted url
    //
    final response = await http.Client().get(Uri.parse(widget.Web_link));

    final int maxLength = 1500;
    // Status Code 200 means response has been received successfully
    if (response.statusCode == 200) {
      // Getting the html document from the response
      var document = parser.parse(response.body);

      try {
        // Scraping the first article title
        var responseString = document.getElementsByTagName("p");

        var extracted_data = '';

        for (var text in responseString) {
          extracted_data = extracted_data + text.text;
        }

        var content = extracted_data.substring(0, maxLength) + "...";

        return [content, widget.Author];
      } catch (e) {
        return ['ERROR!', ''];
      }
    } else {
      return ['ERROR: ${response.statusCode}.', ''];
    }
  }

  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text(
            'Changing language...',
            style: TextStyle(color: Pallete.dark_purple),
          ),
          content: LinearProgressIndicator(
            backgroundColor: Pallete.light_purple,
            valueColor: AlwaysStoppedAnimation<Color>(Pallete.dark_purple),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: (() {
            Navigator.pop(context);
          }),
          child: const Icon(
            Icons.arrow_back,
            size: 20,
            color: Pallete.dark_purple,
          ),
        ),
        title: Text(
          widget.Title,
          style: const TextStyle(
            color: Pallete.dark_purple,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                            "lib/images/" + widget.Img_cat + ".jpg")),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: ElevatedButton.icon(
                            icon: Icon(
                              Icons.translate_rounded,
                              color: Colors.grey,
                              size: 30.0,
                            ),
                            label: Text(
                              'Language : ' + target_lang,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            onPressed: () {
                              buildTranslateDialog(context, false);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Uri url = Uri.parse(widget.Web_link);
                        if (await canLaunchUrl(url))
                          await launchUrl(url);
                        else
                          // can't launch url, there is some error
                          throw "Could not launch $url";
                      },
                      child: Text(
                        "Acquired from : " +
                            widget.Web_link.substring(0, 25) +
                            "...",
                        style: TextStyle(color: Pallete.light_purple),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Author Name : " + data[1],
                      style: const TextStyle(color: Pallete.light_purple),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                        text: data[0],
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                        children: [
                          TextSpan(
                            text: ' Read more',
                            style: const TextStyle(
                              color: Pallete.dark_purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                Uri url = Uri.parse(widget.Web_link);
                                if (await canLaunchUrl(url))
                                  await launchUrl(url);
                                else
                                  // can't launch url, there is some error
                                  throw "Could not launch $url";
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

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
              style: TextStyle(fontSize: 23, color: Pallete.dark_purple),
            ),
            const SizedBox(
              height: 50,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              items: Languages.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedValue = newValue;
                });
              },
            ),
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
                handleLanguageChange(selectedValue);
              },
            ),
          ),
          shadow: const BoxShadow(
              color: Colors.transparent), // to remove shadow from appbar
        ),
      ),
    );
  }

  void handleLanguageChange(String? newValue) async {
    _showPopup(); //show the processing dialog

    String conte = "";

    await generate_translation(data[0], newValue!, source_lang, token)
        .then((value) => {conte = value});

    setState(() {
      data[0] = conte;
      source_lang = newValue;
      target_lang = newValue;
    });
    Navigator.of(context).pop();
  }
}
