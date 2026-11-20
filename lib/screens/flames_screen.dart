import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../flames/flames.dart';
import '../theme/love_colors.dart';
import '../widgets/love_background.dart';

class FlamesScreen extends StatefulWidget {
  const FlamesScreen({super.key});

  @override
  State<FlamesScreen> createState() => _FlamesScreenState();
}

class _FlamesScreenState extends State<FlamesScreen> {
  final _herController = TextEditingController();
  final _hisController = TextEditingController();
  final _herFocus = FocusNode();
  final _hisFocus = FocusNode();

  FlamesResult? _result;
  String _hint = 'Enter two names and discover your fate.';
  bool _hintIsError = false;

  @override
  void dispose() {
    _herController.dispose();
    _hisController.dispose();
    _herFocus.dispose();
    _hisFocus.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = Flames.calculate(_herController.text, _hisController.text);
    setState(() {
      if (result.isEmpty) {
        _result = null;
        _hint = result.description.isEmpty
            ? 'Please enter both names.'
            : result.description;
        _hintIsError = true;
      } else {
        _result = result;
        _hint = '${result.herName}  ×  ${result.hisName}';
        _hintIsError = false;
      }
    });
    if (!result.isEmpty) {
      HapticFeedback.selectionClick();
    }
  }

  void _clear() {
    _herController.clear();
    _hisController.clear();
    setState(() {
      _result = null;
      _hint = 'Enter two names and discover your fate.';
      _hintIsError = false;
    });
    _herFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return LoveBackground(
      child: Scaffold(
        appBar: AppBar(title: const Text('FLAMES')),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Type two names. Fate does the rest.',
                      style: TextStyle(fontSize: 15, color: LoveColors.muted),
                    ),
                    const SizedBox(height: 14),
                    const _Legend(),
                    const SizedBox(height: 18),
                    _NameCard(
                      herController: _herController,
                      hisController: _hisController,
                      herFocus: _herFocus,
                      hisFocus: _hisFocus,
                      onSubmitHer: () => _hisFocus.requestFocus(),
                      onCalculate: _calculate,
                      onClear: _clear,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _hint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: _hintIsError
                            ? LoveColors.danger
                            : LoveColors.muted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      child: _result == null
                          ? const SizedBox.shrink(key: ValueKey('empty'))
                          : _ResultCard(
                              key: ValueKey(
                                '${_result!.herName}|${_result!.hisName}|${_result!.letter}',
                              ),
                              result: _result!,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final outcome in Flames.outcomes)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                '${outcome.letter} ${outcome.label}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: LoveColors.muted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NameCard extends StatelessWidget {
  const _NameCard({
    required this.herController,
    required this.hisController,
    required this.herFocus,
    required this.hisFocus,
    required this.onSubmitHer,
    required this.onCalculate,
    required this.onClear,
  });

  final TextEditingController herController;
  final TextEditingController hisController;
  final FocusNode herFocus;
  final FocusNode hisFocus;
  final VoidCallback onSubmitHer;
  final VoidCallback onCalculate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: LoveColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _FieldLabel(
              icon: Icons.favorite_rounded,
              color: LoveColors.heart,
              text: 'Her name',
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('her-name'),
              controller: herController,
              focusNode: herFocus,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(hintText: 'e.g. Nayanthara'),
              onSubmitted: (_) => onSubmitHer(),
            ),
            const SizedBox(height: 16),
            const _FieldLabel(
              icon: Icons.person_rounded,
              color: LoveColors.primary,
              text: 'His name',
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('his-name'),
              controller: hisController,
              focusNode: hisFocus,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(hintText: 'e.g. Vignesh'),
              onSubmitted: (_) => onCalculate(),
            ),
            const SizedBox(height: 18),
            FilledButton(
              key: const Key('calculate'),
              onPressed: onCalculate,
              child: const Text('Calculate'),
            ),
            Center(
              child: TextButton(
                key: const Key('clear'),
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({super.key, required this.result});

  final FlamesResult result;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F3FF), Color(0xFFFDF2F8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LoveColors.resultBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final outcome in Flames.outcomes)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _LetterDot(
                      letter: outcome.letter,
                      selected: outcome.letter == result.letter,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              result.letter,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: LoveColors.primary,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              result.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: LoveColors.muted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterDot extends StatelessWidget {
  const _LetterDot({required this.letter, required this.selected});

  final String letter;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: selected ? 36 : 28,
      height: selected ? 36 : 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? LoveColors.primary : const Color(0xFFF3F0FF),
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: selected ? 14 : 12,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : LoveColors.muted,
        ),
      ),
    );
  }
}
