class RideRecord {
  final String id;
  final DateTime dateTime;
  final String pickupAddress;
  final String dropoffAddress;
  final double fare;
  final int duration; // in minutes
  final String driverName;
  final String carNumber;
  final String status; // completed, cancelled, etc.

  RideRecord({
    required this.id,
    required this.dateTime,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.fare,
    required this.duration,
    required this.driverName,
    required this.carNumber,
    required this.status,
  });
}

