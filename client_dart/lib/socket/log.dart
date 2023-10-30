import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
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
    // プラットフォーム判定
    String logDirPath;
    if (Platform.isLinux) {
      logDirPath = join(Platform.environment['HOME'] ?? '', 'socketLog');
    } else {
      // 他のプラットフォーム用のディレクトリ取得処理
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('External storage directory not found');
      }
      logDirPath = '${directory.path}/SocketLog/logs';
    }

    // ディレクトリ設定
    final logDirectory = Directory(logDirPath);
    if (!await logDirectory.exists()) {
      await logDirectory.create(recursive: true);
    }

    // ファイル名設定
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