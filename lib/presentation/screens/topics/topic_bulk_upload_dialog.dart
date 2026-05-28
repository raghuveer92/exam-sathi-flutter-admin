import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'template_downloader.dart';

const _bulkTopicTemplate = '''title,description,estimatedHours,difficultyLevel,orderIndex,isActive
Number Systems,Integers and divisibility,2.5,EASY,1,true
Profit and Loss,Basic percentage applications,3,HARD,2,true
''';

Future<List<Map<String, dynamic>>?> showTopicBulkUploadDialog({
  required BuildContext context,
  required int chapterId,
  required int startingOrderIndex,
}) {
  final contentCtrl = TextEditingController();

  return showDialog<List<Map<String, dynamic>>>(
    context: context,
    builder: (dialogContext) {
      String? statusMessage;
      bool isError = false;
      String? fileName;
      List<Map<String, dynamic>>? previewTopics;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickFile() async {
            try {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: const ['csv', 'json', 'txt'],
                withData: true,
              );
              if (result == null || result.files.isEmpty) {
                return;
              }
              final file = result.files.single;
              final bytes = file.bytes;
              if (bytes == null) {
                throw const FormatException(
                  'The selected file could not be read. Try a smaller file.',
                );
              }
              contentCtrl.text = utf8.decode(bytes);
              setDialogState(() {
                fileName = file.name;
                previewTopics = null;
                isError = false;
                statusMessage = 'Loaded ${file.name}';
              });
            } catch (error) {
              setDialogState(() {
                isError = true;
                statusMessage = error.toString();
              });
            }
          }

          return AlertDialog(
            title: const Text('Bulk Upload Topics'),
            content: SizedBox(
              width: 720,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload a CSV or JSON file, or paste the content directly. '
                      'All topics will be added to the current chapter.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: pickFile,
                          icon: const Icon(Icons.upload_file_outlined),
                          label: const Text('Choose File'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            contentCtrl.text = _bulkTopicTemplate;
                            setDialogState(() {
                              fileName = null;
                              previewTopics = null;
                              isError = false;
                              statusMessage =
                                  'Loaded sample CSV template into the editor.';
                            });
                          },
                          icon: const Icon(Icons.description_outlined),
                          label: const Text('Use Template'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final downloaded = await downloadTextFile(
                              fileName: 'topics_bulk_template.csv',
                              content: _bulkTopicTemplate,
                            );
                            setDialogState(() {
                              isError = !downloaded;
                              statusMessage = downloaded
                                  ? 'Template downloaded: topics_bulk_template.csv'
                                  : 'Template download is only supported in the web app.';
                            });
                          },
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Download Template'),
                        ),
                      ],
                    ),
                    if (fileName != null) ...[
                      const SizedBox(height: 8),
                      Text('Selected file: $fileName'),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentCtrl,
                      onChanged: (_) {
                        setDialogState(() {
                          previewTopics = null;
                          if (!isError) {
                            statusMessage = null;
                          }
                        });
                      },
                      minLines: 12,
                      maxLines: 18,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                        labelText: 'CSV or JSON payload',
                        hintText:
                            'CSV columns: title, description, estimatedHours, difficultyLevel, orderIndex, isActive',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'JSON accepts either a top-level array of topics or an object with a "topics" array.',
                      style: TextStyle(fontSize: 12),
                    ),
                    if (previewTopics != null) ...[
                      const SizedBox(height: 16),
                      _TopicPreviewTable(topics: previewTopics!),
                    ],
                    if (statusMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        statusMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isError
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  try {
                    final topics = _parseBulkTopicPayload(
                      rawContent: contentCtrl.text,
                      chapterId: chapterId,
                      startingOrderIndex: startingOrderIndex,
                    );
                    setDialogState(() {
                      previewTopics = topics;
                      isError = false;
                      statusMessage =
                          'Preview ready: ${topics.length} topics will be uploaded.';
                    });
                  } catch (error) {
                    setDialogState(() {
                      previewTopics = null;
                      isError = true;
                      statusMessage = error.toString();
                    });
                  }
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Preview'),
              ),
              FilledButton.icon(
                onPressed: previewTopics == null
                    ? null
                    : () => Navigator.pop(dialogContext, previewTopics),
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Upload Topics'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _TopicPreviewTable extends StatelessWidget {
  final List<Map<String, dynamic>> topics;

  const _TopicPreviewTable({required this.topics});

  @override
  Widget build(BuildContext context) {
    final previewItems = topics.take(8).toList();
    final hasMore = topics.length > previewItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview (${topics.length} topics)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Hours')),
                DataColumn(label: Text('Difficulty')),
                DataColumn(label: Text('Active')),
              ],
              rows: previewItems.map((topic) {
                final orderIndex = topic['orderIndex']?.toString() ?? '-';
                final title = topic['title']?.toString() ?? '';
                final hours = topic['estimatedHours']?.toString() ?? '1.0';
                final difficulty = topic['difficultyLevel']?.toString() ?? 'MEDIUM';
                final active = (topic['isActive'] as bool? ?? true) ? 'Yes' : 'No';
                return DataRow(
                  cells: [
                    DataCell(Text(orderIndex)),
                    DataCell(SizedBox(width: 260, child: Text(title))),
                    DataCell(Text(hours)),
                    DataCell(Text(difficulty)),
                    DataCell(Text(active)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        if (hasMore) ...[
          const SizedBox(height: 6),
          Text(
            'Showing first ${previewItems.length} rows. ${topics.length - previewItems.length} more rows will also be uploaded.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

List<Map<String, dynamic>> _parseBulkTopicPayload({
  required String rawContent,
  required int chapterId,
  required int startingOrderIndex,
}) {
  final content = rawContent.trim();
  if (content.isEmpty) {
    throw const FormatException('Add CSV or JSON content before uploading.');
  }

  if (content.startsWith('[') || content.startsWith('{')) {
    return _parseJsonTopics(
      content: content,
      chapterId: chapterId,
      startingOrderIndex: startingOrderIndex,
    );
  }

  return _parseCsvTopics(
    content: content,
    chapterId: chapterId,
    startingOrderIndex: startingOrderIndex,
  );
}

List<Map<String, dynamic>> _parseJsonTopics({
  required String content,
  required int chapterId,
  required int startingOrderIndex,
}) {
  final decoded = jsonDecode(content);
  late final List<dynamic> entries;

  if (decoded is List<dynamic>) {
    entries = decoded;
  } else if (decoded is Map<String, dynamic> && decoded['topics'] is List<dynamic>) {
    entries = decoded['topics'] as List<dynamic>;
  } else {
    throw const FormatException(
      'JSON must be an array of topic objects or an object with a "topics" array.',
    );
  }

  if (entries.isEmpty) {
    throw const FormatException('The uploaded JSON does not contain any topics.');
  }

  return entries.asMap().entries.map((entry) {
    final item = entry.value;
    if (item is! Map<String, dynamic>) {
      throw FormatException(
        'Topic ${entry.key + 1} must be a JSON object.',
      );
    }
    return _buildTopicPayload(
      raw: item,
      chapterId: chapterId,
      rowNumber: entry.key + 1,
      defaultOrderIndex: startingOrderIndex + entry.key,
    );
  }).toList();
}

List<Map<String, dynamic>> _parseCsvTopics({
  required String content,
  required int chapterId,
  required int startingOrderIndex,
}) {
  final rows = const LineSplitter()
      .convert(content)
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map(_parseCsvRow)
      .toList();

  if (rows.isEmpty) {
    throw const FormatException('The uploaded CSV does not contain any rows.');
  }

  Map<String, int>? headerMap;
  var dataStartIndex = 0;
  if (_isHeaderRow(rows.first)) {
    headerMap = _buildHeaderMap(rows.first);
    dataStartIndex = 1;
  }

  if (rows.length == dataStartIndex) {
    throw const FormatException('The uploaded CSV does not contain any topic rows.');
  }

  final topics = <Map<String, dynamic>>[];
  for (var rowIndex = dataStartIndex; rowIndex < rows.length; rowIndex++) {
    final row = rows[rowIndex];
    final title = _readCsvValue(
      row,
      headerMap,
      aliases: const ['title'],
      fallbackIndex: 0,
      rowNumber: rowIndex + 1,
      required: true,
    );
    final description = _readCsvValue(
      row,
      headerMap,
      aliases: const ['description', 'desc'],
      fallbackIndex: 1,
      rowNumber: rowIndex + 1,
    );
    final estimatedHoursText = _readCsvValue(
      row,
      headerMap,
      aliases: const ['estimatedhours', 'hours'],
      fallbackIndex: 2,
      rowNumber: rowIndex + 1,
    );
    final difficultyText = _readCsvValue(
      row,
      headerMap,
      aliases: const ['difficultylevel', 'difficulty'],
      fallbackIndex: 3,
      rowNumber: rowIndex + 1,
    );
    final orderIndexText = _readCsvValue(
      row,
      headerMap,
      aliases: const ['orderindex', 'order'],
      fallbackIndex: 4,
      rowNumber: rowIndex + 1,
    );
    final isActiveText = _readCsvValue(
      row,
      headerMap,
      aliases: const ['isactive', 'active'],
      fallbackIndex: 5,
      rowNumber: rowIndex + 1,
    );

    topics.add(_buildTopicPayload(
      raw: {
        'title': title,
        'description': description,
        'estimatedHours': estimatedHoursText,
        'difficultyLevel': difficultyText,
        'orderIndex': orderIndexText,
        'isActive': isActiveText,
      },
      chapterId: chapterId,
      rowNumber: rowIndex + 1,
      defaultOrderIndex: startingOrderIndex + topics.length,
    ));
  }

  return topics;
}

Map<String, dynamic> _buildTopicPayload({
  required Map<String, dynamic> raw,
  required int chapterId,
  required int rowNumber,
  required int defaultOrderIndex,
}) {
  final title = _requiredString(raw['title'], 'title', rowNumber);
  final description = _optionalString(raw['description']);
  final estimatedHours = _parseDoubleValue(
        raw['estimatedHours'],
        'estimatedHours',
        rowNumber,
      ) ??
      1.0;
  final difficultyLevel = _parseDifficulty(raw['difficultyLevel'], rowNumber);
  final orderIndex = _parseIntValue(raw['orderIndex'], 'orderIndex', rowNumber) ??
      defaultOrderIndex;
  final isActive = _parseBoolValue(raw['isActive'], 'isActive', rowNumber) ?? true;

  return {
    'chapterId': chapterId,
    'title': title,
    'description': description,
    'estimatedHours': estimatedHours,
    'difficultyLevel': difficultyLevel,
    'orderIndex': orderIndex,
    'isActive': isActive,
  };
}

List<String> _parseCsvRow(String row) {
  final values = <String>[];
  final current = StringBuffer();
  var inQuotes = false;

  for (var index = 0; index < row.length; index++) {
    final char = row[index];
    if (char == '"') {
      final nextIsQuote = index + 1 < row.length && row[index + 1] == '"';
      if (inQuotes && nextIsQuote) {
        current.write('"');
        index++;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (char == ',' && !inQuotes) {
      values.add(current.toString().trim());
      current
        ..clear()
        ..write('');
      continue;
    }

    current.write(char);
  }

  if (inQuotes) {
    throw FormatException('CSV row has unclosed quotes: $row');
  }

  values.add(current.toString().trim());
  return values;
}

bool _isHeaderRow(List<String> row) {
  final normalized = row.map(_normalizeHeader).toSet();
  return normalized.contains('title') || normalized.contains('difficultylevel');
}

Map<String, int> _buildHeaderMap(List<String> row) {
  return {
    for (var index = 0; index < row.length; index++)
      _normalizeHeader(row[index]): index,
  };
}

String _normalizeHeader(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

String? _readCsvValue(
  List<String> row,
  Map<String, int>? headerMap, {
  required List<String> aliases,
  required int fallbackIndex,
  required int rowNumber,
  bool required = false,
}) {
  int? index;
  if (headerMap != null) {
    for (final alias in aliases) {
      index = headerMap[alias];
      if (index != null) {
        break;
      }
    }
  } else {
    index = fallbackIndex;
  }

  final value = index != null && index < row.length ? row[index].trim() : '';
  if (required && value.isEmpty) {
    throw FormatException('Row $rowNumber is missing ${aliases.first}.');
  }
  return value.isEmpty ? null : value;
}

String _requiredString(Object? value, String fieldName, int rowNumber) {
  final text = _optionalString(value);
  if (text == null || text.isEmpty) {
    throw FormatException('Row $rowNumber is missing $fieldName.');
  }
  return text;
}

String? _optionalString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

double? _parseDoubleValue(Object? value, String fieldName, int rowNumber) {
  if (value == null || value.toString().trim().isEmpty) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  final parsed = double.tryParse(value.toString().trim());
  if (parsed == null) {
    throw FormatException('Row $rowNumber has an invalid $fieldName value.');
  }
  return parsed;
}

int? _parseIntValue(Object? value, String fieldName, int rowNumber) {
  if (value == null || value.toString().trim().isEmpty) {
    return null;
  }
  if (value is num) {
    return value.toInt();
  }
  final parsed = int.tryParse(value.toString().trim());
  if (parsed == null) {
    throw FormatException('Row $rowNumber has an invalid $fieldName value.');
  }
  return parsed;
}

bool? _parseBoolValue(Object? value, String fieldName, int rowNumber) {
  if (value == null || value.toString().trim().isEmpty) {
    return null;
  }
  if (value is bool) {
    return value;
  }
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  throw FormatException('Row $rowNumber has an invalid $fieldName value.');
}

String _parseDifficulty(Object? value, int rowNumber) {
  final normalized = value?.toString().trim().toUpperCase();
  if (normalized == null || normalized.isEmpty) {
    return 'MEDIUM';
  }
  if (normalized == 'EASY' || normalized == 'MEDIUM' || normalized == 'HARD') {
    return normalized;
  }
  throw FormatException(
    'Row $rowNumber has an invalid difficultyLevel. Use EASY, MEDIUM, or HARD.',
  );
}