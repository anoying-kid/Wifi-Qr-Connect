import "package:flutter/material.dart";
import "package:network_info_plus/network_info_plus.dart";

class WifiInfo {
  final String? ssid;
  final String? bssid;
  final String? ip;
  final String? gateway;

  WifiInfo({this.ssid, this.bssid, this.ip, this.gateway});
}

class WifiRepository {
  final NetworkInfo _info = NetworkInfo();

  Future<WifiInfo> fetchWifiInfo() async {
    final ssid = await _info.getWifiName();
    final bssid = await _info.getWifiBSSID();
    final ip = await _info.getWifiIP();
    final gateway = await _info.getWifiGatewayIP();

    final b = await _info.getWifiBroadcast();
    final c = await _info.getWifiIPv6();
    final d = await _info.getWifiSubmask();

    debugPrint(
        '${b} ${c} ${d} $ssid $bssid $ip $gateway');

    return WifiInfo(ssid: ssid, bssid: bssid, ip: ip, gateway: gateway);
  }
}
