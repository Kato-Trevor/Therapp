import 'package:flutter/material.dart';
import 'Languages.dart';
import 'package:xen_popup_card/xen_card.dart';

Future<dynamic> buildTranslateDialog(BuildContext context, bool isChat) {
  return showDialog(
    context: context,
    builder: (builder) => XenPopupCard(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Container(
              color: Colors.purple,
              child: Icon(Icons.translate_rounded, color: Colors.white)),
        ),
        Center(
            child: Text(
          "Choose Your Language",
          style: TextStyle(fontSize: 23, color: Colors.purple),
        )),
        SizedBox(
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
            onChanged: (value) {},
          ),
        ),
        SizedBox(
          height: 30,
        ),
        if (isChat) ...[
          Center(
              child: Text(
            "Choose Your Input Language",
            style: TextStyle(fontSize: 20, color: Colors.purple),
          )),
          SizedBox(
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
              onChanged: (value) {},
            ),
          ),
        ],
        SizedBox(
          height: 30,
        ),
        ElevatedButton(
          onPressed: () {},
          child: Text('SELECT'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
          ),
        )
      ],
    )),
  );
}
