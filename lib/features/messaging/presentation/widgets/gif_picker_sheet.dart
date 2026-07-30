import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../data/gif_api.dart';

/// Bottom sheet GIF search/browse, backed by Klipy. Selecting a result pops
/// the sheet with the full GIF URL - the caller sends that URL as the
/// message content directly (matches desktop: a GIF isn't an attachment, the
/// message body just *is* the CDN url and renders specially).
Future<String?> showGifPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _GifPickerSheet(),
  );
}

class _GifPickerSheet extends StatefulWidget {
  const _GifPickerSheet();

  @override
  State<_GifPickerSheet> createState() => _GifPickerSheetState();
}

class _GifPickerSheetState extends State<_GifPickerSheet> {
  final _api = GifApi();
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<GifResult>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({String query = ''}) async {
    setState(() {
      _results = null;
      _error = null;
    });
    try {
      final results = query.isEmpty
          ? await _api.trending()
          : await _api.search(query);
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load GIFs.');
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _load(query: value.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search GIFs',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Expanded(
                child: _error != null
                    ? Center(child: Text(_error!))
                    : _results == null
                    ? const Center(child: CircularProgressIndicator())
                    : _results!.isEmpty
                    ? const Center(child: Text('No GIFs found'))
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: AppSpacing.xs,
                              crossAxisSpacing: AppSpacing.xs,
                              childAspectRatio: 1,
                            ),
                        itemCount: _results!.length,
                        itemBuilder: (context, index) {
                          final gif = _results![index];
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pop(gif.url),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppRadii.chip,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: gif.previewUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  'Powered by KLIPY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
