import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneBookScreen extends StatefulWidget {
  const PhoneBookScreen({Key? key}) : super(key: key);

  @override
  _PhoneBookScreenState createState() => _PhoneBookScreenState();
}

class _PhoneBookScreenState extends State<PhoneBookScreen> {
  List<Contact> contacts = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    contacts = buildContacts();
  }

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;

    return Container(
      width: sizeX,
      height: sizeY,
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 100,
              color: Colors.black,
              padding: const EdgeInsets.only(top: 30, left: 5),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft, // 왼쪽 정렬을 위해 Alignment.centerLeft 사용
                    child: Image.asset('assets/images/logo.png', color: Colors.white),
                  ),
                ],
              )
            ),
            Container(
              padding: const EdgeInsets.only(top: 30),
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  filterContacts(value);
                },
                decoration: const InputDecoration(
                  hintText: '검색어를 입력해주세요.',
                  border: InputBorder.none,
                  icon: Padding(
                    padding: EdgeInsets.only(left: 13),
                    child: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            const Divider(
              height: 1,
              color: Colors.grey,
            ),
            Container(
              color: Colors.white,
              width: sizeX,
              height: sizeY,
              child: ListView.separated(
                itemCount: contacts.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(contacts[index].name),
                    subtitle: Text(contacts[index].number),
                    leading: CircleAvatar(
                      child: Icon(contacts[index].icon),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () {
                        launchPhoneUrl(Uri.parse('tel:${contacts[index].number}'));
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 1,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

  }

  void launchPhoneUrl(Uri uri) async {
    if(await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  List<Contact> buildContacts() {
    List<Contact> contacts = [];
    // 전화번호부
    contacts.add(Contact(
        '제주청 해양오염방제과', '064-801-2591', Icons.sentiment_very_satisfied));
    contacts.add(Contact(
        '제주시 해양오염방제과', '064-766-2591', Icons.sentiment_very_satisfied));
    contacts.add(Contact(
        '서귀포시 해양오염방제과', '064-793-2591', Icons.sentiment_very_satisfied));

    return contacts;
  }

  void filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        contacts = buildContacts();
      } else {
        contacts = buildContacts()
            .where((contact) =>
        contact.name.toLowerCase().contains(query.toLowerCase()) ||
            contact.number.contains(query))
            .toList();
      }
    });
  }
}

class Contact {
  String name;
  String number;
  IconData icon;
  Contact(this.name, this.number, this.icon);
}


