import 'package:flutter/material.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../../wardrobe/domain/item_group.dart';
import '../../../wardrobe/domain/item_type.dart';
import '../../domain/extracted_item.dart';
import '../../domain/last_worn.dart';
import '../studio_state.dart';

/// Attribute fields a user can retype in review (AC-03.6).
enum ReviewTextField { color, material, style }

/// Screen 4a "Review Pieces", spec T7 › G3: the AI proposes, the user
/// corrects, then one tap indexes every Piece.
class ReviewPanel extends StatelessWidget {
  final StudioState state;
  final DateTime today;
  final ValueChanged<int> onExpand;
  final void Function(int index, String typeCode) onTypeChanged;
  final void Function(int index, ReviewTextField field, String value)
      onTextChanged;
  final void Function(int index, LastWornInput lastWorn) onLastWornChanged;
  final VoidCallback onSave;
  final VoidCallback onStartOver;

  const ReviewPanel({
    super.key,
    required this.state,
    required this.today,
    required this.onExpand,
    required this.onTypeChanged,
    required this.onTextChanged,
    required this.onLastWornChanged,
    required this.onSave,
    required this.onStartOver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final review = state.review!;
    final items = review.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text('Review Pieces', style: theme.textTheme.titleLarge),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Banner(
                  text: review.bannerText,
                  note: review.failureNote,
                ),
                const SizedBox(height: 16),
                if (items.isEmpty) ...[
                  Text(
                    "We couldn't find clothes in these photos.",
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: onStartOver,
                    child: const Text('Add other photos'),
                  ),
                ] else ...[
                  _ExpandedPiece(
                    item: items[state.expandedIndex],
                    position: state.expandedIndex + 1,
                    count: items.length,
                    onTypeTap: () => _pickType(context),
                    onTextTap: (field) => _pickText(context, field),
                    onLastWornTap: () => _pickLastWorn(context),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < items.length; i++)
                    if (i != state.expandedIndex)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            'PIECE ${i + 1}/${items.length} · '
                            '${items[i].confidencePercent}% CONFIDENCE · '
                            '${items[i].name}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => onExpand(i),
                        ),
                      ),
                ],
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onSave,
                      child: const Text('Try again'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: PrimaryButton(
            label: state.saveLabel,
            loading: state.isSaving,
            onPressed: state.canSave ? onSave : null,
          ),
        ),
      ],
    );
  }

  int get _index => state.expandedIndex;
  ExtractedItem get _item => state.review!.items[_index];

  Future<void> _pickType(BuildContext context) async {
    final code = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final group in ItemGroup.values) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    group.label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                for (final type in ItemTypeCatalog.typesIn(group))
                  ListTile(
                    title: Text(type.label),
                    selected: type.code == _item.value.typeCode,
                    onTap: () => Navigator.of(context).pop(type.code),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
    if (code != null) onTypeChanged(_index, code);
  }

  Future<void> _pickText(BuildContext context, ReviewTextField field) async {
    final (title, aiValue, current) = switch (field) {
      ReviewTextField.color => ('Colour', _item.ai.color, _item.value.color),
      ReviewTextField.material => (
          'Material',
          _item.ai.material,
          _item.value.material
        ),
      ReviewTextField.style => (
          'Style',
          _item.ai.styleTag,
          _item.value.styleTag
        ),
    };
    final controller = TextEditingController(text: current);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GARBLO SUGGESTS · $aiValue',
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            TextField(controller: controller, autofocus: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(aiValue),
            child: const Text('Use suggestion'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && value.isNotEmpty) onTextChanged(_index, field, value);
  }

  Future<void> _pickLastWorn(BuildContext context) async {
    final option = await showModalBottomSheet<LastWornOption>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in LastWornOption.values)
              ListTile(
                title: Text(option.label),
                selected: option == _item.lastWorn.option,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (option == null || !context.mounted) return;
    if (option != LastWornOption.exactDate) {
      onLastWornChanged(_index, LastWornInput(option));
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(today.year - 10),
      lastDate: today,
    );
    if (date != null) {
      onLastWornChanged(
        _index,
        LastWornInput(LastWornOption.exactDate, exactDate: date),
      );
    }
  }
}

class _Banner extends StatelessWidget {
  final String text;
  final String? note;

  const _Banner({required this.text, this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text('Check before indexing', style: theme.textTheme.bodyMedium),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(
              note!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpandedPiece extends StatelessWidget {
  final ExtractedItem item;
  final int position;
  final int count;
  final VoidCallback onTypeTap;
  final ValueChanged<ReviewTextField> onTextTap;
  final VoidCallback onLastWornTap;

  const _ExpandedPiece({
    required this.item,
    required this.position,
    required this.count,
    required this.onTypeTap,
    required this.onTextTap,
    required this.onLastWornTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = ItemTypeCatalog.byCode(item.value.typeCode)?.label ??
        item.value.typeCode;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 160,
            color: theme.colorScheme.surfaceContainer,
            child: Icon(
              Icons.checkroom_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('PIECE $position/$count',
                        style: theme.textTheme.labelSmall),
                    const SizedBox(width: 8),
                    Text('${item.confidencePercent}% CONFIDENCE',
                        style: theme.textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.name, style: theme.textTheme.headlineSmall),
              ],
            ),
          ),
          _AttributeRow(label: 'Type', value: typeLabel, onTap: onTypeTap),
          _AttributeRow(
            label: 'Colour',
            value: item.value.color,
            onTap: () => onTextTap(ReviewTextField.color),
          ),
          _AttributeRow(
            label: 'Material',
            value: item.value.material,
            onTap: () => onTextTap(ReviewTextField.material),
          ),
          _AttributeRow(
            label: 'Style',
            value: item.value.styleTag,
            onTap: () => onTextTap(ReviewTextField.style),
          ),
          _AttributeRow(
            label: 'Last worn',
            value: item.lastWorn.label,
            onTap: onLastWornTap,
          ),
        ],
      ),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _AttributeRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(label, style: theme.textTheme.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: theme.textTheme.bodyMedium),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}
