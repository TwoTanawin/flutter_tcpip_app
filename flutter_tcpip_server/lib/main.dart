import 'dart:async';
import 'dart:io';
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

class _MyHomePageState extends State<MyHomePage> {
  ServerSocket? _server;
  TextEditingController _ipController = TextEditingController();
  TextEditingController _portController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];

  void _startServer() async {
    try {
      final server = await ServerSocket.bind(
        _ipController.text,
        int.parse(_portController.text),
      );
      setState(() {
        _server = server;
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

  void _stopServer() {
    if (_server != null) {
      _server!.close();
      setState(() {
        _server = null;
        _addMessage('Server stopped');
      });
    }
  }

  void _addMessage(String message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _submitMessage() {
    _addMessage('User: ${_messageController.text}');
    _messageController.clear();
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
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

  Widget _buildServerButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: _startServer,
          child: Text('Start'),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: _stopServer,
          child: Text('Stop'),
        ),
      ],
    );
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
              onPressed: _submitMessage,
              child: Text('Submit'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _clearMessages,
              child: Text('Clear'),
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
        title: Text('TCP/IP Server'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextFields(),
            SizedBox(height: 20),
            _buildServerButtons(),
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
