import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:jitsi_flutter_app/providers/auth_provider.dart';
import 'package:jitsi_flutter_app/services/socket_service.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late SocketService _socketService;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Dio _dio = Dio();
  final jitsiMeet = JitsiMeet(); // Instance of JitsiMeet
  List<dynamic> _users = [];
  String _username = '';
  Map<String, dynamic>? _incomingCall;
  String? _userId;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchUsername();
    await _fetchUserId();
    await _fetchUsers();
    _setupSocketListeners();
  }

  Future<void> _fetchUsername() async {
    final username = await _storage.read(key: 'username');
    setState(() {
      _username = username ?? 'Guest';
    });
  }

  Future<void> _fetchUserId() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userId = authProvider.userId;
    if (_userId != null) {
      _socketService = SocketService('http://localhost:5000', _userId!);
    }
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _storage.read(key: 'token');
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get('http://localhost:5000/api/users');
      if (response.statusCode == 200) {
        setState(() {
          _users = response.data;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load users. Status code: ${response.statusCode}';
          _users = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch users: $e';
        _users = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupSocketListeners() {
    _socketService.socket.on('call', (data) {
      setState(() {
        _incomingCall = data;
      });
    });

    _socketService.socket.on('callStarted', (data) {
      final roomName = data['roomName'];
      join(roomName); // Directly call join method
    });
  }

  void _startCall(String recipientId) {
    _socketService.emit('call', {'recipientId': recipientId});
  }

  void _acceptCall() {
    if (_incomingCall != null) {
      final roomName = _incomingCall!['roomName'];
      join(roomName); // Directly call join method
    }
  }

  // New method to join the Jitsi meeting
  void join(String roomName) {
    var options = JitsiMeetConferenceOptions(
      serverURL: 'https://meet.jit.si',
      room: roomName,
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
      },
      featureFlags: {
        "unsafeRoomWarning.enabled": false,
      },
    );
    jitsiMeet.join(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.blueGrey[100],
            child: Text(
              'Welcome, $_username',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          Expanded(
            child: _users.isEmpty
                ? Center(child: Text('No users available'))
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return ListTile(
                        title: Text(user['username']),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _startCall(user['_id']);
                          },
                          child: Text('Call'),
                        ),
                      );
                    },
                  ),
          ),
          if (_incomingCall != null) ...[
            Text('Incoming call from ${_incomingCall!['caller']}'),
            ElevatedButton(
              onPressed: _acceptCall,
              child: Text('Accept Call'),
            ),
          ],
          if (_errorMessage != null) ...[
            Text('Error: $_errorMessage'),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}
