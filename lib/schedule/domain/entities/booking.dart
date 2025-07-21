import 'booking_actor.dart';
import 'booking_entity.dart';

class Booking {
  final BookingActor actor;
  final List<BookingEntity> bookingEntities;
  final DateTime startTime;
  final DateTime endTime;

  Booking({
    required this.actor,
    required this.bookingEntities,
    required this.endTime,
    required this.startTime,
  });

  List<DateTime> getTimes() {
    // Создаем множество для хранения уникальных временных точек
    final uniqueTimes = <DateTime>{};

    // Добавляем startTime и endTime из каждого BookingEntity
    for (final entity in bookingEntities) {
      uniqueTimes.add(entity.startTime);
      uniqueTimes.add(entity.endTime);
    }

    // Преобразуем множество в отсортированный список
    final sortedTimes = uniqueTimes.toList()..sort((a, b) => a.compareTo(b));

    return sortedTimes;
  }

  BookingEntity? getEntityByTime({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    for (BookingEntity bookingEntity in this.bookingEntities) {
      if ((bookingEntity.startTime == startTime) &&
          (bookingEntity.endTime == endTime)) {
        return bookingEntity;
      }
    }
    return null;
  }
}

class ScheduleFilter {
  final bool filterEnabled;
  final List<FilterItem>? equipmentType;
  final List<FilterItem>? branch;
  final List<FilterItem>? department;

  ScheduleFilter({
    this.equipmentType = null,
    this.branch = null,
    this.department = null,
    this.filterEnabled = false,
  });

  /// Фабричный метод для создания фильтра по списку Booking
  factory ScheduleFilter.fromBookings(List<Booking> bookings) {
    // Используем множества для уникальных значений
    final branchSet = <String>{};
    final departmentSet = <String>{};
    final equipmentTypeSet = <String>{};

    for (final booking in bookings) {
      final actor = booking.actor;
      
          departmentSet;
      actor.equipmentType != ''
          ? equipmentTypeSet.add(actor.equipmentType)
          : equipmentTypeSet;
    }

    List<FilterItem> toFilterItems(Set<String> set) =>
        set.map((e) => FilterItem(title: e, value: false)).toList();

    return ScheduleFilter(
      branch: toFilterItems(branchSet),
      department: toFilterItems(departmentSet),
      equipmentType: toFilterItems(equipmentTypeSet),
      filterEnabled: false,
    );
  }

  bool areAllValuesFalse() {
    // Вспомогательная функция для проверки списка
    bool allItemsAreFalse(List<FilterItem>? items) {
      if (items == null || items.isEmpty) {
        // Если список пустой или null, считаем, что все значения false
        return true;
      }
      return items.every((item) => item.value == false);
    }

    // Проверяем все категории фильтра
    return allItemsAreFalse(equipmentType) &&
        allItemsAreFalse(branch) &&
        allItemsAreFalse(department);
  }

  ScheduleFilter resetAllValuesToFalse() {
    // Вспомогательная функция для сброса значений в списке
    List<FilterItem>? resetItems(List<FilterItem>? items) {
      if (items == null || items.isEmpty) {
        return items; // Если список пустой или null, возвращаем его без изменений
      }
      return items
          .map((item) => FilterItem(title: item.title, value: false))
          .toList();
    }

    // Создаем новый ScheduleFilter с обновленными списками
    return ScheduleFilter(
      filterEnabled: false, // Сохраняем текущее значение filterEnabled
      department: resetItems(department),
      branch: resetItems(branch),
      equipmentType: resetItems(equipmentType),
    );
  }
}

class TimePoint {
  final DateTime time;
  final bool isAxis;

  TimePoint({
    required this.isAxis,
    required this.time,
  });

  @override
  bool operator ==(Object other) {
    return other is TimePoint && other.time == time && other.isAxis == isAxis;
  }

  // Переопределяем hashCode
  @override
  int get hashCode => Object.hash(time, isAxis);
}

class FilterItem {
  final String title;
  final bool value;

  FilterItem({
    required this.title,
    required this.value,
  });
}
