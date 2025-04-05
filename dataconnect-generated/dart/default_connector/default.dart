library;

import 'package:firebase_data_connect/firebase_data_connect.dart';

class DefaultConnector {
  // ✅ Static config
  static final ConnectorConfig connectorConfig = ConnectorConfig(
    'us-central1',
    'default',
    'blogapp',
  );

  // ✅ Singleton getter
  static DefaultConnector get instance => DefaultConnector(
        FirebaseDataConnect.instanceFor(
          connectorConfig: connectorConfig,
          sdkType: CallerSDKType.generated,
        ),
      );

  final FirebaseDataConnect dataConnect;

  // ✅ Constructor
  DefaultConnector(this.dataConnect);
}

