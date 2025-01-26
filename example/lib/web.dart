import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:hex/hex.dart';

import 'sw_client.dart';

void main() async {
  await MLDSASWClient.initialize();

  runApp(const MyApp());
}

class CryptoWidget extends StatefulWidget {
  const CryptoWidget({super.key});

  @override
  State<CryptoWidget> createState() => _CryptoWidgetState();
}

class _CryptoWidgetState extends State<CryptoWidget> {
  late int _strength;

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();

  Uint8List _pk = Uint8List(0);
  Uint8List _sk = Uint8List(0);
  Uint8List _sig = Uint8List(0);

  String _title = 'ML-DSA-44';

  @override
  void initState() {
    _strength = 44;
    super.initState();
  }

  void reset(String title) {
    setState(() {
      _title = title;
      _pk = Uint8List(0);
      _sk = Uint8List(0);
      _sig = Uint8List(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _strength = 44;
                reset('ML-DSA-44');
              },
              child: Text('44'),
            ),
            SizedBox(width: 24),
            ElevatedButton(
              onPressed: () {
                _strength = 65;
                reset('ML-DSA-65');
              },
              child: Text('65'),
            ),
            SizedBox(width: 24),
            ElevatedButton(
              onPressed: () {
                _strength = 87;
                reset('ML-DSA-87');
              },
              child: Text('87'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(_title),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final (pk, sk) = await MLDSASWClient.keyGen(_strength);
            setState(() {
              _pk = pk;
              _sk = sk;
            });
          },
          child: Text('Generate'),
        ),
        SizedBox(height: 8),
        Text('Message:'),
        TextField(
          controller: _messageController,
          minLines: 1,
          maxLines: 5,
        ),
        SizedBox(height: 8),
        Text('Context:'),
        TextField(
          controller: _contextController,
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            if (_sk.isEmpty) {
              final snackbar = SnackBar(content: Text('Must generate keys'));

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(snackbar);

              return;
            }

            final msg = utf8.encode(_messageController.text);
            final ctx = utf8.encode(_contextController.text);

            final sig = await MLDSASWClient.sign(_strength, _sk, msg, ctx);

            setState(() {
              _sig = sig;
            });
          },
          child: Text('Sign'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_sig.isEmpty) {
              final snackbar =
                  SnackBar(content: Text('Must create a signature'));

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(snackbar);

              return;
            }

            final msg = utf8.encode(_messageController.text);
            final ctx = utf8.encode(_contextController.text);

            final result = await MLDSASWClient.verify(_strength, _pk, msg, _sig, ctx);

            SnackBar snackbar;
            if (result) {
              snackbar = SnackBar(content: Text('Success'));
            } else {
              snackbar = SnackBar(content: Text('Failure'));
            }

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          },
          child: Text('Verify'),
        ),
        if (_pk.isNotEmpty)
          Text(
              "Public (${_pk.length} bytes): ${HEX.encode(_pk.sublist(0, 8))}..."),
        if (_sk.isNotEmpty)
          Text(
              "Private (${_sk.length} bytes): ${HEX.encode(_sk.sublist(0, 8))}..."),
        if (_sig.isNotEmpty)
          Text(
              "Signature (${_sig.length} bytes): ${HEX.encode(_sig.sublist(0, 8))}..."),
      ]),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ML-DSA example'),
        ),
        body: CryptoWidget(),
      ),
    );
  }
}
