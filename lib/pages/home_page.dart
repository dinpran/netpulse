import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:netpulse/helper/helper_functions.dart';
import 'package:netpulse/pages/drawer_pages.dart/about_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/history_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/internet_provider_page.dart';
import 'package:netpulse/pages/drawer_pages.dart/language_page.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

import 'package:netpulse/pages/drawer_pages.dart/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _testInProgress = false;
  double _downloadSpeed = 0.0;
  double _uploadSpeed = 0.0;
  String _downloadProgress = '0';
  String _uploadProgress = '0';
  String _unitText = 'Mbps';
  bool _testCompleted = false;
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
        fullName = value ?? "";
      });
    });

    HelperFunctions.getUserEmailKey().then((value) {
      setState(() {
        email = value ?? "";
      });
    });
  }

  // Updated test URLs with HTTPS and more reliable servers
  final List<Map<String, dynamic>> _testUrls = [
    {
      'url':
          'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-zip-file.zip',
      'size': 1024 * 1024, // 1MB
    },
    {
      'url':
          'https://file-examples.com/storage/fe68c9c451e445bb9b5c17e/2017/10/file_example_JPG_2500kB.jpg',
      'size': 2.5 * 1024 * 1024, // 2.5MB
    },
  ];

  Future<void> _startSpeedTest() async {
    setState(() {
      _testInProgress = true;
      _testCompleted = false;
      _downloadSpeed = 0.0;
      _uploadSpeed = 0.0;
      _downloadProgress = '0';
      _uploadProgress = '0';
    });

    try {
      await _testDownloadSpeed();
      await _testUploadSpeed();

      setState(() {
        _testCompleted = true;
        _testInProgress = false;
      });
    } catch (e) {
      setState(() {
        _testInProgress = false;
        _testCompleted = false;
      });
      print('Speed test error: $e');
      _showError(
          'Speed test failed. Please check your internet connection and try again.');
    }
  }

  Future<void> _testDownloadSpeed() async {
    try {
      double totalBytes = 0;
      int successfulTests = 0;
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < _testUrls.length; i++) {
        setState(() {
          _downloadProgress = ((i / _testUrls.length) * 100).toStringAsFixed(0);
        });

        try {
          final client = http.Client();
          final request = http.Request('GET', Uri.parse(_testUrls[i]['url']));

          final response = await client.send(request).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                  'Download timeout', const Duration(seconds: 30));
            },
          );

          if (response.statusCode == 200) {
            final bytes = await response.stream.toBytes();
            totalBytes += bytes.length;
            successfulTests++;

            final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
            if (elapsedSeconds > 0) {
              final speedBps = totalBytes / elapsedSeconds;
              final speedMbps = (speedBps * 8) / (1024 * 1024);

              setState(() {
                _downloadSpeed = speedMbps;
                _unitText = speedMbps >= 1 ? 'Mbps' : 'Kbps';
                if (speedMbps < 1) {
                  _downloadSpeed = speedMbps * 1024;
                }
              });
            }
          }
          client.close();
        } catch (e) {
          print('Download test ${i + 1} failed: $e');
          // Continue with next test
          continue;
        }
      }

      stopwatch.stop();

      if (successfulTests == 0) {
        throw Exception('All download tests failed');
      }

      setState(() {
        _downloadProgress = '100';
      });
    } catch (e) {
      print('Download test error: $e');
      throw Exception('Download test failed: $e');
    }
  }

  Future<void> _testUploadSpeed() async {
    try {
      setState(() {
        _uploadProgress = '0';
      });

      // Use a smaller test data size for better reliability
      final testData = _generateTestData(1 * 1024 * 1024); // 1MB instead of 5MB
      final stopwatch = Stopwatch()..start();

      // Try multiple upload endpoints for better reliability
      final uploadUrls = [
        'https://httpbin.org/post',
        'https://postman-echo.com/post',
        'https://jsonplaceholder.typicode.com/posts',
      ];

      bool success = false;

      for (String uploadUrl in uploadUrls) {
        try {
          print('Attempting upload to: $uploadUrl');

          final client = http.Client();
          final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            testData,
            filename: 'test_data.bin',
          ));

          final response = await client.send(request).timeout(
            const Duration(seconds: 45),
            onTimeout: () {
              throw TimeoutException(
                  'Upload timeout', const Duration(seconds: 45));
            },
          );

          print('Upload response: Status ${response.statusCode}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
            if (elapsedSeconds > 0) {
              final speedBps = testData.length / elapsedSeconds;
              final speedMbps = (speedBps * 8) / (1024 * 1024);

              setState(() {
                _uploadSpeed = speedMbps >= 1 ? speedMbps : speedMbps * 1024;
                _unitText = speedMbps >= 1 ? 'Mbps' : 'Kbps';
                _uploadProgress = '100';
              });
              print(
                  'Upload speed: $_uploadSpeed $_unitText, Time: $elapsedSeconds s');
            }
            success = true;
            client.close();
            break;
          }
          client.close();
        } catch (e) {
          print('Upload failed to $uploadUrl: $e');
          continue;
        }
      }

      if (!success) {
        print('All upload attempts failed');
        // Set a default upload speed to avoid showing error
        setState(() {
          _uploadSpeed = 0.0;
          _uploadProgress = '100';
        });
      }

      stopwatch.stop();
    } catch (e) {
      print('Upload test error: $e');
      setState(() {
        _uploadSpeed = 0.0;
        _uploadProgress = '100';
      });
      // Don't throw error for upload failure, just log it
      print('Upload test failed, continuing without upload speed data');
    }
  }

  Uint8List _generateTestData(int size) {
    final random = Random();
    final data = Uint8List(size);
    for (int i = 0; i < size; i++) {
      data[i] = random.nextInt(256);
    }
    return data;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _reset() {
    setState(() {
      _testInProgress = false;
      _downloadSpeed = 0.0;
      _uploadSpeed = 0.0;
      _downloadProgress = '0';
      _uploadProgress = '0';
      _unitText = 'Mbps';
      _testCompleted = false;
    });
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
      backgroundColor: const Color(0xFFF5E8D3),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular "GO" button or gauge based on test state
                if (!_testInProgress && !_testCompleted)
                  GestureDetector(
                    onTap: _startSpeedTest,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE57373),
                            Color(0xFFD32F2F),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'GO',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (_testInProgress)
                  Column(
                    children: [
                      const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _downloadProgress != '100'
                            ? 'Testing Download Speed...'
                            : 'Testing Upload Speed...',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _downloadProgress != '100'
                            ? 'Download: $_downloadProgress%'
                            : 'Upload: $_uploadProgress%',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                else
                  // Circular speed gauge
                  Container(
                    width: 250,
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                        // Progress circle
                        Container(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: _downloadSpeed > 0
                                ? (_downloadSpeed / 100).clamp(0.0, 1.0)
                                : 0.0,
                            strokeWidth: 15,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _downloadSpeed > 50
                                  ? const Color(0xFFFFD700) // Gold
                                  : _downloadSpeed > 25
                                      ? const Color(0xFFFFB347) // Orange-Gold
                                      : const Color(0xFFFFA500), // Orange
                            ),
                          ),
                        ),
                        // Inner circle with speed text
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFFD700).withOpacity(0.1),
                                const Color(0xFFFFA500).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _downloadSpeed > 0
                                    ? _downloadSpeed.toStringAsFixed(2)
                                    : '0.00',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB8860B), // Dark golden rod
                                ),
                              ),
                              Text(
                                _unitText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFDAA520), // Golden rod
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Download',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),

                // Restart button
                if (_testCompleted)
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.refresh,
                        size: 18,
                        color: Colors.black54,
                      ),
                      label: const Text(
                        'Restart',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),

                // Download and Upload cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSpeedCard(
                      'Download',
                      _downloadSpeed,
                      _unitText,
                      _downloadProgress,
                      Icons.download,
                      Colors.green,
                    ),
                    const SizedBox(width: 20),
                    _buildSpeedCard(
                      'Upload',
                      _uploadSpeed,
                      _unitText,
                      _uploadProgress,
                      Icons.upload,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGaugeMarker(String label) {
    return Column(
      children: [
        const Text(
          '—',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedCard(
    String label,
    double speed,
    String unit,
    String progress,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '(In Mbps)',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            speed > 0 ? speed.toStringAsFixed(2) : '0.00',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
//
