import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jira/core/firebase_config.dart';
import 'package:jira/features/dash_board/presentation/tab/chat_tab/chat/message_model.dart';
import 'chat_detail_state.dart';

class ChatDetailCubit extends Cubit<ChatDetailState> {
  final String initialId;
  final bool isGroup;
  final bool initialIsChatId;

  String? _chatDocId;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;

  final Completer<void> _initCompleter = Completer<void>();
  bool _isInitializing = false;

  ChatDetailCubit(this.initialId, this.isGroup, {this.initialIsChatId = false})
    : super(const ChatDetailState()) {
    _init();
  }

  Future<void> _init() async {
    if (_isInitializing) return;
    _isInitializing = true;
    try {
      final uid = FirebaseConfig.auth.currentUser?.uid;
      if (uid == null) {
        emit(state.copyWith(errorMessage: 'User chưa đăng nhập'));
        if (!_initCompleter.isCompleted) _initCompleter.complete();
        return;
      }

      if (initialIsChatId) {
        // Khi initialIsChatId = true, initialId là chatId đã tồn tại
        // KHÔNG BAO GIỜ tạo chat mới trong trường hợp này
        _chatDocId = initialId;
        print('[ChatDetailCubit._init] Using existing chatId: $initialId');

        // Đảm bảo chat tồn tại và cập nhật name nếu cần
        try {
          final chatDocRef = FirebaseConfig.firestore
              .collection('chats')
              .doc(initialId);

          final chatDoc = await chatDocRef.get();
          if (!chatDoc.exists) {
            emit(state.copyWith(errorMessage: 'Chat không tồn tại'));
            if (!_initCompleter.isCompleted) _initCompleter.complete();
            return;
          }

          final chatData = chatDoc.data() as Map<String, dynamic>? ?? {};
          final isGroupChat = chatData['isGroup'] == true;

          // Cập nhật name và photoURL nếu chat có name rỗng (chỉ cho 1-1 chat)
          if (!isGroupChat) {
            final currentName = (chatData['name'] ?? '').toString();
            final members = List<String>.from(chatData['members'] ?? []);

            // Chỉ cập nhật nếu name rỗng và có đúng 2 members
            if (currentName.isEmpty && members.length == 2) {
              final uid = FirebaseConfig.auth.currentUser?.uid;
              if (uid != null) {
                final otherUserId = members.firstWhere(
                  (id) => id != uid,
                  orElse: () => '',
                );

                if (otherUserId.isNotEmpty) {
                  final otherUserDoc = await FirebaseConfig.firestore
                      .collection('users')
                      .doc(otherUserId)
                      .get();

                  if (otherUserDoc.exists) {
                    final otherUserData = otherUserDoc.data()!;
                    final updateData = <String, dynamic>{};

                    final otherUserName =
                        otherUserData['userName'] ??
                        otherUserData['firstName'] ??
                        '';
                    if (otherUserName.isNotEmpty) {
                      updateData['name'] = otherUserName;
                    }

                    final otherUserPhoto = otherUserData['photoURL'];
                    if (otherUserPhoto != null) {
                      updateData['photoURL'] = otherUserPhoto;
                    }

                    if (updateData.isNotEmpty) {
                      // Cập nhật ngay lập tức trước khi load messages
                      await chatDocRef.update(updateData);
                      print(
                        '[ChatDetailCubit._init] Updated chat info: $updateData',
                      );
                    }
                  }
                }
              }
            }
          }
        } catch (e) {
          print('[ChatDetailCubit._init] Error checking/updating chat: $e');
          // Không return, vẫn tiếp tục load messages với chatId hiện tại
        }
      } else {
        // Chỉ tạo chat mới khi initialIsChatId = false
        if (isGroup) {
          _chatDocId = initialId;
        } else {
          // find existing 1-1 chat between uid and initialId
          // Tìm chat có đúng 2 thành viên là uid và initialId
          // Tìm từ cả 2 phía để đảm bảo không bỏ sót
          final queries = await Future.wait([
            FirebaseConfig.firestore
                .collection('chats')
                .where('isGroup', isEqualTo: false)
                .where('members', arrayContains: uid)
                .get(),
            FirebaseConfig.firestore
                .collection('chats')
                .where('isGroup', isEqualTo: false)
                .where('members', arrayContains: initialId)
                .get(),
          ]);

          String? foundId;
          final allDocs = <String, QueryDocumentSnapshot>{};
          for (var query in queries) {
            for (var doc in query.docs) {
              allDocs[doc.id] = doc;
            }
          }

          // Tìm chat có đúng 2 members và chứa cả uid và initialId
          for (var doc in allDocs.values) {
            final members =
                ((doc.data() as Map<String, dynamic>?)?['members'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [];

            // Kiểm tra có đúng 2 members và chứa cả uid và initialId
            if (members.length == 2 &&
                members.contains(uid) &&
                members.contains(initialId)) {
              foundId = doc.id;
              print(
                '[ChatDetailCubit._init] Found existing 1-1 chat: $foundId',
              );
              break;
            }
          }

          if (foundId != null) {
            _chatDocId = foundId;

            // Cập nhật name và photoURL nếu chat có name rỗng
            try {
              final chatDocRef = FirebaseConfig.firestore
                  .collection('chats')
                  .doc(foundId);

              final chatDoc = await chatDocRef.get();
              if (chatDoc.exists) {
                final chatData = chatDoc.data() as Map<String, dynamic>? ?? {};
                final currentName = (chatData['name'] ?? '').toString();

                if (currentName.isEmpty) {
                  final otherUserDoc = await FirebaseConfig.firestore
                      .collection('users')
                      .doc(initialId)
                      .get();

                  if (otherUserDoc.exists) {
                    final otherUserData = otherUserDoc.data()!;
                    final updateData = <String, dynamic>{};

                    final otherUserName =
                        otherUserData['userName'] ??
                        otherUserData['firstName'] ??
                        '';
                    if (otherUserName.isNotEmpty) {
                      updateData['name'] = otherUserName;
                    }

                    final otherUserPhoto = otherUserData['photoURL'];
                    if (otherUserPhoto != null) {
                      updateData['photoURL'] = otherUserPhoto;
                    }

                    if (updateData.isNotEmpty) {
                      await chatDocRef.update(updateData);
                      print(
                        '[ChatDetailCubit._init] Updated chat info: $updateData',
                      );
                    }
                  }
                }
              }
            } catch (e) {
              print('[ChatDetailCubit._init] Error updating chat: $e');
            }
          } else {
            // Chỉ tạo chat mới nếu KHÔNG tìm thấy chat nào
            print(
              '[ChatDetailCubit._init] No existing chat found, creating new one',
            );

            // Fetch the other user's info before creating chat
            String? otherUserName;
            String? otherUserPhoto;
            try {
              final otherUserDoc = await FirebaseConfig.firestore
                  .collection('users')
                  .doc(initialId)
                  .get();
              if (otherUserDoc.exists) {
                final otherUserData = otherUserDoc.data()!;
                otherUserName =
                    otherUserData['userName'] ??
                    otherUserData['firstName'] ??
                    '';
                otherUserPhoto = otherUserData['photoURL'];
              }
            } catch (e) {
              print('[ChatDetailCubit._init] Error fetching other user: $e');
            }

            final chatRef = await FirebaseConfig.firestore
                .collection('chats')
                .add({
                  'name': otherUserName ?? '', // Lưu tên ngay khi tạo
                  'isGroup': false,
                  'members': [uid, initialId],
                  'admin': uid,
                  'createdAt': FieldValue.serverTimestamp(),
                  'lastMessage': '',
                  'lastMessageTime': FieldValue.serverTimestamp(),
                  'lastMessageFrom': uid,
                  'photoURL': otherUserPhoto, // Lưu avatar ngay khi tạo
                });
            _chatDocId = chatRef.id;
            print(
              '[ChatDetailCubit._init] Created new 1-1 chat: ${chatRef.id}',
            );
          }
        }
      }

      // Đảm bảo _chatDocId đã được set trước khi load messages
      if (_chatDocId != null) {
        _loadMessages();
        _listenToTypingStatus();
      } else {
        emit(state.copyWith(errorMessage: 'Không thể xác định chat ID'));
      }

      if (!_initCompleter.isCompleted) _initCompleter.complete();
    } catch (e, st) {
      print('[ChatDetailCubit._init] Error: $e\n$st');
      emit(state.copyWith(errorMessage: 'Lỗi khởi tạo chat: $e'));
      if (!_initCompleter.isCompleted) _initCompleter.complete();
    } finally {
      _isInitializing = false;
    }
  }

  void _loadMessages() {
    final chatId = _chatDocId;
    if (chatId == null) {
      print(
        '[ChatDetailCubit._loadMessages] chatId is null, cannot load messages',
      );
      return;
    }

    print(
      '[ChatDetailCubit._loadMessages] Loading messages for chatId: $chatId',
    );
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    _messageSubscription?.cancel();
    _messageSubscription = FirebaseConfig.firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            print(
              '[ChatDetailCubit._loadMessages] Received ${snapshot.docs.length} messages',
            );
            final messages = snapshot.docs
                .map((d) => MessageModel.fromJson(d.data(), d.id))
                .toList();
            emit(
              state.copyWith(
                messages: messages,
                isLoading: false,
                errorMessage: '',
              ),
            );
          },
          onError: (e, st) {
            print('[ChatDetailCubit._loadMessages] Error: $e\n$st');
            emit(
              state.copyWith(
                errorMessage: 'Lỗi tải tin nhắn: $e',
                isLoading: false,
              ),
            );
          },
        );
  }

