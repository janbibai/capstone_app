import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/service.dart';
import '../services/api_service.dart';
import '../widgets/step_indicator.dart';
import '../widgets/time_slot_grid.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Service service;

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ApiService _apiService = ApiService();
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1 — Date & Time
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<String> _bookedSlots = [];
  bool _loadingSlots = false;

  // Step 2 — Patient Info
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  DateTime? _dateOfBirth;
  String _gender = 'male';
  XFile? _validIdFile;
  List<int>? _validIdBytes;

  // Step 3 — Submission
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadBookedSlots(DateTime date) async {
    setState(() => _loadingSlots = true);
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final booked = await _apiService.fetchBookedTimes(dateStr);
      setState(() {
        _bookedSlots = booked;
        _loadingSlots = false;
        // Reset selected slot if it's now booked
        if (_selectedTimeSlot != null &&
            _bookedSlots.contains(_selectedTimeSlot)) {
          _selectedTimeSlot = null;
        }
      });
    } catch (e) {
      setState(() => _loadingSlots = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading slots: $e')));
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Select appointment date',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset time when date changes
      });
      await _loadBookedSlots(picked);
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: now.subtract(const Duration(days: 1)),
      helpText: 'Select date of birth',
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _pickValidId() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _validIdFile = image;
          _validIdBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not pick image: $e')));
      }
    }
  }

  Future<void> _submitBooking() async {
    setState(() => _isSubmitting = true);
    try {
      final dateStr =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      final dobStr =
          '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}';

      final result = await _apiService.bookAppointment(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        middleName: _middleNameCtrl.text.trim().isEmpty
            ? null
            : _middleNameCtrl.text.trim(),
        serviceId: widget.service.id,
        schedule: dateStr,
        scheduleTime: _selectedTimeSlot!,
        dateOfBirth: dobStr,
        gender: _gender,
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        validIdBytes: _validIdBytes,
        validIdFilename: _validIdFile?.name,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(
              bookingData: result,
              service: widget.service,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime date) {
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

  String _formatTo12Hour(String time24) {
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.service.name),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          StepIndicator(currentStep: _currentStep),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1DateAndTime(),
                _buildStep2PatientInfo(),
                _buildStep3Confirmation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: Date & Time ─────────────────────────────────────────────
  Widget _buildStep1DateAndTime() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_rounded),
              label: Text(
                _selectedDate != null
                    ? _formatDate(_selectedDate!)
                    : 'Tap to pick a date',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_selectedDate != null) ...[
            Text(
              'Select Time',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Grey slots are already booked.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            if (_loadingSlots)
              const Center(child: CircularProgressIndicator())
            else
              TimeSlotGrid(
                bookedSlots: _bookedSlots,
                selectedSlot: _selectedTimeSlot,
                onSlotSelected: (slot) {
                  setState(() => _selectedTimeSlot = slot);
                },
              ),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedDate != null && _selectedTimeSlot != null)
                  ? () => _goToStep(1)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Next: Patient Information'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 2: Patient Info ────────────────────────────────────────────
  Widget _buildStep2PatientInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // First name
            TextFormField(
              controller: _firstNameCtrl,
              decoration: _inputDecoration('First Name *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Middle name (optional)
            TextFormField(
              controller: _middleNameCtrl,
              decoration: _inputDecoration('Middle Name (optional)'),
            ),
            const SizedBox(height: 12),

            // Last name
            TextFormField(
              controller: _lastNameCtrl,
              decoration: _inputDecoration('Last Name *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Date of birth
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickDateOfBirth,
                icon: const Icon(Icons.cake_rounded, size: 18),
                label: Text(
                  _dateOfBirth != null
                      ? 'Date of Birth: ${_formatDate(_dateOfBirth!)}'
                      : 'Select Date of Birth *',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Gender
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: _inputDecoration('Gender *'),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _gender = v);
              },
            ),
            const SizedBox(height: 12),

            // Phone
            TextFormField(
              controller: _phoneCtrl,
              decoration: _inputDecoration('Phone *'),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
            ),
            const SizedBox(height: 12),

            // Email (optional)
            TextFormField(
              controller: _emailCtrl,
              decoration: _inputDecoration('Email (optional)'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            // Address
            TextFormField(
              controller: _addressCtrl,
              decoration: _inputDecoration('Address *'),
              maxLines: 2,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Address is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // Valid ID upload
            Text(
              'Valid ID (Required)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickValidId,
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: Text(
                _validIdFile != null
                    ? _validIdFile!.name
                    : 'Upload ID photo (JPEG/PNG)',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _goToStep(0),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      final formValid = _formKey.currentState!.validate();
                      if (formValid && _dateOfBirth != null && _validIdFile != null) {
                        _goToStep(2);
                      } else {
                        if (_dateOfBirth == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select your date of birth.'),
                            ),
                          );
                        }
                        if (_validIdFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please upload a valid ID.'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Next: Review & Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 3: Confirmation ────────────────────────────────────────────
  Widget _buildStep3Confirmation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Booking',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _reviewRow('Service', widget.service.name),
                  if (widget.service.department != null)
                    _reviewRow('Department', widget.service.department!.name),
                  _reviewRow(
                    'Date',
                    _selectedDate != null ? _formatDate(_selectedDate!) : '',
                  ),
                  _reviewRow(
                    'Time',
                    _selectedTimeSlot != null
                        ? _formatTo12Hour(_selectedTimeSlot!)
                        : '',
                  ),
                  const Divider(height: 24),
                  _reviewRow(
                    'Name',
                    [
                      _firstNameCtrl.text,
                      _middleNameCtrl.text,
                      _lastNameCtrl.text,
                    ].where((s) => s.trim().isNotEmpty).join(' '),
                  ),
                  _reviewRow(
                    'Date of Birth',
                    _dateOfBirth != null ? _formatDate(_dateOfBirth!) : '',
                  ),
                  _reviewRow(
                    'Gender',
                    _gender[0].toUpperCase() + _gender.substring(1),
                  ),
                  if (_phoneCtrl.text.isNotEmpty)
                    _reviewRow('Phone', _phoneCtrl.text),
                  if (_emailCtrl.text.isNotEmpty)
                    _reviewRow('Email', _emailCtrl.text),
                  if (_addressCtrl.text.isNotEmpty)
                    _reviewRow('Address', _addressCtrl.text),
                  if (_validIdFile != null)
                    _reviewRow('ID Uploaded', _validIdFile!.name),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => _goToStep(1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(_isSubmitting ? 'Booking...' : 'Confirm Booking'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
