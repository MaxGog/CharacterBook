import 'package:characterbook/generated/l10n.dart';
import 'package:characterbook/services/file_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

mixin ListPageMixin<T extends StatefulWidget> on State<T> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FilePickerService filePickerService = FilePickerService();

  bool isSearching = false;
  bool isImporting = false;
  bool isFabVisible = true;
  bool isTagsVisible = true;
  bool isGroupByTagMode = false;
  String? errorMessage;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_handleScroll);
    searchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (scrollController.position.atEdge) {
      final isTop = scrollController.position.pixels == 0;
      if (isTop) {
        _showControls();
      }
      return;
    }

    final direction = scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      _hideControls();
    } else if (direction == ScrollDirection.forward) {
      _showControls();
    }
  }

  void toggleGroupByTagMode() {
    setState(() {
      isGroupByTagMode = !isGroupByTagMode;
    });
  }

  void _showControls() {
    if (!isFabVisible) setState(() => isFabVisible = true);
    if (!isTagsVisible) setState(() => isTagsVisible = true);
  }

  void _hideControls() {
    if (isFabVisible) setState(() => isFabVisible = false);
    if (isTagsVisible) setState(() => isTagsVisible = false);
  }

  Widget animatedFAB(Widget fab, {required Key key}) {
    return AnimatedSwitcher(
      duration: animationDuration,
      switchInCurve: animationCurve,
      switchOutCurve: animationCurve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: isFabVisible
          ? SizedBox(key: key, child: fab)
          : const SizedBox.shrink(key: ValueKey('fab_hidden')),
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<bool> showDeleteConfirmationDialog(
      String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
