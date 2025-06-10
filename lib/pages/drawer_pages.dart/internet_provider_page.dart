import 'package:flutter/material.dart';
import 'package:netpulse/helper/helper_functions.dart';
import 'package:netpulse/pages/drawer_pages.dart/about_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/history_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/language_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/settings_page.dart';
import 'package:netpulse/pages/home_page.dart';

class InternetProviderPage extends StatefulWidget {
  const InternetProviderPage({super.key});

  @override
  State<InternetProviderPage> createState() => _InternetProviderPageState();
}

class _InternetProviderPageState extends State<InternetProviderPage> {
  String fullName = "";
  String email = "";
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // List of providers grouped by country
  final Map<String, List<String>> providersByCountry = {
    "Algeria": ["Algerie Telecom", "Djezzy", "Mobilis"],
    "Angola": ["Unitel"],
    "Argentina": ["Personal", "Telecentro", "IPlan"],
    "Armenia": ["Telecom Armenia", "Viva", "Ucom"],
    "Australia": ["Aussie Broadband", "iiNet", "NBN", "Optus", "Telstra"],
    "Brazil": [],
  };

  @override
  void initState() {
    super.initState();
    getUserData();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const SizedBox(height: 40),
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
              leading: const Icon(Icons.history),
              title: const Text("History"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Placeholder for Compare functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6F61),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Compare",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: providersByCountry.entries.map((entry) {
                    String country = entry.key;
                    List<String> providers = entry.value;

                    // Filter providers based on search query
                    List<String> filteredProviders = providers
                        .where((provider) =>
                            provider.toLowerCase().contains(searchQuery) ||
                            country.toLowerCase().contains(searchQuery))
                        .toList();

                    // Only show the country if it matches the search query or has matching providers
                    if (filteredProviders.isNotEmpty ||
                        country.toLowerCase().contains(searchQuery)) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            country,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (filteredProviders.isEmpty && providers.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Text(
                                "No providers available",
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: filteredProviders.map((provider) {
                                return OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFFFF6F61)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    provider,
                                    style: const TextStyle(
                                        color: Color(0xFFFF6F61)),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
