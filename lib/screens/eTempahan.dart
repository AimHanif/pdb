// screens/e_tempahan_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../navbar.dart';
import '../colors.dart';

// Import the custom widgets
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_date_picker.dart';
import '../widgets/custom_time_picker.dart'; // Newly added
import '../widgets/custom_file_upload_button.dart';
import '../widgets/format_date.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/booking_list.dart';

class ETempahanScreen extends StatefulWidget {
  const ETempahanScreen({Key? key}) : super(key: key);

  @override
  State<ETempahanScreen> createState() => _ETempahanScreenState();
}

class _ETempahanScreenState extends State<ETempahanScreen> {
  int _selectedIndex = 0;
  late Box eTempahanBox;
  bool isBoxReady = false;

  List<Map<String, dynamic>> bookings = [];

  String? selectedFacility; // Kemudahan yang ditempah
  DateTime? bookingDate; // Tarikh Tempahan
  TimeOfDay? bookingTime; // Masa Tempahan (Changed to TimeOfDay)
  String? selectedLokasi; // Selected Lokasi
  // String? location; // Lokasi (Assuming it's a separate field; adjust if not)

  final List<String> facilityOptions = [
    'Dewan',
    'Padang',
    'Bilik Latihan/Auditorium',
    'Gelanggang'
  ];

  final Map<String, List<String>> facilityLocations = {
    'Dewan': ['Dewan Utama', 'Dewan Kecil'],
    'Padang': ['Padang Besar', 'Padang Kecil'],
    'Bilik Latihan/Auditorium': ['Auditorium 1', 'Auditorium 2'],
    'Gelanggang': ['Gelanggang Utama', 'Gelanggang Samping'],
  };

  List<String> currentLokasiOptions = [];

