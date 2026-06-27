import 'package:audioplayers/audioplayers.dart';
import 'package:comchat/models/shop.dart';
import 'package:flutter/material.dart';

class BusinessStatusAdCard extends StatefulWidget {
  final Shop shop;

  const BusinessStatusAdCard({super.key, required this.shop});

  @override
  State<BusinessStatusAdCard> createState() => _BusinessStatusAdCardState();
}

class _BusinessStatusAdCardState extends State<BusinessStatusAdCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    final musicUrl = widget.shop.statusMusicUrl?.trim() ?? '';
    if (!widget.shop.isStatusAdActive || musicUrl.isEmpty) {
      return;
    }

    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
      return;
    }

    await _audioPlayer.play(UrlSource(musicUrl));
    setState(() => _isPlaying = true);
  }

  @override
  Widget build(BuildContext context) {
    final duration = (widget.shop.statusDurationSeconds ?? 30).clamp(30, 60);
    final hasMusic = (widget.shop.statusMusicUrl ?? '').trim().isNotEmpty;
    final statusText = widget.shop.statusText?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'Weekly special preview',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.shop.isStatusAdActive && statusText.isNotEmpty
                ? statusText
                : 'No weekly special yet. Businesses can publish a short promo here.',
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                '${duration}s',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.music_note, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                hasMusic ? 'Background music' : 'No music added',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.shop.isStatusAdActive)
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _togglePlayback,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(_isPlaying ? 'Pause special' : 'Preview special'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
