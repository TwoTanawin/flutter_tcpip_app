import 'dart:async';
import 'dart:io';
import 'dart:typed_data'; // Add this line
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum AppMode { Server, Client }

class _MyHomePageState extends State<MyHomePage> {
  ServerSocket? _server;
  Socket? _client;
  TextEditingController _ipController = TextEditingController();
  TextEditingController _portController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];
  AppMode _appMode = AppMode.Server;

  void _startServer() async {
    try {
      final server = await ServerSocket.bind(
        _ipController.text,
        int.parse(_portController.text),
      );
      setState(() {
        _server = server;
        _client = null;
        _addMessage(
            'Server started on ${server.address.address}:${server.port}');
      });
      server.listen((Socket client) {
        _addMessage(
            'Client connected: ${client.remoteAddress.address}:${client.remotePort}');
      });
    } catch (e) {
      _addMessage('Error starting server: $e');
    }
  }

  void _startClient() async {
    try {
      final client = await Socket.connect(
        _ipController.text,
        int.parse(_portController.text),
      );
      setState(() {
        _client = client;
        _server = null;
        _addMessage(
            'Connected to server: ${client.remoteAddress.address}:${client.remotePort}');
      });

      client.listen(
        (Uint8List data) {
          final message = String.fromCharCodes(data);
          _addMessage('Server: $message');
        },
        onDone: () {
          _addMessage('Disconnected from server');
          setState(() {
            _client = null;
          });
        },
        onError: (error) {
          _addMessage('Error with client: $error');
          setState(() {
            _client = null;
          });
        },
      );
    } catch (e) {
      _addMessage('Error connecting to server: $e');
    }
  }

  void _stopServer() {
    if (_server != null) {
      _server!.close();
      setState(() {
        _server = null;
        _addMessage('Server stopped');
      });
    }
  }

  void _sendMessage() {
    if (_client != null) {
      final message = _messageController.text;
      _client!.write(message);
      _addMessage('Client: $message');
      _messageController.clear();
    }
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
  }

  void _addMessage(String message) {
    setState(() {
      _messages.add(message);
    });
  }

  Widget _buildTextFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _ipController,
          decoration: InputDecoration(labelText: 'IP Address'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _portController,
          decoration: InputDecoration(labelText: 'Port'),
        ),
      ],
    );
  }

  Widget _buildModeDropdown() {
    return DropdownButton<AppMode>(
      value: _appMode,
      items: [
        DropdownMenuItem(
          child: Text('Server'),
          value: AppMode.Server,
        ),
        DropdownMenuItem(
          child: Text('Client'),
          value: AppMode.Client,
        ),
      ],
      onChanged: (value) {
        setState(() {
          _appMode = value!;
        });
      },
    );
  }

  Widget _buildStartStopButtons() {
    if (_appMode == AppMode.Server) {
      return Row(
        children: [
          ElevatedButton(
            onPressed: _startServer,
            child: Text('Start Server'),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: _stopServer,
            child: Text('Stop Server'),
          ),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: _startClient,
        child: Text('Connect to Server'),
      );
    }
  }

  Widget _buildMessageList() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: ListView.builder(
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_messages[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Column(
      children: [
        TextField(
          controller: _messageController,
          decoration: InputDecoration(labelText: 'Message'),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send Message'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _clearMessages,
              child: Text('Clear Messages'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TCP/IP Communication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextFields(),
            SizedBox(height: 20),
            _buildModeDropdown(),
            SizedBox(height: 20),
            _buildStartStopButtons(),
            SizedBox(height: 20),
            _buildMessageList(),
            SizedBox(height: 10),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }
}
