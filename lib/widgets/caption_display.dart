import 'package:flutter/material.dart';
import '../models/caption_model.dart';

class CaptionDisplay extends StatelessWidget {
  final CaptionModel? caption;
  final bool isProcessing;
  final double fontSize;
  final bool isListening;

  const CaptionDisplay({
    super.key,
    this.caption,
    this.isProcessing = false,
    this.fontSize = 18.0,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    print('📺 CaptionDisplay build - Caption: ${caption?.text ?? "null"}, Listening: $isListening, Processing: $isProcessing');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isProcessing)
            const CircularProgressIndicator()
          else if (caption != null)
            Column(
              children: [
                // Main caption text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caption!.text,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Confidence: ${(caption!.confidence * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: caption!.confidence > 0.7 
                                  ? Colors.green 
                                  : caption!.confidence > 0.5 
                                      ? Colors.orange 
                                      : Colors.red,
                            ),
                          ),
                          Text(
                            caption!.timestamp.toString().substring(11, 19),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Icon(
                  isListening ? Icons.mic : Icons.mic_none_outlined,
                  size: 64,
                  color: isListening ? Colors.red : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  isListening 
                      ? 'Listening... Speak now'
                      : 'Tap the microphone to start\nlive captioning',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isListening ? Colors.red : Colors.grey[600],
                  ),
                ),
                if (isListening) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
                const SizedBox(height: 32),
                // R3D watermark
                Opacity(
                  opacity: 0.3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          'R',
                          style: TextStyle(
                            color: Colors.cyan.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '3D',
                        style: TextStyle(
                          color: Colors.cyan.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
