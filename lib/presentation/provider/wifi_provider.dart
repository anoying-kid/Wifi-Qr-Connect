import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_wifi_connect/core/services/wifi_repository.dart';

final wifiRepoProvider = Provider<WifiRepository>((ref) => WifiRepository());

final wifiInfoProvider = FutureProvider<WifiInfo>(
  (ref) async {
    final repo = ref.watch(wifiRepoProvider);
    return repo.fetchWifiInfo();
  },
);
