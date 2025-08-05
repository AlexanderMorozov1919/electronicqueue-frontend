import '../entities/ad_display.dart';

abstract class AdDisplayRepository {
  Future<List<AdDisplay>> getEnabledAds();
}