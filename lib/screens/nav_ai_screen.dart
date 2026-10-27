  
// Used for JSON encoding/decoding the API payload.
// import 'dart:convert';
import 'package:flutter/material.dart';
// HTTP client used to call the Groq chat completions endpoint.
// import 'package:http/http.dart' as http;

// Dark teal used as the primary brand color in light mode.
const Color _cyberTeal = Color(0xFF03303B);
// Mint accent used for text/borders in dark mode.
const Color _aquaFoam = Color(0xFF96FCDF);


// Instructions sent as the "system" message to keep NAV AI on topic:
// helping students locate colleges, halls and buildings at Mutah University.
const String _systemPrompt =
    'أنت NAV AI، مساعد ذكي داخل تطبيق Mutah-Nav لجامعة مؤتة في الأردن. '
    'ساعد الطلاب في إيجاد الكليات والقاعات والمباني وتوجيههم داخل الحرم الجامعي. '
    'جاوب بلهجة بسيطة وواضحة ومختصرة.';

// A single chat message; `user` is true for messages sent by the student.
class _Msg {
  final String text;
  final bool user;
  const _Msg(this.text, this.user);
}

// NAV AI chat screen. Set `embedded` to true to render it inside another
// screen (header + chat only) instead of a standalone Scaffold with an AppBar.
class NavAiScreen extends StatefulWidget {
  final bool embedded;
  const NavAiScreen({super.key, this.embedded = false});

  @override
  State<NavAiScreen> createState() => _NavAiScreenState();
}

class _NavAiScreenState extends State<NavAiScreen> {
  // Controller for the message input field.
  final _ctrl = TextEditingController();
  // Controller used to keep the list scrolled to the newest message.
  final _scroll = ScrollController();
  // Conversation history, starting with the bot's welcome message.
  final List<_Msg> _msgs = [
    const _Msg(
        'أهلاً! أنا NAV AI 👋\nاسألني عن أي كلية أو قاعة أو مبنى بالجامعة.',
        false),
  ];
  // True while waiting for the API response (shows the "..." bubble).
  bool _loading = false;

  // Theme helpers: pick colors based on the current light/dark mode.
  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? const Color(0xFF01181E) : const Color(0xFFF2FFFB);
  Color get _surface => _dark ? const Color(0xFF042A33) : Colors.white;
  Color get _title => _dark ? _aquaFoam : _cyberTeal;
  Color get _border => _dark ? _aquaFoam.withAlpha(45) : _aquaFoam;

  @override
  void dispose() {
    // Release both controllers to avoid memory leaks.
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // Scroll to the bottom after the next frame so new messages are visible.
  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  // Adds the user's message, calls the API, then appends the bot's reply.
  Future<void> _send() async {
    final text = _ctrl.text.trim();
    // Ignore empty messages and prevent double-sending while loading.
    if (text.isEmpty || _loading) return;

    setState(() {
      _msgs.add(_Msg(text, true));
      _loading = true;
      _ctrl.clear();
    });
    _scrollDown();

    String reply;
    try {
      // Guard against a missing API key instead of making a doomed request.
      // Disabled for now: API key check and request are commented out.
      // if (_apiKey.isEmpty) {
      //   reply = 'ما في API key.';
      // } else {
      //   // Start the payload with the system prompt.
      //   final List<Map<String, String>> messages = [
      //     {'role': 'system', 'content': _systemPrompt}
      //   ];
      //
      //   // Skip index 0 (welcome message) and send only the last 10 messages
      //   // to keep the request small and within the model's context window.
      //   final history = _msgs.skip(1).toList();
      //   final recent = history.length > 10
      //       ? history.sublist(history.length - 10)
      //       : history;
      //
      //   for (final m in recent) {
      //     messages.add({
      //       'role': m.user ? 'user' : 'assistant',
      //       'content': m.text,
      //     });
      //   }
      //
      //   // Groq exposes an OpenAI-compatible chat completions endpoint.
      //   final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      //
      //   // Send the conversation and give up after 30 seconds.
      //   final res = await http
      //       .post(
      //         url,
      //         headers: {
      //           'content-type': 'application/json',
      //           'Authorization': 'Bearer $_apiKey',
      //         },
      //         body: jsonEncode({
      //           'model': _model,
      //           'messages': messages,
      //           'temperature': 0.7,
      //         }),
      //       )
      //       .timeout(const Duration(seconds: 30));
      //
      //   // Decode bytes as UTF-8 so the Arabic text is not garbled.
      //   final data = jsonDecode(utf8.decode(res.bodyBytes));
      //
      //   if (res.statusCode == 200) {
      //     // Read the content of the first choice when it exists.
      //     if (data['choices'] != null && data['choices'].isNotEmpty) {
      //       reply = data['choices'][0]['message']['content'];
      //     } else {
      //       reply = 'استقبلنا رد فارغ من الخادم.';
      //     }
      //   } else {
      //     // Show the API error message (or raw body) to the user.
      //     reply = 'خطأ (${res.statusCode}): ${data['error']?['message'] ?? data.toString()}';
      //   }
      // }
      reply = 'NAV AI غير متاح حالياً.';
    } catch (e) {
      // Network errors, timeouts and JSON parse failures all land here.
      print('API Exception: $e');
      reply = 'حدث استثناء برمجي: $e';
    }

    // The widget may have been disposed while the request was in flight.
    if (!mounted) return;
    setState(() {
      _msgs.add(_Msg(reply, false));
      _loading = false;
    });
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    // Shared chat layout: message list + input row, used by both modes.
    final chat = Column(
      children: [
        // Message list; while loading, one extra bubble shows the typing dots.
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
          // Skip the bottom inset when embedded; the host screen handles it.
          bottom: !widget.embedded,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(
              children: [
                // Multiline input: grows up to 4 lines, submits with the
                // keyboard's send action.
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
                // Circular send button.
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

    // Embedded mode: no Scaffold/AppBar, just a compact header above the chat.
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

    // Standalone mode: full screen with an AppBar titled "NAV AI".
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

  // Builds a chat bubble. User bubbles are filled and aligned to the start
  // (right in RTL); bot bubbles are outlined and aligned to the end.
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
        // A bubble never takes more than 78% of the screen width.
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
   
  