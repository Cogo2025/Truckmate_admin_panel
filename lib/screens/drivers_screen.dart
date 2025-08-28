import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_models.dart';
import '../widgets/admin_drawer.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({Key? key}) : super(key: key);

  @override
  State createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final ApiService _apiService = ApiService();
  List<Driver> _drivers = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final drivers = await _apiService.getAllDrivers();
      setState(() {
        _drivers = drivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Driver> get _filteredDrivers {
    List<Driver> filtered = _drivers;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((driver) {
        return driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            driver.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (driver.phone?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    switch (_selectedFilter) {
      case 'Active':
        filtered = filtered.where((d) => d.isAvailable).toList();
        break;
      case 'Inactive':
        filtered = filtered.where((d) => !d.isAvailable).toList();
        break;
      case 'Profile Complete':
        filtered = filtered.where((d) => d.profile != null).toList();
        break;
      case 'Profile Incomplete':
        filtered = filtered.where((d) => d.profile == null).toList();
        break;
      default:
        break;
    }
    return filtered;
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationChip(String status) {
    Color color;
    String text;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        text = 'Verified';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.orange;
        text = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), border: Border.all(color: color.withOpacity(0.5)), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildPhotoRow(BuildContext context, String? profilePhoto, String? licenseFront, String? licenseBack) {
    if (profilePhoto == null && licenseFront == null && licenseBack == null) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (profilePhoto != null)
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullscreenPhotoViewer(imageUrl: profilePhoto))),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Image.network(profilePhoto, height: 150, fit: BoxFit.cover),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.7)]),
                          ),
                          child: const Center(child: Icon(Icons.zoom_in, color: Colors.white, size: 40)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Profile Photo', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
        if (profilePhoto != null && (licenseFront != null || licenseBack != null)) const SizedBox(width: 16),
        if (licenseFront != null)
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullscreenPhotoViewer(imageUrl: licenseFront))),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Image.network(licenseFront, height: 150, fit: BoxFit.cover),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.7)]),
                          ),
                          child: const Center(child: Icon(Icons.zoom_in, color: Colors.white, size: 40)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('License Photo (Front)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
        if (licenseFront != null && licenseBack != null) const SizedBox(width: 16),
        if (licenseBack != null)
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullscreenPhotoViewer(imageUrl: licenseBack))),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Image.network(licenseBack, height: 150, fit: BoxFit.cover),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.7)]),
                          ),
                          child: const Center(child: Icon(Icons.zoom_in, color: Colors.white, size: 40)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('License Photo (Back)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Drivers Management'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
            ),
            boxShadow: [
              BoxShadow(color: theme.primaryColor.withOpacity(0.5), blurRadius: 20, offset: Offset(0, 0)),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDrivers),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF16161F)],
              ),
              border: Border(
                bottom: BorderSide(color: theme.primaryColor.withOpacity(0.3), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search drivers...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.primaryColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.5))),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.primaryColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.5))),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Drivers')),
                      DropdownMenuItem(value: 'Active', child: Text('Active Only')),
                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'Profile Complete', child: Text('Profile Complete')),
                      DropdownMenuItem(value: 'Profile Incomplete', child: Text('Profile Incomplete')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedFilter = value);
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatCard('Total Drivers', _drivers.length.toString(), Icons.local_shipping, Colors.blue),
                const SizedBox(width: 16),
                _buildStatCard('Active Drivers', _drivers.where((d) => d.isAvailable).length.toString(), Icons.online_prediction, Colors.green),
                const SizedBox(width: 16),
                _buildStatCard('Profile Complete', _drivers.where((d) => d.profile != null).length.toString(), Icons.check_circle, Colors.orange),
                const SizedBox(width: 16),
                _buildStatCard('Filtered Results', _filteredDrivers.length.toString(), Icons.filter_list, Colors.purple),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDrivers,
              color: theme.primaryColor,
              backgroundColor: const Color(0xFF1A1A1A),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : (_error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [Colors.red[800]!, Colors.red[600]!]),
                                ),
                                child: const Icon(Icons.error, size: 48, color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(onPressed: _loadDrivers, child: const Text('Retry')),
                            ],
                          ),
                        )
                      : (_filteredDrivers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [Colors.grey[800]!, Colors.grey[600]!]),
                                    ),
                                    child: const Icon(Icons.no_accounts, size: 48, color: Colors.white),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('No drivers found', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredDrivers.length,
                              itemBuilder: (context, index) => _buildStatCard(
                                    _filteredDrivers[index].name,
                                    _filteredDrivers[index].email,
                                    Icons.directions_car,
                                    Colors.blue,
                                  )))),
            ),
          ),
        ],
      ),
    );
  }
}

// FullscreenPhotoViewer as implemented earlier
class FullscreenPhotoViewer extends StatelessWidget {
  final String imageUrl;
  const FullscreenPhotoViewer({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(child: Text("Failed to load image", style: TextStyle(color: Colors.white))),
          ),
        ),
      ),
    );
  }
}
