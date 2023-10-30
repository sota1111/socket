import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SocketDataState {
  final Map<String, dynamic> sendData;
  final Map<String, dynamic> receivedData;

  SocketDataState({required this.sendData, required this.receivedData});
}

final socketDataProvider = StateNotifierProvider<SocketNotifier, SocketDataState>(
      (ref) {
    return SocketNotifier(
      SocketDataState(
        sendData: {},
        receivedData: {},
      ),
    );
  },
);

class SocketNotifier extends StateNotifier<SocketDataState> {
  SocketNotifier(SocketDataState state) : super(state);
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);

  Map<String, dynamic> getSendData() {
    return state.sendData;
  }

  void updateSendData(Map<String, dynamic> newSendData) {//todo: 現状使う必要はない。
    state = SocketDataState(
      sendData: newSendData,
      receivedData: state.receivedData,
    );
  }

  void updateReceivedData(Map<String, dynamic> newReceivedData) {
    state = SocketDataState(
      sendData: state.sendData,
      receivedData: newReceivedData,
    );
  }
}
