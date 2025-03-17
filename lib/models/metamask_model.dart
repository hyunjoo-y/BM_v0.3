import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnect {
  static Future<String> loginUsingMetamask(BuildContext context) async {

    final Web3App web3app = await Web3App.createInstance(
      projectId: '79d88517a3032f1cb467d5d642758156',
      metadata: const PairingMetadata(
        name: 'Blockchain Messenger',
        description: 'Blockchain Messenger Wallet',
        url: 'https://walletconnect.com/',
        icons: [
          'https://walletconnect.com/walletconnect-logo.png',
        ],
      ),
    );

    final ConnectResponse response = await web3app.connect(
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          chains: [
            'eip155:1',
          ],
          methods: [
            'personal_sign',
            'eth_sign',
            'eth_signTransaction',
            'eth_signTypedData',
            'eth_sendTransaction',
          ],
          events: [
            'chainChanged',
            'accountsChanged',
          ],
        ),
      },
    );

    final Uri? uri = response.uri;
    if (uri != null) {
      final String encodedUri = Uri.encodeComponent('$uri');

      await launchUrlString(
        'metamask://wc?uri=$encodedUri',
        mode: LaunchMode.externalApplication,
      );

      SessionData session = await response.session.future;

      String account = NamespaceUtils.getAccount(
        session.namespaces.values.first.accounts[0],
      );
      print('account: $account');
      return account;
    }

    return '';
  }
}
