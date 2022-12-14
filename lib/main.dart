// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:simple_storage_flutter_blockchain/contract_linking.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContractLinking(),
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: const HelloWorld(),
      ),
    );
  }
}

class HelloWorld extends StatefulWidget {
  const HelloWorld({Key? key}) : super(key: key);

  @override
  State<HelloWorld> createState() => _HelloWorldState();
}

class _HelloWorldState extends State<HelloWorld> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var contractLink = Provider.of<ContractLinking>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello World"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: contractLink.isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Form(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Hello ${contractLink.deployedName!}",
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 29),
                          child: TextFormField(
                            cursorColor: Colors.red,
                            scrollController: ScrollController(),
                            // showCursor: false,

                            controller: _textFieldController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: " Name",
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.yellow,
                              shadowColor: Colors.red,
                              elevation: 5,
                            ),
                            onPressed: () async {
                              await contractLink
                                  .setName(_textFieldController.text);
                              _textFieldController.clear();
                            },
                            child: const Text(
                              'Update',
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
