import 'dart:convert';

import 'package:blockchain_messenger/models/contract_model.dart';
import 'package:blockchain_messenger/models/user_model.dart';

import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';




Future<DeployedContract> getContract(Contracts smartContract) async {
  String abiFile = await rootBundle.loadString(smartContract.abiJson);
  final contract = DeployedContract(ContractAbi.fromJson(abiFile, smartContract.contractName),
      EthereumAddress.fromHex(smartContract.contractAddress));

  return contract;
}

Future<List<dynamic>> callFunction(Contracts smartContract,String functionName) async {
  final contract = await getContract(smartContract);
  final function = contract.function(functionName);
  /*String foo = 'relay';
  List<int> bytsList = utf8.encode(foo);*/

  final result = await smartContract.client
      .call(contract: contract, function: function, params: []);
  return result;
}


Future<String> getRelayAddr(Contracts smartContract, String relayPeerId) async {
  final contract = await getContract(smartContract);
  final function = contract.function("getRelayAddr");

  final result = await smartContract.client
      .call(contract: contract, function: function, params: []);

  print("test${result[0]}");
  return result[0];

  //setState(() {});
}

Future<bool> getUserLogin(Contracts smartContract, String _userId, String _pubKey) async {
  final contract = await getContract(smartContract);
  final function = contract.function("getUserLogin");

  // Uint8List pwdBytes = Uint8List.fromList(utf8.encode(pubKey));

  final result = await smartContract.client
      .call(contract: contract, function: function, params: [_userId, _pubKey]);
  print("test${result[0]}");
  return result[0];

  //setState(() {});
}

Future<String> getUserProfileHash(Contracts smartContract, String userId) async {
  final contract = await getContract(smartContract);
  final function = contract.function("getUserProfileHash");

  final result = await smartContract.client
      .call(contract: contract, function: function, params: [userId]);
  print("test${result[0]}");
  return result[0];

  //setState(() {});
}

Future<bool> checkUserExists(Contracts smartContract, String userId) async {
  final contract = await getContract(smartContract);
  final function = contract.function("checkUserExists");

  final result = await smartContract.client
      .call(contract: contract, function: function, params: [userId]);
  print("test ${result[0]} $userId");
  return result[0];

}


// signup function
Future<bool?> registerUser(Contracts smartContract, User user) async {
  // snackBar(label: "Sign Up...");
  //obtain private key for write operation
  Credentials key = EthPrivateKey.fromHex(
      smartContract.privateKey);

  //obtain our contract from abi in json file
  final contract = await getContract(smartContract);
  final function = contract.function("registerUser");
  print('register result: $function');

  //send transaction using the our private key, function and contract
  final result = await smartContract.client.sendTransaction(
      key,
      Transaction.callContract(
          contract: contract, function: function,
          parameters: [
            user.id,
            user.nodeAddr,
            user.pubKey,
            user.profileHash
          ]),
      chainId: 1241);

  print('register result: $result');
  bool? check;

  if(result.isNotEmpty){
    check = true;
  }else{
    check = false;
  }

  return check;
}

