import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../navbar.dart';
import '../colors.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_date_picker.dart';
import '../widgets/custom_time_picker.dart';
import '../widgets/custom_app_bar.dart';

class ETempahanScreen extends StatefulWidget {
  const ETempahanScreen({super.key});

  @override
  State<ETempahanScreen> createState() => _ETempahanScreenState();
}

class _ETempahanScreenState extends State<ETempahanScreen> {
  int _selectedIndex = 0;
  late Box eTempahanBox;
  bool isBoxReady = false;

  List<Map<String, dynamic>> bookings = [];
  String? selectedCategory;
  String? selectedFacility;
  DateTime? bookingDate;
  TimeOfDay? bookingTime;
  String? selectedLokasi;

  final List<Map<String, dynamic>> categories = [
    {'label': 'Dewan', 'icon': Icons.home, 'color': Colors.red},
    {'label': 'Padang', 'icon': Icons.sports_soccer, 'color': Colors.green},
    {'label': 'Auditorium', 'icon': Icons.meeting_room, 'color': Colors.blue},
    {'label': 'Gelanggang', 'icon': Icons.sports_basketball, 'color': Colors.amber},
  ];

  final Map<String, List<String>> facilityOptions = {
    'Dewan': ['Dewan Utama', 'Dewan Kecil'],
    'Padang': ['Padang Besar', 'Padang Kecil'],
    'Auditorium': ['Auditorium 1', 'Auditorium 2'],
    'Gelanggang': ['Gelanggang Utama', 'Gelanggang Samping'],
  };

  List<String> currentFacilityOptions = [];
  bool isEditing = false;
  bool isCreating = true;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    selectedCategory = 'Dewan';
    currentFacilityOptions = facilityOptions[selectedCategory] ?? [];
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
    final storedData = eTempahanBox.get('bookings', defaultValue: <String, List<Map<String, dynamic>>>{});
    if (storedData is Map<String, dynamic>) {
      final categoryBookings = storedData[selectedCategory];
      if (categoryBookings is List<dynamic>) {
        bookings = categoryBookings.map((item) {
          final mapItem = Map<String, dynamic>.from(item);
          if (mapItem['date'] is String) {
            mapItem['date'] = DateTime.parse(mapItem['date']);
          }
          return mapItem;
        }).toList();
      } else {
        bookings = [];
      }
    } else {
      bookings = [];
    }

    setState(() {
      isCreating = bookings.isEmpty;
    });
  }

  void _saveBookings() {
    final currentData = eTempahanBox.get('bookings', defaultValue: <String, List<Map<String, dynamic>>>{});
    final updatedData = currentData is Map<String, dynamic>
        ? {...currentData, selectedCategory!: bookings}
        : {selectedCategory!: bookings};

    eTempahanBox.put('bookings', updatedData);
  }

  void _submitBooking() {
    if (selectedFacility == null || bookingDate == null || bookingTime == null || selectedLokasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    final formattedTime = bookingTime!.format(context);

    final newBooking = {
      'facility': selectedFacility!,
      'date': bookingDate!.toIso8601String(),
      'time': formattedTime,
      'location': selectedLokasi!,
      'status': 'Pending',
      'createdDate': DateTime.now().toIso8601String(),
    };

    if (isEditing && editingIndex != null) {
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
  }

  void _resetForm() {
    selectedFacility = null;
    bookingDate = null;
    bookingTime = null;
    selectedLokasi = null;
    currentFacilityOptions = [];
    isEditing = false;
    editingIndex = null;
  }

  void _deleteBooking(int index) {
    setState(() {
      bookings.removeAt(index);
    });
    _saveBookings();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking deleted successfully.')),
    );
  }

  void _editBooking(int index) {
    final booking = bookings[index];
    setState(() {
      selectedFacility = booking['facility'];
      bookingDate = booking['date'] is DateTime
          ? booking['date']
          : DateTime.parse(booking['date']);
      bookingTime = TimeOfDay(
        hour: int.parse(booking['time'].split(':')[0]),
        minute: int.parse(booking['time'].split(':')[1]),
      );
      selectedLokasi = booking['location'];
      editingIndex = index;
      isEditing = true;
      isCreating = true;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      currentFacilityOptions = facilityOptions[category] ?? [];
      _loadBookings();
      isCreating = bookings.isEmpty;
    });
  }

  void _startCreating() {
    setState(() {
      isCreating = true;
      isEditing = false;
      _resetForm();
    });
  }

  void _refreshStatus() {
    _loadBookings();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status refreshed successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCategoryCards(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startCreating,
                    icon: const Text('  ➕', style: TextStyle(fontSize: 18.0)),
                    label: Text(
                      'Add Application',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshStatus,
                    icon: const Text('🔄', style: TextStyle(fontSize: 18.0)),
                    label: Text(
                      'Refresh Status',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isCreating
                ? _buildBookingFormWidget()
                : _buildBookingsList(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildCategoryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = selectedCategory == category['label'];
            return GestureDetector(
              onTap: () => _selectCategory(category['label']),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : category['color'],
                  borderRadius: BorderRadius.circular(12.0),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      category['icon'],
                      color: isSelected ? AppColors.textPrimary : Colors.white,
                      size: 36.0,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      category['label'],
                      style: GoogleFonts.poppins(
                        color: isSelected ? AppColors.primary : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: bookings.asMap().entries.map((entry) {
          final index = entry.key;
          final booking = entry.value;

          final statusText = booking['status'] == 'approved'
              ? 'Diluluskan ✅'
              : booking['status'] == 'rejected'
              ? 'Ditolak ❌'
              : 'Menunggu ⌛';
          final statusColor = booking['status'] == 'approved'
              ? Colors.green
              : booking['status'] == 'rejected'
              ? Colors.red
              : Colors.orange;

          final displayDate = booking['date'] is DateTime
              ? _formatDate(booking['date'])
              : _formatDate(DateTime.parse(booking['date']));

          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15.0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kemudahan: ${booking['facility']}'),
                Text('Tarikh: $displayDate'),
                Text('Masa: ${booking['time']}'),
                Text('Lokasi: ${booking['location']}'),
                Text('Status: $statusText', style: TextStyle(color: statusColor)),
                if (booking['status'] == 'Pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editBooking(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteBooking(index),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  Widget _buildBookingFormWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Ubah Tempahan untuk $selectedCategory' : 'Tempahan untuk $selectedCategory',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16.0),
            CustomDropdown(
              label: 'Kemudahan',
              items: currentFacilityOptions,
              value: selectedFacility,
              onChanged: (val) => setState(() => selectedFacility = val),
            ),
            const SizedBox(height: 16.0),
            CustomDatePicker(
              label: 'Tarikh Tempahan',
              selectedDate: bookingDate,
              onDateSelected: (date) => setState(() => bookingDate = date),
            ),
            const SizedBox(height: 16.0),
            CustomTimePicker(
              label: 'Masa Tempahan',
              selectedTime: bookingTime,
              onTimeSelected: (time) => setState(() => bookingTime = time),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Lokasi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) => setState(() => selectedLokasi = value),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 40.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  isEditing ? 'Simpan Tempahan' : 'Hantar Tempahan',
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
  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () async {
          // If editing/creating, revert to list, else pop
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
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
      title: Text(
        'e-Tempahan 🏢',
        style: GoogleFonts.poppins(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      centerTitle: true,
    );
  }

}
