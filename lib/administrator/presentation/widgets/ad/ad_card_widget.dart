import 'dart:convert';
import 'package:elqueue/administrator/data/datasource/ad_remote_data_source.dart';
import 'package:elqueue/administrator/domain/entities/ad_entity.dart';
import 'package:elqueue/administrator/presentation/blocs/ad/ad_bloc.dart';
import 'package:elqueue/administrator/presentation/widgets/ad/ad_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;


// ИСПРАВЛЕНИЕ: Превращаем в StatefulWidget для ленивой загрузки
class AdCardWidget extends StatefulWidget {
  final AdEntity ad;
  const AdCardWidget({super.key, required this.ad});

  @override
  State<AdCardWidget> createState() => _AdCardWidgetState();
}

class _AdCardWidgetState extends State<AdCardWidget> {
  String? _pictureBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Если картинки нет, загружаем ее
    if (widget.ad.picture == null || widget.ad.picture!.isEmpty) {
      _fetchAdPicture();
    } else {
      _pictureBase64 = widget.ad.picture;
    }
  }

  Future<void> _fetchAdPicture() async {
    if (widget.ad.id == null) return;
    setState(() => _isLoading = true);
    try {
      // Напрямую обращаемся к DataSource для простоты
      final dataSource = AdRemoteDataSourceImpl(client: http.Client());
      final fullAd = await dataSource.getAdById(widget.ad.id!);
      if (mounted) {
        setState(() {
          _pictureBase64 = fullAd.picture;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print("Failed to load picture for ad ${widget.ad.id}: $e");
    }
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Подтверждение'),
        content: const Text('Вы уверены, что хотите удалить этот рекламный материал?'),
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
        // Передаем AdEntity с уже загруженной картинкой
        child: AdEditDialog(ad: widget.ad.copyWith(picture: _pictureBase64)),
      )
    ).then((_) {
      // Обновляем картинку после редактирования, если нужно
      context.read<AdBloc>().add(LoadAds());
    });
  }
  
  void _showImagePreview(BuildContext context) {
    if (_pictureBase64 == null) return;
    showDialog(context: context, builder: (_) => Dialog(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Image.memory(base64Decode(_pictureBase64!)),
      ),
    ));
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Image
          Positioned.fill(
            child: InkWell(
              onTap: () => _showImagePreview(context),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _pictureBase64 != null && _pictureBase64!.isNotEmpty
                      ? Image.memory(
                          base64Decode(_pictureBase64!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, color: Colors.red),
                        )
                      : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
            ),
          ),
          // Gradient overlay for text
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
          // Controls
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
                  avatar: const Icon(Icons.timer_outlined, color: Colors.white),
                  label: Text('${widget.ad.durationSec} сек', style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.black54,
                ),
                Switch(
                  value: widget.ad.isEnabled,
                  onChanged: (newValue) {
                    context.read<AdBloc>().add(
                        UpdateAdInfo(widget.ad.copyWith(isEnabled: newValue, picture: _pictureBase64)));
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