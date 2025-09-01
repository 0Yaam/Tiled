import 'package:flutter/material.dart';

class Portrait {
  final String asset;
  final Rect? src;   
  final Size size;    
  const Portrait({required this.asset, this.src, this.size = const Size(64, 64)});
}

class DialogueLine {
  final String text;
  final Portrait? speaker;
  const DialogueLine(this.text, {this.speaker});
}

class DialogueChoice {
  final String text;
  final List<DialogueLine>? nextLines;
  final VoidCallback? onSelected;
  const DialogueChoice(this.text, {this.nextLines, this.onSelected});
}

class DialogManager {
  final ValueNotifier<String> currentText = ValueNotifier<String>('');
  final ValueNotifier<List<DialogueChoice>> currentChoices =
      ValueNotifier<List<DialogueChoice>>(<DialogueChoice>[]);
  final ValueNotifier<Portrait?> currentPortrait = ValueNotifier<Portrait?>(null);
  final ValueNotifier<Portrait?> currentRightPortrait = ValueNotifier<Portrait?>(null);
  VoidCallback? onRequestOpenOverlay;
  VoidCallback? onRequestCloseOverlay;

  bool get isOpen => _isOpen;
  bool _isOpen = false;
  void show({
    required String text,
    Portrait? portrait,
    List<DialogueChoice> choices = const [],
    Portrait? rightPortrait,
  }) {
    currentText.value = text;
    currentChoices.value = choices;
    currentPortrait.value = portrait ?? currentPortrait.value;
    currentRightPortrait.value = rightPortrait;

    if (!_isOpen) {
      _isOpen = true;
      onRequestOpenOverlay?.call();
    }
  }
  void startLinear(List<DialogueLine> lines) {
    if (lines.isEmpty) return;
    _linear = List<DialogueLine>.from(lines);
    _cursor = 0;
    _showCurrentLinear();
  }
  void setPortraits({Portrait? left, Portrait? right}) {
    if (left != null) currentPortrait.value = left;
    if (right != null) currentRightPortrait.value = right;
  }

  /// Đóng overlay
  void close() {
    if (!_isOpen) return;
    _linear = null;
    _cursor = -1;
    currentChoices.value = const [];
    _isOpen = false;
    onRequestCloseOverlay?.call();
  }

  // ========== DÒNG TUYẾN TÍNH ==========

  List<DialogueLine>? _linear;
  int _cursor = -1;

  void _showCurrentLinear() {
    if (_linear == null || _cursor < 0 || _cursor >= _linear!.length) {
      close();
      return;
    }
    final line = _linear![_cursor];
    currentText.value = line.text;
    if (line.speaker != null) currentPortrait.value = line.speaker;
    currentChoices.value = const [];  

    if (!_isOpen) {
      _isOpen = true;
      onRequestOpenOverlay?.call();
    }
  }

  void advance() {
    if (currentChoices.value.isNotEmpty) return; 
    if (_linear == null) {
      close();
      return;
    }
    _cursor++;
    if (_cursor >= _linear!.length) {
      close();
    } else {
      _showCurrentLinear();
    }
  }

  void choose(int index) {
    final list = currentChoices.value;
    if (index < 0 || index >= list.length) return;
    final c = list[index];
    if (c.nextLines != null && c.nextLines!.isNotEmpty) {
      startLinear(c.nextLines!);
      return;
    }

    //chạy callback
    if (c.onSelected != null) {
      c.onSelected!.call();
      return;
    }
    close();
  }
}
