import 'dart:io';

void main(List<String> args) {
  Process.runSync(
        'networksetup', ['-setairportpower', 'en0', 'off'],);
}