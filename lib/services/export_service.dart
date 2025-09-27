import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/pdf.dart';
// ignore: depend_on_referenced_packages
import 'package:pdf/widgets.dart' as pw;

import 'package:lifeline/memory.dart';
import 'package:lifeline/models/anchors/anchor_models.dart';

/// Сервис, отвечающий за логику генерации PDF и JSON файлов.
class ExportService {
  // В будущем здесь могут быть методы для управления шаблонами и т.д.
}

/// Класс для передачи данных в изолят
class ExportIsolateData {
  final SendPort sendPort;
  final List<Memory> memories;
  final String format;
  final ByteData orbitronRegular;
  final ByteData orbitronBold;
  final List<String> localImagePaths;
  final List<SpotifyTrackDetails> spotifyDetails;

  ExportIsolateData({
    required this.sendPort,
    required this.memories,
    required this.format,
    required this.orbitronRegular,
    required this.orbitronBold,
    required this.localImagePaths,
    required this.spotifyDetails,
  });
}

/// Точка входа для изолята, который будет генерировать файл экспорта.
Future<void> generateExportFile(ExportIsolateData data) async {
  await initializeDateFormatting('ru', null);

  Uint8List result;

  if (data.format == 'pdf') {
    result = await _generatePdf(
      data.memories,
      data.orbitronRegular,
      data.orbitronBold,
      data.localImagePaths,
      data.spotifyDetails,
    );
  } else if (data.format == 'json') {
    result = await _generateJson(data.memories);
  } else {
    result = Uint8List(0);
  }

  data.sendPort.send(result);
}

Future<Uint8List> _generateJson(List<Memory> memories) async {
  final List<Map<String, dynamic>> memoriesJson = [];
  for (final memory in memories) {
    final firestoreMap = memory.toFirestore();
    final jsonMap = <String, dynamic>{};

    firestoreMap.forEach((key, value) {
      if (value is Timestamp) {
        jsonMap[key] = value.toDate().toIso8601String();
      } else {
        jsonMap[key] = value;
      }
    });
    memoriesJson.add(jsonMap);
  }

  final jsonString = jsonEncode(memoriesJson);
  return utf8.encode(jsonString);
}

String _getTranslatedEmotion(String key) {
  const translations = {
    'joy': 'Радость',
    'nostalgia': 'Ностальгия',
    'pride': 'Гордость',
    'sadness': 'Грусть',
    'gratitude': 'Благодарность',
    'love': 'Любовь',
    'fear': 'Страх',
    'anger': 'Злость',
  };
  return translations[key.toLowerCase()] ?? key;
}

Future<Uint8List> _generatePdf(
  List<Memory> memories,
  ByteData fontRegular,
  ByteData fontBold,
  List<String> localImagePaths,
  List<SpotifyTrackDetails> spotifyDetails,
) async {
  final pdf = pw.Document();

  final ttfRegular = pw.Font.ttf(fontRegular);
  final ttfBold = pw.Font.ttf(fontBold);

  final imageProviders = <pw.MemoryImage>[];
  for (final path in localImagePaths) {
    final file = File(path);
    if (await file.exists()) {
      imageProviders.add(pw.MemoryImage(await file.readAsBytes()));
    }
  }

  final Map<String, pw.MemoryImage> spotifyArtworks = {};
  await Future.wait(spotifyDetails.map((details) async {
    if (details.albumArtUrl != null) {
      try {
        final response = await http.get(Uri.parse(details.albumArtUrl!));
        if (response.statusCode == 200) {
          spotifyArtworks[details.id] = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        // ignore: avoid_print
        print('Could not download spotify artwork: ${details.albumArtUrl}');
      }
    }
  }));

  for (final memory in memories) {
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: ttfRegular,
          bold: ttfBold,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Expanded(
                      child: pw.Text(memory.title,
                          style: pw.TextStyle(font: ttfBold, fontSize: 24))),
                  pw.Row(children: [
                    pw.Text(DateFormat.yMMMMd('ru').format(memory.date),
                        style: pw.TextStyle(
                            font: ttfRegular,
                            fontSize: 12,
                            color: PdfColors.grey)),
                    if (memory.isEncrypted)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 8),
                        child: pw.Text('🔒',
                            style: const pw.TextStyle(fontSize: 12)),
                      ),
                  ])
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            if (memory.content != null && memory.content!.isNotEmpty)
              pw.Paragraph(
                text: memory.content!,
                style: const pw.TextStyle(lineSpacing: 5, fontSize: 11),
              ),
            if (memory.content != null && memory.content!.isNotEmpty)
              pw.SizedBox(height: 20),

            if (imageProviders.isNotEmpty)
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: imageProviders.map((img) {
                  return pw.SizedBox(
                      width: 120,
                      height: 120,
                      child: pw.Image(img, fit: pw.BoxFit.cover));
                }).toList(),
              ),
            if (imageProviders.isNotEmpty) pw.SizedBox(height: 20),

            ...spotifyDetails.map((track) => _buildSpotifyBlock(
                track, spotifyArtworks[track.id], ttfRegular, ttfBold)),
            
            if (memory.displayableAudioPaths.isNotEmpty)
              ...memory.displayableAudioPaths.map((url) => _buildMediaQrBlock(
                  'Аудиозаметка', url, ttfRegular, ttfBold)),

            if (memory.displayableVideoPaths.isNotEmpty)
              ...memory.displayableVideoPaths.map((url) => _buildMediaQrBlock(
                  'Видеозапись', url, ttfRegular, ttfBold)),

            _buildReflectionBlock(memory, ttfRegular, ttfBold),
          ];
        },
      ),
    );
  }

  return pdf.save();
}

