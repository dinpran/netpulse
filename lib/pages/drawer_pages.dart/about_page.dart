import 'package:flutter/material.dart';
import 'package:netpulse/helper/helper_functions.dart';
import 'package:netpulse/pages/drawer_pages.dart/history_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/internet_provider_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/language_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/settings_page.dart';
import 'package:netpulse/pages/home_page.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String fullName = "";
  String email = "";

  @override
  void initState() {
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
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        title: const Text(
          "NetPulse",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(
              height: 40,
            ),
            ListTile(
              leading: const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/login.png"),
              ),
              title: Text(fullName),
              subtitle: Text(email),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return const HomePage();
                  },
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return const AboutPage();
                  },
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text("Internet Provider"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return const InternetProviderPage();
                  },
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return const HistoryPage();
                  },
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Language"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return const LanguagePage();
                  },
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              selected: true,
              selectedColor: Colors.black,
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return const SettingsPage();
                  },
                ));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/about.png",
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              color: const Color(0xFFF5E9E2),
              padding: const EdgeInsets.all(16.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About Us",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "1. Who We Are",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We’re a team of internet enthusiasts, developers, and network engineers on a mission to help people measure and understand their internet performance with clarity and simplicity.",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "2. What We Do",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Our web app offers fast, accurate, and ad-free internet speed tests — including download, upload, ping, jitter, and more. We help you get real insights into your connection quality.",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "3. Why We Built This",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We created this tool because many internet users don’t get the speeds they pay for. Our goal is to make internet testing fair, transparent, and available to everyone.",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "4. What Makes Us Different",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Lightweight, fast-loading interface\n• Real-time jitter and latency insights\n• Built for modern users and developers",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "5. Our Mission",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "To empower users with tools that reveal the truth about their internet.",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
