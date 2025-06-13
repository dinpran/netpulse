import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:netpulse/helper/helper_functions.dart';
import 'package:netpulse/pages/drawer_pages.dart/about_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/internet_provider_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/language_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/settings_page.dart';
import 'package:netpulse/pages/home_page.dart';
import 'package:netpulse/service/database_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String fullName = "";
  String email = "";
  String uid = "";

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

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

    // Get user ID - you might need to add this method to helper_functions

    setState(() {
      uid = FirebaseAuth.instance.currentUser!.uid;
    });
  }

  _submitMessage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        DatabaseService databaseService = DatabaseService(uid: uid);
        await databaseService.submitAdminMessage(
          _titleController.text.trim(),
          _messageController.text.trim(),
          fullName,
          email,
        );

        // Clear form after successful submission
        _titleController.clear();
        _messageController.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Message submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
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
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: 40,
            ),
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
              leading: Icon(Icons.help),
              title: Text("Help"),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Text(
                  'Submit Message to Admin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.message),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitMessage,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Submit',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
