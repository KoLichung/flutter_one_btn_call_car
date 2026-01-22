import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/ride_record.dart';
import '../services/ride_service.dart';
import 'ride_detail_page.dart';

class RideHistoryPage extends StatefulWidget {
  const RideHistoryPage({super.key});

  @override
  State<RideHistoryPage> createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage> {
  final RideService _rideService = RideService();
  final ScrollController _scrollController = ScrollController();
  
  List<RideRecord> _rideHistory = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  int _currentPage = 1;
  int _totalCount = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // 滾動到底部前200像素時開始加載
      if (!_isLoadingMore && _rideHistory.length < _totalCount) {
        _loadMoreHistory();
      }
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });

    final result = await _rideService.getHistory(page: 1, pageSize: _pageSize);

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _rideHistory = result['cases'] as List<RideRecord>;
        _totalCount = result['total_count'] ?? 0;
        _currentPage = result['page'] ?? 1;
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  Future<void> _loadMoreHistory() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = _currentPage + 1;
    final result = await _rideService.getHistory(page: nextPage, pageSize: _pageSize);

    setState(() {
      _isLoadingMore = false;
      if (result['success'] == true) {
        final newCases = result['cases'] as List<RideRecord>;
        _rideHistory.addAll(newCases);
        _currentPage = nextPage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.rideHistoryTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // History List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadHistory,
                              child: Text(AppLocalizations.of(context)!.retry),
                            ),
                          ],
                        ),
                      )
                    : _rideHistory.isEmpty
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
                                  AppLocalizations.of(context)!.noRideHistory,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _rideHistory.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < _rideHistory.length) {
                                return _buildRideCard(_rideHistory[index]);
                              } else {
                                // 加載更多指示器
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
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
                      _formatDate(ride.createDateTime),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Pickup Address
                    Text(
                      ride.onAddress,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      color: _getStatusColor(ride.caseState).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ride.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(ride.caseState),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Fare
                  Text(
                    ride.caseMoney != null 
                        ? 'NT\$ ${ride.caseMoney!.toStringAsFixed(0)}'
                        : '-',
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
    // Add 8 hours for UTC+8 timezone
    final localDate = date.add(const Duration(hours: 8));
    
    // Format as YYYYMMDD HH:mm
    final year = localDate.year.toString();
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    
    return '$year/$month/$day $hour:$minute';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'finished':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'wait':
      case 'dispatching':
        return Colors.orange;
      case 'way_to_catch':
      case 'arrived':
      case 'catched':
      case 'on_road':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

