import 'package:flutter/material.dart';
import 'package:netpulse/helper/helper_functions.dart';
import 'package:netpulse/pages/drawer_pages.dart/about_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/internet_provider_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/language_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/settings_page.dart';
import 'package:netpulse/pages/home_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String fullName = "";
  String email = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  getUserData() async {
    HelperFunctions.getUserNameKey().then((value) {
      setState(() {
        fullName = value!;
      });
    });

    HelperFunctions.getUserEmailKey().then((value) {
      setState(() {
        email = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: 40,
            ),
            // Icon(
            //   Icons.person,
            //   size: 150,
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            // Text(
            //   "${fullName}",
            //   textAlign: TextAlign.center,
            // ),
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/login.png"),
              ),
              title: Text("${fullName}"),
              subtitle: Text("${email}"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return HomePage();
                  },
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("About"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return AboutPage();
                  },
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.wifi),
              title: Text("Internet Provider"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return InternetProviderPage();
                  },
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("History"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return HistoryPage();
                  },
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text("Language"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return LanguagePage();
                  },
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage();
                  },
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
