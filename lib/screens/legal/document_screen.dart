import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lifeline/l10n/app_localizations.dart';

class DocumentScreen extends StatelessWidget {
  final String documentPath;
  final String title;

  const DocumentScreen({
    super.key,
    required this.title,
    required this.documentPath,
  });

  Future<String> _loadDocument() async {
    return await rootBundle.loadString(documentPath);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<String>(
        future: _loadDocument(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Markdown(
                data: snapshot.data!,
                padding: const EdgeInsets.all(16.0),
              );
            }
            return Center(child: Text(l10n.documentErrorLoading));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
