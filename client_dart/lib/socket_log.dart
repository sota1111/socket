import 'dart:io';
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final logManagerProvider = Provider<LogManager>((ref) {
  return LogManager();
});
class LogManager {
  File? logFile;

  Future<void> initLogFile() async {
    logFile = await _createLogFile();
  }

  Future<File> _createLogFile() async {
    //ディレクトリ設定
    final directory = await getExternalStorageDirectory();//todo:Linuxの内部ディレクトリに変更する必要あり
    if (directory == null) {
      throw Exception('External storage directory not found');
    }
    final logDirectory = Directory('${directory.path}/SocketLog/logs');
    if (!await logDirectory.exists()) {
      await logDirectory.create(recursive: true);
    }

    //ファイル名設定
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final logFile = File('${logDirectory.path}/socketLog_$timestamp.log');
    if (!await logFile.exists()) {
      await logFile.create(recursive: true);
    }
    return logFile;
  }

  Future<void> logToFile(String message) async {
    if (logFile == null) {
      debugPrint('LogFile not initialized');
      return;
    }
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final logLine = '$timestamp - $message\n';
    await logFile!.writeAsString(logLine, mode: FileMode.append, flush: true);
  }
}