pw.Widget _buildSpotifyBlock(SpotifyTrackDetails track, pw.MemoryImage? artwork,
    pw.Font ttfRegular, pw.Font ttfBold) {
  return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Моя песня',
                style: pw.TextStyle(font: ttfBold, fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (artwork != null)
                    pw.SizedBox(
                      width: 60,
                      height: 60,
                      child: pw.Image(artwork, fit: pw.BoxFit.cover),
                    ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                        pw.Text(track.name,
                            style: pw.TextStyle(font: ttfBold, fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text(track.artist,
                            style: pw.TextStyle(
                                font: ttfRegular,
                                fontSize: 10,
                                color: PdfColors.grey700)),
                      ])),
                  if (track.trackUrl != null)
                    pw.SizedBox(
                      width: 60,
                      height: 60,
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: track.trackUrl!,
                        color: PdfColors.black,
                      ),
                    )
                ]),
          ]));
}

pw.Widget _buildMediaQrBlock(
    String title, String url, pw.Font ttfRegular, pw.Font ttfBold) {
  return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(font: ttfBold, fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Expanded(
                    child: pw.Text('Отсканируйте для просмотра/прослушивания',
                        style: pw.TextStyle(
                            font: ttfRegular,
                            fontSize: 10,
                            color: PdfColors.grey700)),
                  ),
                  pw.SizedBox(
                    width: 60,
                    height: 60,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: url,
                      color: PdfColors.black,
                    ),
                  )
                ]),
          ]));
}

pw.Widget _buildReflectionItem(
    String title, String content, pw.Font ttfRegular, pw.Font ttfBold) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: ttfBold, fontSize: 11)),
        pw.SizedBox(height: 4),
        pw.Text(content,
            style: pw.TextStyle(
                font: ttfRegular, fontSize: 10, color: PdfColors.grey700)),
      ],
    ),
  );
}

pw.Widget _buildReflectionBlock(
    Memory memory, pw.Font ttfRegular, pw.Font ttfBold) {
  final hasImpact =
      memory.reflectionImpact != null && memory.reflectionImpact!.isNotEmpty;
  final hasLesson =
      memory.reflectionLesson != null && memory.reflectionLesson!.isNotEmpty;
  final hasEmotions = memory.emotions.isNotEmpty;

  if (!hasImpact && !hasLesson && !hasEmotions) {
    return pw.SizedBox.shrink();
  }

  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 20),
    padding: const pw.EdgeInsets.all(16),
    decoration: const pw.BoxDecoration(
      color: PdfColors.grey200,
      borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
    ),
    child:
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(
        'Рефлексия',
        style: pw.TextStyle(font: ttfBold, fontSize: 16),
      ),
      pw.SizedBox(height: 12),
      if (hasImpact)
        _buildReflectionItem(
            'Влияние', memory.reflectionImpact!, ttfRegular, ttfBold),
      if (hasLesson)
        _buildReflectionItem(
            'Извлеченный урок', memory.reflectionLesson!, ttfRegular, ttfBold),
      if (hasEmotions) ...[
        pw.SizedBox(height: 8),
        pw.Text('Эмоции:', style: pw.TextStyle(font: ttfBold, fontSize: 11)),
        pw.SizedBox(height: 5),
        pw.Wrap(
          spacing: 5,
          runSpacing: 5,
          children: memory.emotions.entries.map((entry) {
            final emotionName = _getTranslatedEmotion(entry.key);
            return pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text('$emotionName (${entry.value}%)',
                  style: const pw.TextStyle(fontSize: 9)),
            );
          }).toList(),
        ),
      ]
    ]),
  );
}

