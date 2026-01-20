import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../models/customer.dart';

class ChatPage extends StatefulWidget {
  final String driverName;
  final String? driverId;
  final String? caseId;

  const ChatPage({
    super.key,
    required this.driverName,
    this.driverId,
    this.caseId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final StorageService _storage = StorageService();
  
  // 消息列表（包含temp message和server message）
  final List<ChatMessage> _messages = [];
  
  // Temp messages（臨時消息，等待服務器確認）
  final Map<String, ChatMessage> _tempMessages = {};
  
  Timer? _pollingTimer;
  int? _conversationId;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  bool _isInitialized = false;
  Customer? _customer;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    if (widget.caseId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.messageMissing)),
        );
      }
      return;
    }

    // 獲取當前用戶信息
    _customer = await _storage.getCustomer();
    if (_customer == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.pleaseLogin)),
        );
      }
      return;
    }

    // 創建或獲取對話會話
    final conversationResult = await _chatService.createOrGetConversation(
      caseId: int.parse(widget.caseId!),
      customerId: _customer!.id,
      driverId: widget.driverId != null ? int.parse(widget.driverId!) : null,
    );

    if (!conversationResult['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(conversationResult['message'] ?? AppLocalizations.of(context)!.chatInitFailed)),
        );
      }
      return;
    }

    setState(() {
      _conversationId = conversationResult['conversation']?['id'];
    });

    // 加載第一頁消息
    await _loadMessages(page: 1);

    // 開始3秒輪詢
    _startPolling();

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _loadMessages({int? page, bool isLoadMore = false}) async {
    if (_isLoadingMore && isLoadMore) return;
    if (!isLoadMore && !_hasMorePages && page != 1) return;

    setState(() {
      if (isLoadMore) {
        _isLoadingMore = true;
      }
    });

    final result = await _chatService.getMessages(
      caseId: int.parse(widget.caseId!),
      conversationId: _conversationId,
      page: page ?? _currentPage,
      pageSize: 20,
    );

    if (!mounted) return;

    if (result['success']) {
      final List<dynamic> messagesData = result['messages'] ?? [];
      final pagination = result['pagination'] ?? {};
      final hasNext = pagination['has_next'] ?? false;

      if (isLoadMore) {
        // 加載更多：添加到列表前面（因為reverse，更舊的消息在頂部）
        // API返回的消息是按created_at倒序的，所以第二页是更舊的消息
        final newMessages = messagesData.map((data) => _parseMessage(data)).toList();
        //  反轉順序，因為API返回的是倒序的，我們需要正序添加到前面
        final reversedMessages = newMessages.reversed.toList();
        setState(() {
          // 添加到列表前面（更舊的消息）
          _messages.insertAll(0, reversedMessages);
          _currentPage = page ?? _currentPage + 1;
          _hasMorePages = hasNext;
          _isLoadingMore = false;
        });
      } else {
        // 首次加載或刷新：替換所有消息
        final newMessages = messagesData.map((data) => _parseMessage(data)).toList();
        setState(() {
          _messages.clear();
          _messages.addAll(newMessages);
          // 按時間排序（reverse模式下，最新的在最後）
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          _currentPage = page ?? 1;
          _hasMorePages = hasNext;
          _isLoadingMore = false;
        });

        // 滾動到底部（最新消息）- ListView reverse: true 時，pixels = 0 顯示最新消息
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        });
      }
    } else {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted && !isLoadMore) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? AppLocalizations.of(context)!.loadMessagesFailed)),
        );
      }
    }
  }

  ChatMessage _parseMessage(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id']?.toString(),
      text: data['content'] ?? '',
      isFromPassenger: data['sender_type'] == 'customer',
      timestamp: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      isTemp: false,
    );
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // 只加載第一頁（最新消息）
      final result = await _chatService.getMessages(
        caseId: int.parse(widget.caseId!),
        conversationId: _conversationId,
        page: 1,
        pageSize: 20,
      );

      if (!mounted) return;

      if (result['success']) {
        final List<dynamic> messagesData = result['messages'] ?? [];
        final serverMessages = messagesData.map((data) => _parseMessage(data)).toList();

        setState(() {
          // 找出所有temp message的ID（基於時間戳匹配）
          final tempIdsToRemove = <String>[];
          
          for (final tempId in _tempMessages.keys) {
            final tempMsg = _tempMessages[tempId]!;
            // 检查服务器消息中是否有匹配的（相同内容和发送者，时间接近）
            final hasMatch = serverMessages.any((serverMsg) {
              return serverMsg.text == tempMsg.text &&
                  serverMsg.isFromPassenger == tempMsg.isFromPassenger &&
                  serverMsg.timestamp.difference(tempMsg.timestamp).abs().inSeconds < 10;
            });
            
            if (hasMatch) {
              tempIdsToRemove.add(tempId);
            }
          }

          // 移除已匹配的temp message
          for (final tempId in tempIdsToRemove) {
            _tempMessages.remove(tempId);
            _messages.removeWhere((msg) => msg.tempId == tempId);
          }

          // 找出新消息（不在現有列表中的服務器消息）
          final existingIds = _messages.where((m) => !m.isTemp && m.id != null).map((m) => m.id).toSet();
          final newServerMessages = serverMessages.where((m) => m.id != null && !existingIds.contains(m.id)).toList();
          
          if (newServerMessages.isNotEmpty) {
            // 添加新消息到列表末尾（reverse模式下，最新的在最底部）
            _messages.addAll(newServerMessages);
            // 按時間排序（reverse模式下，最新的在最後）
            _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            
            // 如果當前在底部（接近 0），自動滾動到最新消息
            if (_scrollController.hasClients) {
              final currentPosition = _scrollController.position.pixels;
              // 如果當前位置接近底部（< 100），自動滾動到最新消息
              if (currentPosition < 100) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            }
          }
        });
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 創建temp message
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final tempMessage = ChatMessage(
      id: null,
      text: text,
      isFromPassenger: true,
      timestamp: DateTime.now(),
      isTemp: true,
      tempId: tempId,
    );

    setState(() {
      _tempMessages[tempId] = tempMessage;
      _messages.add(tempMessage);
      // 按時間排序
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      _messageController.clear();
    });

    // ListView reverse: true 時，pixels = 0 顯示最新消息（底部），pixels = maxScrollExtent 顯示最舊消息（頂部）
    // 所以要顯示最新消息，應該滾動到 pixels = 0（ListView 底部）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // 滾動到 0（ListView 底部，顯示最新消息）
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // 發送到服務器
    final result = await _chatService.sendMessage(
      caseId: int.parse(widget.caseId!),
      content: text,
      conversationId: _conversationId,
      customerId: _customer?.id,
      driverId: widget.driverId != null ? int.parse(widget.driverId!) : null,
    );

    if (!mounted) return;

    if (!result['success']) {
      // 發送失敗，移除temp message
      setState(() {
        _tempMessages.remove(tempId);
        _messages.removeWhere((msg) => msg.tempId == tempId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? AppLocalizations.of(context)!.sendFailed)),
      );
    }
    // 如果成功，temp message會在下次輪詢時被服務器消息替換
  }

  void _onScroll() {
    // 檢測是否滾動到頂部，加載更多
    if (_scrollController.hasClients &&
        _scrollController.position.pixels <= 100 &&
        _hasMorePages &&
        !_isLoadingMore) {
      _loadMessages(page: _currentPage + 1, isLoadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.driverName),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.driverName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.startConversation,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        _onScroll();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true, // Reverse list
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        // Reverse index
                        final reversedIndex = _messages.length - 1 - index;
                        final message = _messages[reversedIndex];
                        return _buildMessageBubble(message);
                      },
                    ),
                  ),
          ),
          // 输入框
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.messageHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isFromPassenger = message.isFromPassenger;
    final isTemp = message.isTemp;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isFromPassenger ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromPassenger) ...[
            // 司机头像
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isFromPassenger ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isFromPassenger ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (isTemp && isFromPassenger) ...[
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isFromPassenger) ...[
            const SizedBox(width: 8),
            // 乘客頭像
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.green,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String? id;
  final String text;
  final bool isFromPassenger;
  final DateTime timestamp;
  final bool isTemp;
  final String? tempId;

  ChatMessage({
    this.id,
    required this.text,
    required this.isFromPassenger,
    required this.timestamp,
    this.isTemp = false,
    this.tempId,
  });
}
