import 'package:elqueue/queue_reception/data/datasources/ad_display_remote_datasource.dart';
import 'package:elqueue/queue_reception/domain/entities/ad_display.dart';
import 'package:elqueue/queue_reception/domain/repositories/ad_display_repository.dart';

class AdDisplayRepositoryImpl implements AdDisplayRepository {
  final AdDisplayRemoteDataSource dataSource;

  AdDisplayRepositoryImpl({required this.dataSource});

  @override
  Future<List<AdDisplay>> getEnabledAds() {
    return dataSource.getEnabledAds();
  }
}