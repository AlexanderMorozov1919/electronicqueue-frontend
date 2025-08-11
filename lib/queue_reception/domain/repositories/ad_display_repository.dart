import 'package:elqueue/queue_reception/domain/entities/ad_display.dart';

abstract class AdDisplayRepository {
  Future<List<AdDisplay>> getEnabledAds(String screen);
}