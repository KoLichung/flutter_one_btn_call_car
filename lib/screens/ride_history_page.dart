import 'package:flutter/material.dart';
import '../models/ride_record.dart';
import 'ride_detail_page.dart';

class RideHistoryPage extends StatefulWidget {
  const RideHistoryPage({super.key});

  @override
  State<RideHistoryPage> createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage> {
  // Mock ride history data
  final List<RideRecord> _rideHistory = [
    RideRecord(
      id: '1',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      pickupAddress: '台北車站',
      dropoffAddress: '台北101',
      fare: 250.0,
      duration: 25,
      driverName: '王師傅',
      carNumber: 'ABC-1234',
      status: 'completed',
    ),
    RideRecord(
      id: '2',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      pickupAddress: '信義區',
      dropoffAddress: '松山機場',
      fare: 380.0,
      duration: 35,
      driverName: '李師傅',
      carNumber: 'DEF-5678',
      status: 'completed',
    ),
    RideRecord(
      id: '3',
      dateTime: DateTime.now().subtract(const Duration(days: 7)),
      pickupAddress: '西門町',
      dropoffAddress: '台北車站',
      fare: 150.0,
      duration: 15,
      driverName: '張師傅',
      carNumber: 'GHI-9012',
      status: 'completed',
    ),
    RideRecord(
      id: '4',
      dateTime: DateTime.now().subtract(const Duration(days: 10)),
      pickupAddress: '台北101',
      dropoffAddress: '大安森林公園',
      fare: 180.0,
      duration: 18,
      driverName: '陳師傅',
      carNumber: 'JKL-3456',
      status: 'completed',
    ),
    RideRecord(
      id: '5',
      dateTime: DateTime.now().subtract(const Duration(days: 15)),
      pickupAddress: '士林夜市',
      dropoffAddress: '淡水老街',
      fare: 420.0,
      duration: 45,
      driverName: '林師傅',
      carNumber: 'MNO-7890',
      status: 'completed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('叫車紀錄'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // History List
          Expanded(
            child: _rideHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '尚無叫車紀錄',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rideHistory.length,
                    itemBuilder: (context, index) {
                      return _buildRideCard(_rideHistory[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(RideRecord ride) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RideDetailPage(ride: ride),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left side - Time and Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time
                    Text(
                      _formatDate(ride.dateTime),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Pickup Address
                    Text(
                      ride.pickupAddress,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right side - Status and Fare
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ride.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(ride.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(ride.status),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Fare
                  Text(
                    'NT\$ ${ride.fare.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} 天前';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return '未知';
    }
  }
}

