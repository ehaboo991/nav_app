import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Color _cyberTeal = Color(0xFF03303B);
const Color _aquaFoam = Color(0xFF96FCDF);


const String _systemPrompt =
    'أنت NAV AI، مساعد ذكي داخل تطبيق Mutah-Nav لجامعة مؤتة في الأردن. '
    'ساعد الطلاب في إيجاد الكليات والقاعات والمباني وتوجيههم داخل الحرم الجامعي. '
    'جاوب بلهجة بسيطة وواضحة ومختصرة.';

class _Msg {
  final String text;
  final bool user;
  const _Msg(this.text, this.user);
}

class NavAiScreen extends StatefulWidget {
  final bool embedded;
  const NavAiScreen({super.key, this.embedded = false});

  @override
  State<NavAiScreen> createState() => _NavAiScreenState();
}

class _NavAiScreenState extends State<NavAiScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [
    const _Msg(
        'أهلاً! أنا NAV AI 👋\nاسألني عن أي كلية أو قاعة أو مبنى بالجامعة.',
        false),
  ];
  bool _loading = false;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? const Color(0xFF01181E) : const Color(0xFFF2FFFB);
  Color get _surface => _dark ? const Color(0xFF042A33) : Colors.white;
  Color get _title => _dark ? _aquaFoam : _cyberTeal;
  Color get _border => _dark ? _aquaFoam.withAlpha(45) : _aquaFoam;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _msgs.add(_Msg(text, true));
      _loading = true;
      _ctrl.clear();
    });
    _scrollDown();

    String reply;
    try {
      if (_apiKey.isEmpty) {
        reply = 'ما في API key.';
      } else {
        final List<Map<String, String>> messages = [
          {'role': 'system', 'content': _systemPrompt}
        ];

        final history = _msgs.skip(1).toList();
        final recent = history.length > 10
            ? history.sublist(history.length - 10)
            : history;

        for (final m in recent) {
          messages.add({
            'role': m.user ? 'user' : 'assistant',
            'content': m.text,
          });
        }

        final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

        final res = await http
            .post(
              url,
              headers: {
                'content-type': 'application/json',
                'Authorization': 'Bearer $_apiKey',
              },
              body: jsonEncode({
                'model': _model,
                'messages': messages,
                'temperature': 0.7,
              }),
            )
            .timeout(const Duration(seconds: 30));

        final data = jsonDecode(utf8.decode(res.bodyBytes));
        
        if (res.statusCode == 200) {
          if (data['choices'] != null && data['choices'].isNotEmpty) {
            reply = data['choices'][0]['message']['content'];
          } else {
            reply = 'استقبلنا رد فارغ من الخادم.';
          }
        } else {
          reply = 'خطأ (${res.statusCode}): ${data['error']?['message'] ?? data.toString()}';
        }
      }
    } catch (e) {
      print('API Exception: $e');
      reply = 'حدث استثناء برمجي: $e';
    }

    if (!mounted) return;
    setState(() {
      _msgs.add(_Msg(reply, false));
      _loading = false;
    });
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    final chat = Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _msgs.length + (_loading ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _msgs.length) return _bubble('...', false);
              return _bubble(_msgs[i].text, _msgs[i].user);
            },
          ),
        ),
        SafeArea(
          top: false,
          bottom: !widget.embedded,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: TextStyle(color: _title),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'اسأل NAV AI...',
                      hintStyle: TextStyle(color: _title.withAlpha(150)),
                      filled: true,
                      fillColor: _surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: BorderSide(color: _title, width: 1.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: _dark ? _aquaFoam : _cyberTeal,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _send,
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Icon(Icons.send_rounded,
                          size: 22, color: _dark ? _cyberTeal : _aquaFoam),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: ColoredBox(
          color: _bg,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  color: _dark ? const Color(0xFF021F26) : _cyberTeal,
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: _aquaFoam, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'NAV AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: chat),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _dark ? const Color(0xFF021F26) : _cyberTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: _aquaFoam, size: 22),
              SizedBox(width: 8),
              Text('NAV AI', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        body: chat,
      ),
    );
  }

  Widget _bubble(String text, bool user) {
    final bg = user ? (_dark ? _aquaFoam : _cyberTeal) : _surface;
    final fg = user ? (_dark ? _cyberTeal : Colors.white) : _title;
    return Align(
      alignment: user
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: user ? null : Border.all(color: _border),
        ),
        child: SelectableText(text,
            style: TextStyle(color: fg, fontSize: 14.5, height: 1.45)),
      ),
    );
  }
}