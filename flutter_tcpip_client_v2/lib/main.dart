import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCP/IP Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Socket? socket;
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void connectToServer() async {
    try {
      socket = await Socket.connect(
          ipController.text, int.parse(portController.text));
      if (socket != null) {
        print(
            'Connected to ${socket?.remoteAddress.address}:${socket?.remotePort}');
        setupSocketListener();
      } else {
        print('Connection failed');
        updateChat('Connection failed');
      }
    } catch (e) {
      print('Error connecting to server: $e');
      updateChat('Error connecting to server: $e');
    }
  }

  void setupSocketListener() {
    socket?.listen(
      (List<int> data) {
        String message = utf8.decode(data);
        print('Received: $message');
        updateChat('Server: $message');
      },
      onDone: () {
        print('Server disconnected');
        socket?.destroy();
      },
      onError: (error) {
        print('Error: $error');
        socket?.destroy();
      },
    );
  }

  void disconnectFromServer() {
    if (socket != null) {
      try {
        socket?.destroy();
        print('Disconnected from server');
        updateChat('Disconnected from server');
      } catch (e) {
        print('Error disconnecting from server: $e');
        updateChat('Error disconnecting from server: $e');
      }
    } else {
      print('Not connected to any server');
      updateChat('Not connected to any server');
    }
  }

  void submitMessage() {
    if (socket != null) {
      try {
        String message = messageController.text;
        socket?.write(utf8.encode(message));
        print('Sent: $message');
        updateChat('You: $message');
        messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
        updateChat('Error sending message: $e');
      }
    } else {
      print('Not connected to any server');
      updateChat('Not connected to any server');
    }
  }

  void clearChat() {
    setState(() {
      chatController.clear();
    });
  }

  void updateChat(String message) {
    setState(() {
      chatController.text += message + '\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TCP/IP Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: ipController,
              decoration: InputDecoration(labelText: 'Enter IP'),
            ),
            TextField(
              controller: portController,
              decoration: InputDecoration(labelText: 'Enter Port'),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: connectToServer,
                  child: Text('Connect'),
                ),
                ElevatedButton(
                  onPressed: disconnectFromServer,
                  child: Text('Disconnect'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: chatController,
                  readOnly: true,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Chat',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: submitMessage,
                  child: Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: clearChat,
                  child: Text('Clear'),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Enter Message'),
            ),
          ],
        ),
      ),
    );
  }
}
