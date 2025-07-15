enum TicketCategory {
  byAppointment('Прием по записи'),
  makeAppointment('Запись на прием'),
  tests('Анализы'),
  other('Другой вопрос');

  final String name;
  const TicketCategory(this.name);
}