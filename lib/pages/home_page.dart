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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _testInProgress = false;
  double _downloadSpeed = 0.0;
  double _uploadSpeed = 0.0;
  String _downloadProgress = '0';
  String _uploadProgress = '0';
  String _unitText = 'Mbps';
  bool _testCompleted = false;
  String fullName = "";
  String email = "";

  late AnimationController _pulseController;
  late AnimationController _gaugeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _gaugeAnimation;

  @override
  void initState() {
    super.initState();
    getUserData();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _gaugeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _gaugeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gaugeController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _gaugeController.dispose();
    super.dispose();
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

    _pulseController.stop();
    _gaugeController.reset();

    try {
      await _testDownloadSpeed();
      await _testUploadSpeed();

      setState(() {
        _testCompleted = true;
        _testInProgress = false;
      });

      _gaugeController.forward();
    } catch (e) {
      setState(() {
        _testInProgress = false;
        _testCompleted = false;
      });
      print('Speed test error: $e');
      _showError(
          'Speed test failed. Please check your internet connection and try again.');
      _pulseController.repeat(reverse: true);
    }
  }

  Future<void> _testDownloadSpeed() async {
    try {
      double totalBytes = 0;
      int successfulTests = 0;
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < _testUrls.length; i++) {
        setState(() {
          _downloadProgress = ((i / _testUrls.length) * 100).toStringAsFixed(2);
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

      final testData = _generateTestData(1 * 1024 * 1024);
      final stopwatch = Stopwatch()..start();

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
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: const Color(0xFFE53E3E),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

    _gaugeController.reset();
    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      appBar: AppBar(
        title: const Text(
          "NetPulse",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF2C2C2C),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        // backgroundColor: const Color(0xFFF5F3F0),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
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
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main Speed Test Circle
                    _buildMainSpeedTest(),

                    const SizedBox(height: 60),

                    // Speed Cards
                    _buildSpeedCards(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFFF5F3F0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD4A574), Color(0xFFB8926A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage("assets/login.png"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._buildDrawerItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    final items = [
      {'icon': Icons.home_outlined, 'title': 'Home', 'page': const HomePage()},
      {'icon': Icons.info_outline, 'title': 'About', 'page': const AboutPage()},
      {
        'icon': Icons.wifi_outlined,
        'title': 'Internet Provider',
        'page': const InternetProviderPage()
      },
      {
        'icon': Icons.history_outlined,
        'title': 'History',
        'page': const HistoryPage()
      },
      {
        'icon': Icons.language_outlined,
        'title': 'Language',
        'page': const LanguagePage()
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Settings',
        'page': const SettingsPage()
      },
    ];

    return items
        .map((item) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: item['title'] == 'Home'
                    ? const Color(0xFFD4A574).withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: ListTile(
                leading: Icon(
                  item['icon'] as IconData,
                  color: item['title'] == 'Home'
                      ? const Color(0xFFD4A574)
                      : const Color(0xFF4A5568),
                  size: 24,
                ),
                title: Text(
                  item['title'] as String,
                  style: TextStyle(
                    color: item['title'] == 'Home'
                        ? const Color(0xFFD4A574)
                        : const Color(0xFF2D3748),
                    fontWeight: item['title'] == 'Home'
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => item['page'] as Widget),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ))
        .toList();
  }

  Widget _buildMainSpeedTest() {
    if (!_testInProgress && !_testCompleted) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: GestureDetector(
              onTap: _startSpeedTest,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4A574), Color(0xFFB8926A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4A574).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
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
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else if (_testInProgress) {
      return _buildTestInProgress();
    } else {
      return _buildCompletedTest();
    }
  }

  Widget _buildTestInProgress() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _downloadProgress != '100' ? Icons.download : Icons.upload,
                size: 32,
                color: const Color(0xFFD4A574),
              ),
              const SizedBox(height: 8),
              Text(
                _downloadProgress != '100' ? 'Download' : 'Upload',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_downloadProgress != '100' ? _downloadProgress : _uploadProgress}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4A574),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTest() {
    return Column(
      children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _downloadSpeed.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                Text(
                  _unitText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF888888),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Download',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: _reset,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A574),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4A574).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Text(
              'Test Again',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedCards() {
    return Row(
      children: [
        Expanded(
            child: _buildSpeedCard('Download', _downloadSpeed, '( In Mbps )')),
        const SizedBox(width: 20),
        Expanded(child: _buildSpeedCard('Upload', _uploadSpeed, '( In Mbps )')),
      ],
    );
  }

  Widget _buildSpeedCard(String title, double speed, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4A574).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            speed > 0 ? speed.toStringAsFixed(2) : '0',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }
}
//
