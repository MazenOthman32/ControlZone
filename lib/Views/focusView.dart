import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FocusView extends StatefulWidget {
  final void Function(bool)? onLockChange;

  const FocusView({super.key, this.onLockChange});

  @override
  State<FocusView> createState() => _FocusViewState();
}

class _FocusViewState extends State<FocusView> with WidgetsBindingObserver {
  bool _isInFocusMode = false;
  bool _canExit = true;
  Duration _focusDuration = Duration.zero;
  Timer? _timer;
  int _remainingSeconds = 0;
  final TextEditingController _controller = TextEditingController();

  static const platform = MethodChannel('focus_app');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _timer?.cancel();
    _controller.dispose();

    super.dispose();
  }

  @override
  void _startFocusTimer() {
    widget.onLockChange?.call(true);

    // Cancel any existing timer
    _timer?.cancel();

    // Set initial state for the timer
    _canExit = false;
    _remainingSeconds = _focusDuration.inSeconds;

    // Start the timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          // Timer finished, allow exiting focus mode
          _canExit = true;
          _timer?.cancel();
          widget.onLockChange?.call(false);
        }
      });
    });
  }

  void _toggleFocusMode() {
    if (_isInFocusMode && !_canExit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can't exit focus mode until the timer ends."),
        ),
      );
      return;
    }

    setState(() {
      _isInFocusMode = !_isInFocusMode;
    });

    if (_isInFocusMode) {
      final minutes = int.tryParse(_controller.text);
      if (minutes == null || minutes <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid focus time in minutes."),
          ),
        );
        setState(() {
          _isInFocusMode = false;
        });
        return;
      }
      _focusDuration = Duration(minutes: minutes);
      _startFocusTimer();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} remaining';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isInFocusMode || _canExit,
      child: Scaffold(
        backgroundColor: _isInFocusMode ? Colors.black : Colors.white,
        appBar:
            _isInFocusMode
                ? null
                : AppBar(
                  centerTitle: true,
                  title: const Text(
                    'Focus Mode App',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.teal,
                ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isInFocusMode ? Icons.visibility_off : Icons.visibility,
                  size: 100,
                  color: _isInFocusMode ? Colors.white : Colors.teal,
                ),
                const SizedBox(height: 30),
                Text(
                  _isInFocusMode ? 'Focus Mode Enabled' : 'Focus Mode Disabled',
                  style: TextStyle(
                    fontSize: 24,
                    color: _isInFocusMode ? Colors.white : Colors.black,
                  ),
                ),
                if (_isInFocusMode && !_canExit) ...[
                  const SizedBox(height: 20),
                  Text(
                    _formatDuration(_remainingSeconds),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
                if (!_isInFocusMode) ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Focus Time (minutes)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _toggleFocusMode,
                  icon: Icon(
                    color: Colors.black,
                    _isInFocusMode ? Icons.fullscreen_exit : Icons.fullscreen,
                  ),
                  label: Text(
                    _isInFocusMode ? 'Exit Focus Mode' : 'Enter Focus Mode',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                if (_isInFocusMode && !_canExit) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "You can't exit until the timer ends.",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
