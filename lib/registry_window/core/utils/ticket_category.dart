enum TicketCategory {
  all('Все категории'),
  makeAppointment('Записаться'),
  byAppointment('Прием по записи'),
  tests('Анализы'),
  other('Получить результаты');

  final String name;
  const TicketCategory(this.name);
}