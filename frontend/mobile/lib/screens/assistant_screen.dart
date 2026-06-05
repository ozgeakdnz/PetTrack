import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/pet_models.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

const _welcome =
    'Merhaba! Ben Pati Dostu AI. Evcil hayvan bakımı, belirtiler ve uygulama kullanımı hakkında sorularını yanıtlamaya hazırım. 🐾';

const _quickQuestionsDefault = [
  _QuickQ(Icons.restaurant_rounded, 'Kedim bugün çok iştahsız ne yapmalıyım?'),
  _QuickQ(Icons.vaccines_rounded, 'Köpeklerde aşı sonrası halsizlik normal mi?'),
  _QuickQ(Icons.egg_alt_outlined, 'Yavru kuşların beslenme sıklığı nedir?'),
];

class _QuickQ {
  const _QuickQ(this.icon, this.text);
  final IconData icon;
  final String text;
}

class _UiMessage {
  _UiMessage({required this.role, required this.content, required this.time});

  final String role;
  final String content;
  final DateTime time;

  bool get isUser => role == 'user';
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_UiMessage>[
    _UiMessage(role: 'assistant', content: _welcome, time: DateTime.now()),
  ];
  bool _loading = false;
  List<_QuickQ> _quickQuestions = _quickQuestionsDefault;
  String _disclaimer =
      'Bu yapay zeka tavsiyeleri profesyonel teşhis ile yer değiştiremez. Acil durumlarda lütfen en yakın veteriner kliniğine başvurun.';

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    try {
      final meta = await ApiService.instance.getChatMeta();
      if (!mounted) return;
      setState(() {
        if (meta.suggestions.isNotEmpty) {
          _quickQuestions = meta.suggestions
              .asMap()
              .entries
              .map((e) => _QuickQ(_iconForIndex(e.key), e.value))
              .toList();
        }
        if (meta.disclaimer.isNotEmpty) _disclaimer = meta.disclaimer;
      });
    } catch (_) {}
  }

  static IconData _iconForIndex(int i) {
    switch (i % 3) {
      case 0:
        return Icons.restaurant_rounded;
      case 1:
        return Icons.vaccines_rounded;
      default:
        return Icons.egg_alt_outlined;
    }
  }

  void _attachContext() {
    setState(() {
      _input.text = '${_input.text}Belirti: '.trim();
      _input.selection = TextSelection.fromPosition(TextPosition(offset: _input.text.length));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Belirti bağlamı eklendi — detayları yazın')),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    final prompt = text.trim();
    if (prompt.isEmpty || _loading) return;

    setState(() {
      _messages.add(_UiMessage(role: 'user', content: prompt, time: DateTime.now()));
      _loading = true;
    });
    _input.clear();
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => m.content != _welcome || m.role == 'user')
          .map((m) => ChatMessage(role: m.role, content: m.content))
          .toList();
      final reply = await ApiService.instance.chat(prompt, history);
      if (!mounted) return;
      setState(() {
        _messages.add(_UiMessage(role: 'assistant', content: reply, time: DateTime.now()));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _UiMessage(
            role: 'assistant',
            content: e.toString().replaceFirst('Exception: ', ''),
            time: DateTime.now(),
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _clearChat() {
    setState(() {
      _messages
        ..clear()
        ..add(_UiMessage(role: 'assistant', content: _welcome, time: DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildDisclaimer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                'HIZLI SORULAR',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                ),
              ),
            ),
            SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _quickQuestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final q = _quickQuestions[i];
                  return SizedBox(
                    width: 200,
                    child: Material(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      elevation: 1,
                      shadowColor: Colors.black26,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _loading ? null : () => _send(q.text),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(q.icon, color: AppColors.primary, size: 22),
                              const Spacer(),
                              Text(
                                q.text,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildChat()),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textPrimary,
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pati Dostu',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ONLİNE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearChat,
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF2E9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF5D0B5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _disclaimer,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Colors.orange.shade900.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: _messages.length + (_loading ? 1 : 0),
      itemBuilder: (_, i) {
        if (_loading && i == _messages.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(false),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Pati Dostu yazıyor...',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final msg = _messages[i];
        final time = DateFormat.Hm('tr_TR').format(msg.time);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!msg.isUser) ...[_avatar(false), const SizedBox(width: 8)],
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: msg.isUser ? AppColors.primary : const Color(0xFFF2F4F4),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                          bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                        ),
                      ),
                      child: Text(
                        msg.content,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: msg.isUser ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 4, left: msg.isUser ? 0 : 44, right: msg.isUser ? 4 : 0),
                child: Text(
                  time,
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withValues(alpha: 0.8)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _avatar(bool user) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: user ? AppColors.primary : const Color(0xFFE8EAED),
      child: Icon(
        user ? Icons.person_rounded : Icons.smart_toy_rounded,
        size: 18,
        color: user ? Colors.white : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F4),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _loading ? null : _attachContext,
                    icon: Icon(Icons.attach_file_rounded, color: AppColors.textSecondary.withValues(alpha: 0.85)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      enabled: !_loading,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: const InputDecoration(
                        hintText: 'Bir şeyler yaz...',
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _loading ? null : () => _send(_input.text),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