  void _listenToTypingStatus() {
    final chatId = _chatDocId;
    if (chatId == null) return;
    _typingSubscription?.cancel();
    _typingSubscription = FirebaseConfig.firestore
        .collection('chats')
        .doc(chatId)
        .collection('typingStatus')
        .snapshots()
        .listen(
          (snapshot) {
            final currentUid = FirebaseConfig.auth.currentUser?.uid;
            final isTyping = snapshot.docs.any((doc) {
              final data = doc.data();
              return data['uid'] != currentUid &&
                  (data['typing'] as bool? ?? false);
            });
            emit(state.copyWith(isTyping: isTyping));
          },
          onError: (e, st) {
            print('[ChatDetailCubit._listenToTypingStatus] $e\n$st');
          },
        );
  }

  Future<void> sendMessage(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;

    try {
      final uid = FirebaseConfig.auth.currentUser?.uid;
      if (uid == null) {
        emit(state.copyWith(errorMessage: 'User chưa đăng nhập'));
        return;
      }

      if (!_initCompleter.isCompleted) {
        await _initCompleter.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {},
        );
      }

      if (_chatDocId == null) {
        // Chỉ gọi _init() nếu chưa có chatId và initialIsChatId = false
        // Nếu initialIsChatId = true mà _chatDocId vẫn null, có lỗi
        if (initialIsChatId) {
          emit(state.copyWith(errorMessage: 'Chat ID không hợp lệ'));
          return;
        }
        await _init();
        if (_chatDocId == null) {
          emit(state.copyWith(errorMessage: 'Không thể xác định chat id'));
          return;
        }
      }

      final chatId = _chatDocId!;

      // Đảm bảo chat tồn tại trước khi gửi tin nhắn
      final chatDoc = await FirebaseConfig.firestore
          .collection('chats')
          .doc(chatId)
          .get();

      if (!chatDoc.exists) {
        emit(state.copyWith(errorMessage: 'Chat không tồn tại'));
        return;
      }

      await FirebaseConfig.firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'from': uid,
            'text': content,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'chatId': chatId,
          });

      await FirebaseConfig.firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageFrom': uid,
      });

      await setTyping(false);
    } catch (e, st) {
      print('[ChatDetailCubit.sendMessage] Error: $e\n$st');
      emit(state.copyWith(errorMessage: 'Lỗi gửi tin nhắn: $e'));
    }
  }

  Future<void> setTyping(bool typing) async {
    try {
      final uid = FirebaseConfig.auth.currentUser?.uid;
      if (uid == null || _chatDocId == null) return;
      await FirebaseConfig.firestore
          .collection('chats')
          .doc(_chatDocId)
          .collection('typingStatus')
          .doc(uid)
          .set({
            'uid': uid,
            'typing': typing,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e, st) {
      print('[ChatDetailCubit.setTyping] $e\n$st');
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    return super.close();
  }
}
