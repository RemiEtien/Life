import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lifeline/l10n/app_localizations.dart';
import 'package:markdown_widget/markdown_widget.dart';

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
              // ИЗМЕНЕНИЕ: Заменен Markdown на MarkdownWidget из нового пакета.
              // Виджет обернут в SingleChildScrollView для поддержки прокрутки.
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: MarkdownWidget(
                  data: snapshot.data!,
                  // Базовая конфигурация для улучшения внешнего вида
                  config: MarkdownConfig(
                    configs: [
                      PConfig(
                        textStyle: Theme.of(context).textTheme.bodyMedium ??
                            const TextStyle(),
                      ),
                      H1Config(
                        style: Theme.of(context).textTheme.headlineSmall ??
                            const TextStyle(),
                      ),
                      H2Config(
                        style: Theme.of(context).textTheme.titleLarge ??
                            const TextStyle(),
                      ),
                      H3Config(
                        style: Theme.of(context).textTheme.titleMedium ??
                            const TextStyle(),
                      ),
                    ],
                  ),
                ),
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

