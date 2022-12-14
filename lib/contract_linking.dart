// ignore_for_file: empty_constructor_bodies

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinking extends ChangeNotifier {
  // final String _rpcURl = "HTTP://127.0.0.1:7545";
  // final String _wsURl = "ws://127.0.0.1:7545";
  // final String _privateKey ="0x087e86cd8417090d75d8b1f99da2a21e74e4d831f5f6349bd70e955dce3fd98d";
  final String _rpcURl = dotenv.env['RPC_URL']!;
  final String _wsURl = dotenv.env['WS_URL']!;
  final String _privateKey = dotenv.env['PRIVATE_KEY']!;

  // print(dotenv.env['PRIVATE_KEY']!);

  late Web3Client _client;
  late String _abiCode;

  late EthereumAddress _contractAddress;
  late Credentials _credentials;

  late DeployedContract _contract;
  late ContractFunction _yourName;
  late ContractFunction _setName;

  bool isLoading = true;
  String? deployedName;

  ContractLinking() {
    _initialSetup();
  }

  _initialSetup() async {
    _client = Web3Client(
      _rpcURl,
      Client(),
      socketConnector: () {
        return IOWebSocketChannel.connect(_wsURl).cast<String>();
      },
    );

    await _getAbi();
    await _getCredentials();
    await _getDeployedContract();
  }

  Future<void> _getAbi() async {
    String abiStringFile =
        await rootBundle.loadString("src/artifacts/SimpleStorage.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);

    _contractAddress = EthereumAddress.fromHex(
      jsonAbi["networks"]["5777"]["address"],
    );
  }

  Future<void> _getCredentials() async {
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  Future<void> _getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "SimpleStorage"), _contractAddress);
    _yourName = _contract.function("yourName");
    _setName = _contract.function("setName");
    getName();
  }

  Future<void> getName() async {
    var currentName = await _client
        .call(contract: _contract, function: _yourName, params: []);
    deployedName = currentName[0];
    isLoading = false;
    notifyListeners();
  }

  Future<void> setName(String nameToSet) async {
    isLoading = true;
    notifyListeners();
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _setName,
        parameters: [nameToSet],
      ),
    );
    getName();
  }
}
