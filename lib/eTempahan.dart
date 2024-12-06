import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'navbar.dart';
import 'colors.dart';

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
  String? bookingDate; // Tarikh Tempahan
  String? bookingTime; // Masa Tempahan
  String? location; // Lokasi

  final List<String> facilityOptions = [
    'Dewan',
    'Padang',
    'Bilik Latihan/Auditorium',
    'Gelanggang'
  ];

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
    bookings = List<Map<String, dynamic>>.from(storedBookings);
  }

  void _saveBookings() {
    eTempahanBox.put('bookings', bookings);
  }

  void _submitBooking() {
    if (selectedFacility == null || bookingDate == null || bookingTime == null || location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sila lengkapkan semua maklumat yang diperlukan sebelum meneruskan.')),
      );
      return;
    }

    final newBooking = {
      'selectedFacility': selectedFacility,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'location': location,
      'status': 'Pending',
      'bookingDateTime': DateTime.now(),
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
    location = null;
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
    selectedFacility = booking['selectedFacility'];
    bookingDate = booking['bookingDate'];
    bookingTime = booking['bookingTime'];
    location = booking['location'];
    isEditing = true;
    isCreating = false;
    editingIndex = index;
    setState(() {});
  }

  void _startCreating() {
    _resetForm();
    isCreating = true;
    isEditing = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildContent(),
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

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
      title: Text(
        'e-Tempahan',
        style: GoogleFonts.poppins(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      centerTitle: true,
    );
  }

  Widget _buildContent() {
    if (isCreating || isEditing || bookings.isEmpty) {
      return _buildBookingFormWidget();
    }
    return Stack(
      children: [
        _buildBookingsList(),
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
                    icon: Icon(Icons.add, size: 18.0),
                    label: Text(
                      'Add Booking',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
                    icon: Icon(Icons.refresh, size: 18.0),
                    label: Text(
                      'Refresh Status',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
            _buildDropdownField('Kemudahan', facilityOptions, (val) => setState(() => selectedFacility = val), selectedFacility),
            const SizedBox(height: 16.0),
            _buildTextField('Tarikh Tempahan', (val) => setState(() => bookingDate = val), bookingDate),
            const SizedBox(height: 16.0),
            _buildTextField('Masa Tempahan', (val) => setState(() => bookingTime = val), bookingTime),
            const SizedBox(height: 16.0),
            _buildTextField('Lokasi', (val) => setState(() => location = val), location),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Submit Booking',
                  style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.bold, color: AppColors.buttonText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Bookings 🏟',
            style: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16.0),
          ...bookings.asMap().entries.map((entry) {
            final index = entry.key;
            final booking = entry.value;
            return _buildBookingCard(booking, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
    String statusText;
    Color statusColor;

    switch (booking['status'].toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Approved ✅';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected ❌';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pending ⌛';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: _whiteCardDecoration(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Kemudahan', booking['selectedFacility']),
          _buildInfoRow('Tarikh Tempahan', booking['bookingDate']),
          _buildInfoRow('Masa Tempahan', booking['bookingTime']),
          _buildInfoRow('Lokasi', booking['location']),
          _buildInfoRow('Booking Date', _formatDate(DateTime.parse(booking['bookingDateTime'].toString()))),
          Row(
            children: [
              Text('Status: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
              Text(statusText, style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12.0),
          if (booking['status'] == 'Pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildPopupMenu(index),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(int index) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      onSelected: (value) {
        if (value == 'edit') {
          _editBooking(index);
        } else if (value == 'delete') {
          _deleteBooking(index);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: AppColors.primary),
              const SizedBox(width: 8.0),
              Text('Edit', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 8.0),
              Text('Delete', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, ValueChanged<String?> onChanged, String? currentValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButtonFormField<String>(
            value: currentValue,
            decoration: const InputDecoration(border: InputBorder.none),
            style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textPrimary),
            hint: Text(
              'Pilih $label',
              style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textSecondary.withOpacity(0.8)),
            ),
            items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item, overflow: TextOverflow.ellipsis, maxLines: 1))).toList(),
            onChanged: onChanged,
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, ValueChanged<String?> onChanged, String? currentValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          initialValue: currentValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.4), width: 1.5),
            ),
            hintText: 'Masukkan $label',
            hintStyle: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textSecondary.withOpacity(0.8)),
          ),
          style: GoogleFonts.poppins(fontSize: 14.0, color: AppColors.textPrimary),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
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

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
