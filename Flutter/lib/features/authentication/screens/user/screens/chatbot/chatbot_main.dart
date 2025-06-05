import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'chat_service.dart';

class ChatbotMain extends StatefulWidget {
  const ChatbotMain({super.key});

  @override
  State<ChatbotMain> createState() => _ChatbotMainState();
}

class _Message {
  final String text;
  final bool fromUser;
  _Message(this.text, this.fromUser);
}

class _ChatbotMainState extends State<ChatbotMain> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_Message> _messages = [];
  final ChatService _chatService = ChatService();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleSend() async {
    final input = _textController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _messages.add(_Message(input, true));
      _scrollToBottom();
    });
    _textController.clear();

    // Send User input
    try {
      final String reply = await _chatService.sendMessage(
        input,
        onTypingStateChanged: (isTyping) {
          if (mounted) {
            setState(() {
              _isTyping = isTyping;
              if (!_isTyping) {
                _scrollToBottom();
              } else {
                _scrollToBottom(isForTypingIndicator: true);
              }
            });
          }
        },
      );

      setState(() {
        _messages.add(_Message(reply, false));
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _messages.add(_Message("Error", false));
        _scrollToBottom();
      });
    }
  }

  // Scroll to bottom
  void _scrollToBottom({bool isForTypingIndicator = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        Future.delayed(Duration(milliseconds: isForTypingIndicator ? 50 : 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        excludeHeaderSemantics: true,
        title: const Text("AI Assistant"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(

          // Chat bubbles
          child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Align(
                    alignment: msg.fromUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: BubbleSpecialTwo(
                      isSender: msg.fromUser,
                      color: msg.fromUser
                          ? const Color(0xFF4FC3F7)
                          : const Color(0xFFE5E5E5),
                      tail: true,
                      text: msg.text,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Show typing
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 8.0, right: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: BubbleSpecialTwo(
                  isSender: false,
                  color: const Color(0xFFE5E5E5),
                  tail: true,
                  text: "AI Assistant is searching...",
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(

                // Input field
                child: TextFormField(
                    controller: _textController,
                    onFieldSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: "Find a product ...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                        const BorderSide(color: Color(0xFF4FC3F7), width: 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),

                // Send button
                FloatingActionButton(
                  heroTag: "send_button",
                  onPressed: _isTyping ? null : _handleSend,
                  backgroundColor: _isTyping ? Colors.grey : const Color(0xFF4FC3F7),
                  foregroundColor: Colors.white,
                  elevation: _isTyping ? 0 : 2,
                  child: const Icon(Icons.send),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}