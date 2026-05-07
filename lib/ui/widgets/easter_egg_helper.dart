import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class EasterEggHelper extends StatefulWidget {
  const EasterEggHelper({super.key});

  @override
  State<EasterEggHelper> createState() => _EasterEggHelperState();
}

class _EasterEggHelperState extends State<EasterEggHelper> {
  String _currentMessage = '';
  final List<String> _messages = _buildMessages();
  late Timer _messageTimer;

  static List<String> _buildMessages() {
    return [
      '🎨 Создавай персонажей с помощью гибких шаблонов!',
      '📁 Разложи героев по папкам — в каждой кампании порядок.',
      '🔍 Ищи персонажа по имени, расе или любому полю — мгновенно.',
      '🏷️ Добавляй теги для быстрой фильтрации.',
      '📄 Экспортируй лист персонажа в PDF — удобно для игры.',
      '🖨️ Распечатай лист и возьми с собой за стол.',
      '🌙 Переключи тему на тёмную — играй ночью без бликов.',
      '🌍 Приложение говорит на русском и английском.',
      '📱 Интерфейс адаптируется под телефон и планшет.',
      '⚡ Автосохранение бережёт твои правки.',
      '💾 Всё хранится локально — работай без интернета.',
      '🔄 Сделай резервную копию в один клик.',
      '🎲 Поддерживаются D&D, Pathfinder и любые домашние системы.',
      '🧩 Конструктор шаблонов позволяет создать свою форму персонажа.',
      '🖼️ Добавляй несколько изображений к персонажу.',
      '👥 Управляй NPC и героями партии в одном месте.',
      '🗺️ В планах: совместная работа с игроками.',
      '📦 Импортируй и экспортируй персонажей через JSON.',
      '🛡️ Открытый исходный код — можешь предложить улучшение!',
      '🎭 Спасибо, что пользуешься CharacterBook!',
    ];
  }

  @override
  void initState() {
    super.initState();
    _showRandomMessage();
    _messageTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _showRandomMessage();
    });
  }

  void _showRandomMessage() {
    if (!mounted) return;
    setState(() {
      _currentMessage = _messages[Random().nextInt(_messages.length)];
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _currentMessage = '');
    });
  }

  @override
  void dispose() {
    _messageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (_currentMessage.isNotEmpty)
            Positioned(
              bottom: 160,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Text(
                      _currentMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 16,
            child: GestureDetector(
              onTap: _showRandomMessage,
              child: Image.asset(
                'assets/maxupshur.png',
                height: 200,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
