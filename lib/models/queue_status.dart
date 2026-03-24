class QueueAppointment {
  final int id;
  final int queueNumber;
  final String queueNumberFormatted;
  final String status;
  final String scheduleTime;

  QueueAppointment({
    required this.id,
    required this.queueNumber,
    required this.queueNumberFormatted,
    required this.status,
    required this.scheduleTime,
  });

  factory QueueAppointment.fromJson(Map<String, dynamic> json) {
    return QueueAppointment(
      id: json['id'],
      queueNumber: json['queue_number'],
      queueNumberFormatted: json['queue_number_formatted'],
      status: json['status'],
      scheduleTime: json['schedule_time'],
    );
  }
}

class QueueStatus {
  final QueueAppointment? currentServing;
  final List<QueueAppointment> appointments;

  QueueStatus({
    this.currentServing,
    required this.appointments,
  });

  factory QueueStatus.fromJson(Map<String, dynamic> json) {
    return QueueStatus(
      currentServing: json['current_serving'] != null
          ? QueueAppointment.fromJson(json['current_serving'])
          : null,
      appointments: (json['appointments'] as List)
          .map((a) => QueueAppointment.fromJson(a))
          .toList(),
    );
  }
}
