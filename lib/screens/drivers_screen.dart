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
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((d) {
        return d.name.toLowerCase().contains(lowerQuery) ||
            d.email.toLowerCase().contains(lowerQuery) ||
            (d.phone?.toLowerCase().contains(lowerQuery) ?? false);
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
            side: BorderSide(color: color.withOpacity(0.3), width: 1)),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 0),
                )
              ]),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      )
                    ]),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text(title,
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationChip(String? status) {
    final st = (status ?? 'pending').toLowerCase();
    Color color;
    String text;
    switch (st) {
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showCopyButton = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(
                '$label:',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
              )),
          Expanded(
              child: Text(
            value,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          )),
          if (showCopyButton && value != 'N/A')
            InkWell(
              onTap: () async {
                // Clipboard copy functionality, optional
              },
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.copy, size: 16, color: Colors.blue),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildDocumentThumbnail(BuildContext context, String imageUrl, String label) {
    if (imageUrl.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FullscreenPhotoViewer(imageUrl: imageUrl),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 140,
                  width: 140,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.7)])),
                  child: Center(
                    child: Icon(Icons.zoom_in, size: 32, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard(Driver driver) {
    final profile = driver.profile;
    final verificationStatus = profile?.verificationStatus ?? 'pending';
    final isVerified = verificationStatus.toLowerCase() == 'approved';

    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isVerified ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
              width: 1)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
                colors: [Color(0xFF1A1A22), Color(0xFF16161E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            boxShadow: [
              BoxShadow(
                  color: isVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  blurRadius: 10)
            ]),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blueGrey.withOpacity(0.7),
            backgroundImage:
                (profile?.profilePhoto != null && profile!.profilePhoto!.isNotEmpty)
                    ? NetworkImage(profile.profilePhoto!)
                    : null,
            child: (profile?.profilePhoto == null || profile!.profilePhoto!.isEmpty)
                ? Text(driver.name[0].toUpperCase(),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                : null,
          ),
          title: Text(
            driver.name,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
          ),
          subtitle: Row(
            children: [
              Expanded(
                  child:
                      Text(driver.email, style: TextStyle(color: Colors.white70, fontSize: 12))),
              _buildVerificationChip(verificationStatus),
            ],
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile != null) ...[
                    _buildInfoRow('Phone', driver.phone ?? 'Not provided'),
                    _buildInfoRow('License Number', profile.licenseNumber ?? 'N/A', showCopyButton: true),
                    _buildInfoRow('Experience', profile.experience ?? 'N/A'),
                    _buildInfoRow('Location', profile.location ?? 'N/A'),
                    _buildInfoRow('Gender', profile.gender ?? 'N/A'),
                    _buildInfoRow('Age', profile.age?.toString() ?? 'N/A'),
                    if (profile.knownTruckTypes != null && profile.knownTruckTypes!.isNotEmpty)
                      _buildInfoRow('Truck Types', profile.knownTruckTypes!.join(', ')),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      alignment: WrapAlignment.start,
                      children: [
                        if (profile.profilePhoto != null && profile.profilePhoto!.isNotEmpty)
                          _buildDocumentThumbnail(context, profile.profilePhoto!, 'Profile Photo'),
                        if (driver.licensePhotoFront != null && driver.licensePhotoFront!.isNotEmpty)
                          _buildDocumentThumbnail(context, driver.licensePhotoFront!, 'License Front'),
                        if (driver.licensePhotoBack != null && driver.licensePhotoBack!.isNotEmpty)
                          _buildDocumentThumbnail(context, driver.licensePhotoBack!, 'License Back'),
                      ],
                    )
                  ] else
                    Text(
                      'Profile not completed',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text('Drivers Management'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _loadDrivers,
          )
        ],
      ),
      drawer: AdminDrawer(),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.primaryColor.withOpacity(0.3))),
                gradient: LinearGradient(
                    colors: [Color(0xFF1A1A1A), Color(0xFF16161F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                        hintText: 'Search drivers...',
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.primaryColor)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.5)))),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    items: [
                      DropdownMenuItem(child: Text('All'), value: 'All'),
                      DropdownMenuItem(child: Text('Active'), value: 'Active'),
                      DropdownMenuItem(child: Text('Inactive'), value: 'Inactive'),
                      DropdownMenuItem(child: Text('Profile Complete'), value: 'Profile Complete'),
                      DropdownMenuItem(child: Text('Profile Incomplete'), value: 'Profile Incomplete'),
                    ],
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedFilter = val;
                        });
                      }
                    },
                    style: TextStyle(color: Colors.white),
                    dropdownColor: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildStatCard('Total', _drivers.length.toString(), Icons.directions_car, Colors.blue),
                SizedBox(width: 12),
                _buildStatCard(
                    'Active', _drivers.where((d) => d.isAvailable).length.toString(), Icons.check_circle, Colors.green),
                SizedBox(width: 12),
                _buildStatCard('Profiles', _drivers.where((d) => d.profile != null).length.toString(),
                    Icons.person_outline, Colors.orange),
                SizedBox(width: 12),
                _buildStatCard('Filtered', _filteredDrivers.length.toString(), Icons.filter_alt, Colors.purple),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: theme.primaryColor,
              onRefresh: _loadDrivers,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                            SizedBox(height: 12),
                            Text(_error ?? 'Error loading drivers',
                                style: TextStyle(color: Colors.redAccent)),
                            SizedBox(height: 12),
                            ElevatedButton(
                                onPressed: _loadDrivers,
                                child: Text('Retry'))
                          ],
                        ))
                      : _filteredDrivers.isEmpty
                          ? Center(
                              child: Text('No drivers found.', style: TextStyle(color: Colors.white54)),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _filteredDrivers.length,
                              itemBuilder: (ctx, i) => _buildDriverCard(_filteredDrivers[i]),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

// Fullscreen image viewer for showing documents/photos
class FullscreenPhotoViewer extends StatelessWidget {
  final String imageUrl;
  const FullscreenPhotoViewer({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4.0,
          minScale: 0.5,
          child: Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (ctx, err, stack) {
            return Center(
                child: Text(
              'Failed to load image',
              style: TextStyle(color: Colors.white70),
            ));
          }),
        ),
      ),
    );
  }
}
