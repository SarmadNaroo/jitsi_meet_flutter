import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  SocketService(String url, String userId) {
    socket = IO.io(url, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setQuery({'userId': userId})
      .build()
    );

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });

    socket.on('call', (data) {
      // Handle incoming call data
      print('Incoming call data: $data');
    });

    socket.on('callStarted', (data) {
      final roomName = data['roomName'];
      // Trigger meeting creation in JitsiProvider
      print('Call started in room: $roomName');
    });

    socket.onError((error) {
      print('Socket error: $error');
    });
  }

  void emit(String event, Map<String, dynamic> data) {
    socket.emit(event, data);
  }

  void dispose() {
    socket.dispose();
  }
}
