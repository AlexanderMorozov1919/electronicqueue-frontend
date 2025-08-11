import 'dart:convert';
import 'package:elqueue/administrator/data/datasource/ad_remote_data_source.dart';
import 'package:elqueue/administrator/domain/entities/ad_entity.dart';
import 'package:elqueue/administrator/presentation/blocs/ad/ad_bloc.dart';
import 'package:elqueue/administrator/presentation/widgets/ad/ad_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class AdCardWidget extends StatefulWidget {
  final AdEntity ad;
  const AdCardWidget({super.key, required this.ad});

  @override
  State<AdCardWidget> createState() => _AdCardWidgetState();
}

class _AdCardWidgetState extends State<AdCardWidget> {
  AdEntity? _fullAd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullAd = widget.ad;
    if ((widget.ad.mediaType == 'image' &&
            (widget.ad.picture == null || widget.ad.picture!.isEmpty)) ||
        (widget.ad.mediaType == 'video' &&
            (widget.ad.video == null || widget.ad.video!.isEmpty))) {
      _fetchAdMedia();
    }
  }

  Future<void> _fetchAdMedia() async {
    if (widget.ad.id == null) return;
    setState(() => _isLoading = true);
    try {
      final dataSource = AdRemoteDataSourceImpl(client: http.Client());
      final fetchedAd = await dataSource.getAdById(widget.ad.id!);
      if (mounted) {
        setState(() {
          _fullAd = fetchedAd;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print("Failed to load media for ad ${widget.ad.id}: $e");
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Подтверждение'),
        content: const Text(
            'Вы уверены, что хотите удалить этот рекламный материал?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (widget.ad.id != null) {
                context.read<AdBloc>().add(DeleteAdById(widget.ad.id!));
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdBloc>(),
        child: AdEditDialog(ad: _fullAd),
      ),
    ).then((_) {
      context.read<AdBloc>().add(LoadAds());
    });
  }

  void _showPreview(BuildContext context) {
    if (_fullAd == null) return;

    if (_fullAd!.mediaType == 'image' &&
        _fullAd!.picture != null &&
        _fullAd!.picture!.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Image.memory(base64Decode(_fullAd!.picture!)),
          ),
        ),
      );
    } else if (_fullAd!.mediaType == 'video') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Предпросмотр видео недоступен в этой панели")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final adData = _fullAd ?? widget.ad;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              onTap: () => _showPreview(context),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : adData.mediaType == 'image' &&
                          adData.picture != null &&
                          adData.picture!.isNotEmpty
                      ? Image.memory(
                          base64Decode(adData.picture!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, color: Colors.red),
                        )
                      : adData.mediaType == 'video'
                          ? const Center(
                              child: Icon(Icons.videocam,
                                  size: 60, color: Colors.grey))
                          : const Center(
                              child: Icon(Icons.image_not_supported,
                                  color: Colors.grey)),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Column(
              children: [
                IconButton(
                  onPressed: () => _showEditDialog(context),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Редактировать',
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  tooltip: 'Удалить',
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: Icon(
                      adData.mediaType == 'video'
                          ? Icons.repeat
                          : Icons.timer_outlined,
                      color: Colors.white),
                  label: Text(
                      adData.mediaType == 'video'
                          ? '${adData.repeatCount} раз'
                          : '${adData.durationSec} сек',
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.black54,
                ),
                Switch(
                  value: adData.isEnabled,
                  onChanged: (newValue) {
                    context.read<AdBloc>().add(
                        UpdateAdInfo(adData.copyWith(isEnabled: newValue)));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}