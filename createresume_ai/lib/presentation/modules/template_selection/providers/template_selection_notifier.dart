import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplateSelectionState {
  final String? selectedCategory;
  final String? selectedStyle;

  const TemplateSelectionState({
    this.selectedCategory,
    this.selectedStyle,
  });

  TemplateSelectionState copyWith({
    String? selectedCategory,
    String? selectedStyle,
  }) {
    return TemplateSelectionState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedStyle: selectedStyle ?? this.selectedStyle,
    );
  }
}

class TemplateSelectionNotifier extends Notifier<TemplateSelectionState> {
  @override
  TemplateSelectionState build() {
    return const TemplateSelectionState();
  }

  void selectCategory(String? category) {
    state = state.copyWith(selectedCategory: category, selectedStyle: null);
  }

  void selectStyle(String style) {
    state = state.copyWith(selectedStyle: style);
  }
}

final templateSelectionProvider =
    NotifierProvider<TemplateSelectionNotifier, TemplateSelectionState>(
  TemplateSelectionNotifier.new,
);
