import 'dart:math';

import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/ui/widgets/appbar/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RandomNumberScreen extends StatefulWidget {
  const RandomNumberScreen({super.key});

  @override
  State<RandomNumberScreen> createState() => _RandomNumberScreenState();
}

class _RandomNumberScreenState extends State<RandomNumberScreen> {
  int _minValue = 0;
  int _maxValue = 100;
  int? _generatedNumber;
  bool _isGenerating = false;

  void _generateRandomNumber() {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
      _generatedNumber = null;
    });

    HapticFeedback.mediumImpact();

    final random = Random();
    final delay = 300 + random.nextInt(700);

    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        setState(() {
          _generatedNumber =
              _minValue + random.nextInt(_maxValue - _minValue + 1);
          _isGenerating = false;
        });
      }
    });
  }

  void _updateMinValue(int value) {
    setState(() {
      _minValue = value;
      if (_minValue >= _maxValue) {
        _maxValue = _minValue + 1;
      }
    });
  }

  void _updateMaxValue(int value) {
    setState(() {
      _maxValue = value;
      if (_maxValue <= _minValue) {
        _minValue = _maxValue - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = S.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 380;

    return Scaffold(
      appBar: CommonAppBar.standard(
        context: context,
        title: l10n.randomNumberGenerator,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        l10n.selectRange,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isSmallScreen)
                        Column(
                          children: [
                            _CompactNumberSelector(
                              title: l10n.from,
                              value: _minValue,
                              min: -999,
                              max: 999,
                              onChanged: _updateMinValue,
                            ),
                            const SizedBox(height: 16),
                            _CompactNumberSelector(
                              title: l10n.to,
                              value: _maxValue,
                              min: -999,
                              max: 999,
                              onChanged: _updateMaxValue,
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: _CompactNumberSelector(
                                title: l10n.from,
                                value: _minValue,
                                min: -999,
                                max: 999,
                                onChanged: _updateMinValue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _CompactNumberSelector(
                                title: l10n.to,
                                value: _maxValue,
                                min: -999,
                                max: 999,
                                onChanged: _updateMaxValue,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: _isGenerating
                        ? SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimaryContainer,
                              ),
                              strokeWidth: 3,
                            ),
                          )
                        : _generatedNumber != null
                            ? Text(
                                '$_generatedNumber',
                                style: textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: isSmallScreen ? 48 : 56,
                                ),
                              )
                            : Text(
                                '?',
                                style: textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer
                                      .withOpacity(0.3),
                                  fontSize: isSmallScreen ? 48 : 56,
                                ),
                              ),
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    FilledButton(
                      onPressed: _generateRandomNumber,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.casino, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isGenerating
                                ? l10n.generating
                                : l10n.generateNumber,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _minValue = 0;
                          _maxValue = 100;
                          _generatedNumber = null;
                        });
                      },
                      child: Text(l10n.default_settings),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactNumberSelector extends StatefulWidget {
  final String title;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _CompactNumberSelector({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_CompactNumberSelector> createState() => _CompactNumberSelectorState();
}

class _CompactNumberSelectorState extends State<_CompactNumberSelector> {
  late List<int> _items;
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _rebuildItems();
  }

  void _rebuildItems() {
    _items = List.generate(
      widget.max - widget.min + 1,
      (index) => widget.min + index,
    );
    final initialIndex =
        _items.indexOf(widget.value).clamp(0, _items.length - 1);
    _controller = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void didUpdateWidget(_CompactNumberSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.min != widget.min || oldWidget.max != widget.max) {
      _rebuildItems();
    } else if (oldWidget.value != widget.value) {
      final index = _items.indexOf(widget.value);
      if (index >= 0 && index < _items.length) {
        _controller.animateToItem(
          index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showNumberInputDialog() async {
    final TextEditingController textController = TextEditingController(
      text: widget.value.toString(),
    );
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.title),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.numberWithOptions(signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
          ],
          autofocus: true,
          decoration: InputDecoration(
            hintText: widget.value.toString(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(textController.text);
              if (parsed != null &&
                  parsed >= widget.min &&
                  parsed <= widget.max) {
                Navigator.pop(ctx, parsed);
              }
            },
            child: Text(S.of(context).ok),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      widget.onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showNumberInputDialog,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                widget.value.toString(),
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: colorScheme.primary,
                size: 24,
              ),
              onPressed: () {
                if (widget.value > widget.min) {
                  widget.onChanged(widget.value - 1);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.value.toString(),
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(
                Icons.add_circle_outline,
                color: colorScheme.primary,
                size: 24,
              ),
              onPressed: () {
                if (widget.value < widget.max) {
                  widget.onChanged(widget.value + 1);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }
}
