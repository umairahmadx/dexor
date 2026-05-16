import 'package:flutter/material.dart';

import '../../../core/widgets/shared_widgets.dart';

class UnixTimestampScreen extends StatefulWidget {
  const UnixTimestampScreen({super.key});

  @override
  State<UnixTimestampScreen> createState() => _UnixTimestampScreenState();
}

class _UnixTimestampScreenState extends State<UnixTimestampScreen> {
  String _timestamp = '';
  DateTime? _parsedDateTime;

  @override
  void initState() {
    super.initState();
    _useCurrentTime();
  }

  void _parseTimestamp(String input) {
    try {
      final parsed = int.parse(input.trim());
      final date = DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
      setState(() {
        _timestamp = input;
        _parsedDateTime = date;
      });
    } catch (e) {
      setState(() {
        _timestamp = input;
        _parsedDateTime = null;
      });
    }
  }

  void _useCurrentTime() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _parseTimestamp(now.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unix Timestamp'),
        actions: [
          if (_timestamp.isNotEmpty)
            CopyButton(text: _timestamp, label: 'Copy'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current time button
          FilledButton.icon(
            onPressed: _useCurrentTime,
            icon: const Icon(Icons.schedule),
            label: const Text('Current Time'),
          ),
          const SizedBox(height: 16),

          // Timestamp input
          TextField(
            onChanged: _parseTimestamp,
            decoration: InputDecoration(
              labelText: 'Unix Timestamp (seconds)',
              hintText: '1640995200',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: _timestamp),
          ),
          const SizedBox(height: 16),

          if (_parsedDateTime != null) ...[
            _TimestampBit(label: 'Date (ISO)', value: _parsedDateTime!.toIso8601String()),
            _TimestampBit(
              label: 'Date (Local)',
              value: _parsedDateTime!.toString(),
            ),
            _TimestampBit(
              label: 'Year',
              value: _parsedDateTime!.year.toString(),
            ),
            _TimestampBit(
              label: 'Month',
              value: '${_parsedDateTime!.month} (${_getMonthName(_parsedDateTime!.month)})',
            ),
            _TimestampBit(
              label: 'Day',
              value: _parsedDateTime!.day.toString(),
            ),
            _TimestampBit(
              label: 'Weekday',
              value: _getWeekday(_parsedDateTime!.weekday),
            ),
            _TimestampBit(
              label: 'Hour',
              value: _parsedDateTime!.hour.toString().padLeft(2, '0'),
            ),
            _TimestampBit(
              label: 'Minute',
              value: _parsedDateTime!.minute.toString().padLeft(2, '0'),
            ),
            _TimestampBit(
              label: 'Second',
              value: _parsedDateTime!.second.toString().padLeft(2, '0'),
            ),
            const SizedBox(height: 16),
            Text('Other Formats', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _TimestampBit(
              label: 'Milliseconds',
              value: _parsedDateTime!.millisecondsSinceEpoch.toString(),
            ),
            _TimestampBit(
              label: 'Microseconds',
              value: _parsedDateTime!.microsecondsSinceEpoch.toString(),
            ),
          ] else if (_timestamp.isNotEmpty)
            Center(
              child: Text('Invalid timestamp', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red)),
            )
          else
            Center(
              child: Text('Enter a Unix timestamp to convert', style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getWeekday(int day) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[day - 1];
  }
}

class _TimestampBit extends StatelessWidget {
  const _TimestampBit({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
            ],
          ),
        ),
      ),
    );
  }
}