  bool isEditing = false;
  bool isCreating = false;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    _initHiveData();
  }

  Future<void> _initHiveData() async {
    if (!Hive.isBoxOpen('eTempahanData')) {
      await Hive.openBox('eTempahanData');
    }
    eTempahanBox = Hive.box('eTempahanData');
    _loadBookings();
    setState(() {
      isBoxReady = true;
    });
  }

  void _loadBookings() {
    final storedBookings = eTempahanBox.get('bookings', defaultValue: []);
    if (storedBookings is List) {
      bookings = storedBookings
          .where((booking) => booking is Map)
          .map((booking) => Map<String, dynamic>.from(booking as Map))
          .toList();
    } else {
      bookings = [];
    }
  }

  void _saveBookings() {
    try {
      eTempahanBox.put(
        'bookings',
        bookings.map((booking) => Map<String, dynamic>.from(booking)).toList(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save booking: $e')),
      );
      print('Error saving booking: $e');
    }
  }

  void _submitBooking() {
    print('Selected Facility: $selectedFacility');
    print('Booking Date: $bookingDate');
    print('Booking Time: $bookingTime');
    print('Selected Lokasi: $selectedLokasi');
    // print('Location: $location'); // Not used in Solution 1

    if (selectedFacility == null ||
        bookingDate == null ||
        bookingTime == null ||
        selectedLokasi == null ||
        selectedLokasi!.isEmpty) { // Removed location checks
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sila lengkapkan semua maklumat yang diperlukan sebelum meneruskan.')),
      );
      return;
    }

    // Convert TimeOfDay to String for storage
    final String formattedTime = bookingTime!.format(context);

    final newBooking = {
      'selectedFacility': selectedFacility,
      'bookingDate': bookingDate!.toIso8601String(),
      'bookingTime': formattedTime, // Store as formatted string
      'selectedLokasi': selectedLokasi, // Capture Lokasi
      // 'location': location, // Optional, remove if not needed
      'status': 'Pending',
      'bookingDateTime': DateTime.now(),
    };

    if (isEditing && editingIndex != null) {
      final booking = bookings[editingIndex!];
      if (booking['status'] != 'Pending') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can only edit pending bookings.')),
        );
        return;
      }
      bookings[editingIndex!] = newBooking;
    } else {
      bookings.add(newBooking);
    }

    _saveBookings();
    _resetForm();
    setState(() {
      isCreating = false;
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking submitted successfully!')),
    );
  }

  void _resetForm() {
    selectedFacility = null;
    bookingDate = null;
    bookingTime = null;
    selectedLokasi = null;
    // location = null; // Removed in Solution 1
    currentLokasiOptions = [];
    isEditing = false;
    editingIndex = null;
  }

  void _refreshStatus() {
    _loadBookings();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All statuses refreshed!')),
    );
    setState(() {});
  }

  void _deleteBooking(int index) {
    bookings.removeAt(index);
    _saveBookings();
    setState(() {});
  }

  void _editBooking(int index) {
    final booking = bookings[index];
    if (booking['status'] != 'Pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only edit pending bookings.')),
      );
      return;
    }
    setState(() {
      selectedFacility = booking['selectedFacility'];
      bookingDate = DateTime.parse(booking['bookingDate']);
      // Parse the stored formatted time back to TimeOfDay
      final parsedTime = _parseTimeOfDay(booking['bookingTime']);
      bookingTime = parsedTime;
      selectedLokasi = booking['selectedLokasi'];
      // location = booking['location']; // Removed in Solution 1
      currentLokasiOptions = facilityLocations[selectedFacility] ?? [];
      isEditing = true;
      isCreating = false;
      editingIndex = index;
    });
  }

  // Helper method to parse time string to TimeOfDay
  TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final format = DateFormat.jm(); // Example: 5:08 PM
      final dateTime = format.parse(timeString);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      print('Error parsing time: $e');
      return null;
    }
  }

  void _startCreating() {
    _resetForm();
    isCreating = true;
    isEditing = false;
    setState(() {});
  }

  // Since location is optional, you can remove this method
  /*
  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      location = result.files.single.path;
      setState(() {});
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _onWillPop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'e-Tempahan',
          onLeadingPressed: () {
            if (isEditing || isCreating) {
              setState(() {
                isEditing = false;
                isCreating = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _buildContent(),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isCreating || isEditing || bookings.isEmpty) {
      return _buildBookingFormWidget();
    }
    return Stack(
      children: [
        BookingList(
          bookings: bookings,
          onEdit: _editBooking,
          onDelete: _deleteBooking,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startCreating,
                    icon: Icon(Icons.add, size: 18.0, color: AppColors.textPrimary),
                    label: Text(
                      'Add Booking',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshStatus,
                    icon: Icon(Icons.refresh, size: 18.0, color: AppColors.textPrimary),
                    label: Text(
                      'Refresh Status',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingFormWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: _whiteCardDecoration(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Your Booking 🏢' : 'Submit Your Booking 🏢',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Kemudahan
            CustomDropdown(
              label: 'Kemudahan',
              items: facilityOptions,
              value: selectedFacility,
              onChanged: (val) {
                setState(() {
                  selectedFacility = val;
                  // Update Lokasi options based on selected Kemudahan
                  currentLokasiOptions = facilityLocations[val] ?? [];
                  selectedLokasi = null; // Reset selected Lokasi
                });
              },
            ),
            const SizedBox(height: 16.0),
            // Using CustomDatePicker for Tarikh Tempahan
            CustomDatePicker(
              label: 'Tarikh Tempahan',
              selectedDate: bookingDate,
              onDateSelected: (date) => setState(() => bookingDate = date),
            ),
            const SizedBox(height: 16.0),
            // Using CustomTimePicker for Masa Tempahan
            CustomTimePicker(
              label: 'Masa Tempahan ⏰',
              selectedTime: bookingTime,
              onTimeSelected: (time) => setState(() => bookingTime = time),
            ),
            const SizedBox(height: 16.0),
            // Using CustomDropdown for Lokasi
            CustomDropdown(
              label: 'Lokasi',
              items: currentLokasiOptions,
              value: selectedLokasi,
              onChanged: (val) => setState(() => selectedLokasi = val),
            ),
            const SizedBox(height: 16.0),
            // Using CustomFileUploadButton for Lokasi (Optional - Solution 2)
            /*
            CustomFileUploadButton(
              label: 'Dokumen Lokasi 📍',
              fileInfo: location != null ? location!.split('/').last : null,
              onTap: _pickDocuments,
              iconData: Icons.location_on,
              multiple: false,
            ),
            */
            const SizedBox(height: 24.0),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Submit Booking',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buttonText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return BookingList(
      bookings: bookings,
      onEdit: _editBooking,
      onDelete: _deleteBooking,
    );
  }

  BoxDecoration _whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 15.0,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    // If editing or creating, revert to list view
    if (isEditing || isCreating) {
      setState(() {
        isEditing = false;
        isCreating = false;
      });
      return false; // Don't pop
    }
    return true; // Pop if not editing/creating
  }
}
