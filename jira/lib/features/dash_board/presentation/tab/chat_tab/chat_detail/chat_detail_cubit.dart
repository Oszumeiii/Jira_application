// features/chat_detail/cubit/chat_detail_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_detail_state.dart';

class ChatDetailCubit extends Cubit<ChatDetailState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _messagesSubscription;
  final String chatId;
  final String chatName;

  ChatDetailCubit({required this.chatId, required this.chatName})
    : super(
        ChatDetailState(
          chatId: chatId,
          chatName: chatName,
          currentUserUid: FirebaseAuth.instance.currentUser?.uid ?? '',
        ),
      ) {
    _listenToMessages();
  }

  void _listenToMessages() {
    if (state.currentUserUid.isEmpty) {
      emit(state.copyWith(sendingError: 'Không xác thực người dùng'));
      return;
    }

    _messagesSubscription = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
            final messages = <ChatMessage>[];
            final userCache = <String, Map<String, dynamic>>{};

            for (var doc in snapshot.docs) {
              final data = doc.data();
              final fromUid = data['from'] as String;

              if (!userCache.containsKey(fromUid)) {
                final userDoc = await _db
                    .collection('users')
                    .doc(fromUid)
                    .get();
                userCache[fromUid] = userDoc.data() ?? {};
              }

              final userData = userCache[fromUid]!;

              messages.add(
                ChatMessage(
                  id: doc.id,
                  text: data['text'] ?? '',
                  from: fromUid,
                  time:
                      (data['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  isSystem: data['system'] == true,
                  senderName: userData['name'] ?? 'Unknown',
                  senderPhotoURL: userData['photoURL'],
                ),
              );
            }

            emit(state.copyWith(messages: messages, isLoading: false));
          },
          onError: (e) {
            emit(state.copyWith(sendingError: 'Lỗi tải tin nhắn'));
          },
        );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(state.copyWith(sendingError: 'Không xác thực'));
      return;
    }

    try {
      await _db.collection('chats').doc(chatId).collection('messages').add({
        'text': text.trim(),
        'from': uid,
        'time': FieldValue.serverTimestamp(),
        'system': false,
      });

      await _db.collection('chats').doc(chatId).update({
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      emit(state.copyWith(sendingError: null));
    } catch (e) {
      emit(state.copyWith(sendingError: 'Không thể gửi tin nhắn'));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
