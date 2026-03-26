import 'package:flutter/material.dart';
import '../models/queue_status.dart';
import '../services/api_service.dart';
import 'services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  DateTime _selectedDate = DateTime.now();
  QueueStatus? _queueStatus;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchQueueStatus();
  }

  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchQueueStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final status = await _apiService.fetchQueueStatus(
        _dateToString(_selectedDate),
      );
      setState(() {
        _queueStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Select date to view queue',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF154C9E),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchQueueStatus();
    }
  }

  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'started':
        return const Color(0xFF0D7E4E);
      case 'pending':
        return const Color(0xFFB45309);
      case 'completed':
        return const Color(0xFF154C9E);
      case 'cancelled':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'started':
        return const Color(0xFFECFDF5);
      case 'pending':
        return const Color(0xFFFFFBEB);
      case 'completed':
        return const Color(0xFFEFF6FF);
      case 'cancelled':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'started':
        return 'Now Serving';
      case 'pending':
        return 'Waiting';
      case 'completed':
        return 'Done';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF154C9E),
                      strokeWidth: 2.5,
                    ),
                  )
                : _error != null
                ? _buildError()
                : _buildQueueContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF154C9E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Queue Status',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      _isToday(_selectedDate)
                          ? 'Today · ${_formatShortDate(_selectedDate)}'
                          : _formatShortDate(_selectedDate),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Color(0xFF154C9E),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Change Date',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF154C9E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _fetchQueueStatus,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  minimumSize: const Size(38, 38),
                  maximumSize: const Size(38, 38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ServicesScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'Book an Appointment',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF154C9E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 34,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to load queue',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 160,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _fetchQueueStatus,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF154C9E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueContent() {
    final qs = _queueStatus!;
    return RefreshIndicator(
      onRefresh: _fetchQueueStatus,
      color: const Color(0xFF154C9E),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        children: [
          _buildServingHeroCard(qs),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Queue List',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              if (qs.appointments.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${qs.appointments.length} entries',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF154C9E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (qs.appointments.isEmpty)
            _buildEmptyState()
          else
            ...qs.appointments.map((appt) => _buildQueueTile(appt)),
        ],
      ),
    );
  }

  Widget _buildServingHeroCard(QueueStatus qs) {
    final hasServing = qs.currentServing != null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF154C9E), Color(0xFF1E65CC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF154C9E).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: hasServing
                              ? const Color(0xFF4ADE80)
                              : Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasServing ? 'Live' : 'Inactive',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Currently Serving',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasServing ? qs.currentServing!.queueNumberFormatted : '—',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 54,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.5,
                height: 1,
              ),
            ),
            const SizedBox(height: 10),
            if (hasServing)
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    qs.currentServing!.scheduleTime,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            else
              Text(
                qs.appointments.isEmpty
                    ? 'No appointments scheduled for this date'
                    : 'Queue has not started yet',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 34,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No appointments',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'There are no appointments scheduled\nfor this date.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueTile(QueueAppointment appt) {
    final isServing = appt.status == 'started';
    final color = _statusColor(appt.status);
    final bgColor = _statusBgColor(appt.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isServing
              ? const Color(0xFF154C9E).withOpacity(0.3)
              : const Color(0xFFE2E8F0),
          width: isServing ? 1.5 : 1,
        ),
        boxShadow: isServing
            ? [
                BoxShadow(
                  color: const Color(0xFF154C9E).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isServing
                    ? const Color(0xFF154C9E)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  appt.queueNumber.toString(),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isServing ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appt.queueNumberFormatted,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appt.scheduleTime,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel(appt.status),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
