import 'package:flutter/material.dart';
import 'package:netpulse/auth/login_page.dart';
import 'package:netpulse/helper/helper_functions.dart';
import 'package:netpulse/pages/admin_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/about_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/history_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/internet_provider_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/language_page.dart';
import 'package:netpulse/pages/home_page.dart';
import 'package:netpulse/service/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String fullName = "";
  String email = "";
  AuthService authService = AuthService();
  bool isAdmin = false; // Add this variable to track admin status

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
        // Check if the user is admin based on email
        isAdmin = (email == "purplemerit-admin1645@gmail.com");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        title: Text(
          "NetPulse",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Show admin icon only if user is admin
          if (isAdmin)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return AdminPage();
                  },
                ));
              },
              icon: Icon(
                Icons.admin_panel_settings,
                color:
                    Colors.blue, // Optional: Add color to highlight admin icon
              ),
              tooltip: "Admin Panel", // Optional: Add tooltip
            ),
        ],
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

            // Optional: Add Admin Panel to drawer as well (only for admin)
            if (isAdmin)
              ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.blue,
                ),
                title: const Text(
                  "Admin Panel",
                  style: TextStyle(color: Colors.blue),
                ),
                selected: true,
                selectedColor: Colors.blue,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return const AdminPage();
                    },
                  ));
                },
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Account Settings",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // Optional: Show admin badge in body as well
                  if (isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "ADMIN",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              // Profile Section
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/login.png"),
                ),
                title: Text(
                  fullName.isNotEmpty ? fullName : "Loading...",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  email.isNotEmpty ? email : "Loading...",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                selected: true,
                selectedColor: Colors.black,
                onTap: () {},
              ),

              const SizedBox(height: 10),

              // Profile picture buttons
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Placeholder for changing profile picture
                    },
                    child: const Text(
                      "Change profile picture",
                      style: TextStyle(
                        color: Color(0xFFFF6F61),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      // Placeholder for removing profile picture
                    },
                    child: const Text(
                      "Remove",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Full Name Section
              const Text(
                "Full Name",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  fullName.isNotEmpty ? fullName : "Loading...",
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 40),

              // Email Section
              const Text(
                "Email",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  email.isNotEmpty ? email : "Loading...",
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 60),

              // Logout Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Logout functionality
                    await authService.sigout();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) {
                        return const LoginPage();
                      },
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6F61),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
