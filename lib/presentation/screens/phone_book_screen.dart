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
            Expanded(
              child: Container(
                color: Colors.white,
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
            ),
          ],
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
    contacts.add(Contact(
        '제주도청 환경관리과', '064-728-3129', Icons.sentiment_very_satisfied));
    contacts.add(Contact(
        '제주도청 환경정책과 ', '064-710-6010', Icons.sentiment_very_satisfied));
    contacts.add(Contact(
        '해양환경공단 제주사업소', '064-753-8396', Icons.sentiment_very_satisfied));
    contacts.add(Contact(
        '해양환경공단 서귀포사업소', '064-762-2856', Icons.sentiment_very_satisfied));
    contacts.add(Contact(
        '제주시 환경관리과', '064-728-3129', Icons.sentiment_very_satisfied));
    contacts.add(Contact(
        '서귀포시 생활환경과', '064-760-2930', Icons.sentiment_very_satisfied));
    contacts.add(Contact(
        '제주환경운동연합', '064-759-2162', Icons.sentiment_very_satisfied));
    contacts.add(Contact(
        '제주해경 해양오염방제과', '064-766-2191', Icons.sentiment_very_satisfied));
    contacts.add(Contact(
        '해양수산부 해양환경정책과', '044-200-5280', Icons.sentiment_very_satisfied));
    contacts.add(Contact(
        '해양수산부 해양보전과', '044-200-5300', Icons.sentiment_very_satisfied));



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


