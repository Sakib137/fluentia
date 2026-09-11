import 'package:flutter/material.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/models/speech_recognition_state.dart';

/// Premium, accessible microphone interaction button with subtle state feedback.
class MicrophoneButton extends StatefulWidget {
  const MicrophoneButton({
    super.key,
    required this.state,
    required this.onTap,
    this.soundLevel = 0.0,
    this.size = 72.0,
  });

  final SpeechRecordingState state;
  final VoidCallback onTap;
  final double soundLevel;
  final double size;

  @override
  State<MicrophoneButton> createState() => _MicrophoneButtonState();
}

class _MicrophoneButtonState extends State<MicrophoneButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.state.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MicrophoneButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.isListening && !oldWidget.state.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.state.isListening && oldWidget.state.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isListening = widget.state.isListening;
    final isProcessing = widget.state.isProcessing;

    final baseColor = isListening
        ? AppColors.error500
        : (widget.state.isError || widget.state.isPermissionDenied)
        ? AppColors.slate500
        : (isDark ? AppColors.primary500 : AppColors.primary600);

    final semanticLabel = switch (widget.state) {
      SpeechRecordingState.listening => 'Stop recording speech',
      SpeechRecordingState.processing => 'Analyzing speech transcript',
      SpeechRecordingState.idle => 'Start recording speech',
      SpeechRecordingState.preparing => 'Preparing microphone',
      SpeechRecordingState.permissionDenied => 'Microphone access denied',
      SpeechRecordingState.unavailable => 'Speech recognition unavailable',
      _ => 'Microphone button',
    };

    return Semantics(
      button: true,
      enabled: !isProcessing,
      label: semanticLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = isListening ? _pulseAnimation.value : 1.0;
              final glowSpread = isListening ? (widget.soundLevel * 12.0) : 0.0;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: baseColor,
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withValues(
                          alpha: isListening ? 0.35 : 0.2,
                        ),
                        blurRadius: 16.0 + glowSpread,
                        spreadRadius: 2.0 + (glowSpread / 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isProcessing ? null : widget.onTap,
                      customBorder: const CircleBorder(),
                      splashColor: Colors.white24,
                      child: Center(
                        child: isProcessing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Icon(
                                isListening
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                                color: Colors.white,
                                size: widget.size * 0.48,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          // Descriptive text below button
          Text(
            switch (widget.state) {
              SpeechRecordingState.listening => 'Tap to stop recording',
              SpeechRecordingState.processing => 'Analyzing your speech...',
              SpeechRecordingState.idle => 'Tap to speak',
              SpeechRecordingState.preparing => 'Get ready...',
              SpeechRecordingState.permissionDenied =>
                'Microphone access required',
              SpeechRecordingState.unavailable => 'Recognition unavailable',
              _ => 'Tap to speak',
            },
            style: TextStyle(
              fontSize: AppFontSizes.bodySmall,
              fontWeight: AppFontWeights.medium,
              color: isListening
                  ? (isDark ? AppColors.error400 : AppColors.error600)
                  : (isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
