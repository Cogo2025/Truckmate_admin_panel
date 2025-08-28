import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_models.dart';
import '../widgets/admin_drawer.dart';

class OwnersScreen extends StatefulWidget {
  const OwnersScreen({Key? key}) : super(key: key);

  @override
  State<OwnersScreen> createState() => _OwnersScreenState();
}

class _OwnersScreenState extends State<OwnersScreen> {
  final ApiService _apiService = ApiService();
  List<Owner> _owners = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  Future<void> _loadOwners() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final owners = await _apiService.getAllOwners();
      setState(() {
        _owners = owners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is Exception ? e.toString() : 'An unknown error occurred';
        _isLoading = false;
      });
      debugPrint('Error loading owners: $_error');
    }
  }

  List<Owner> get _filteredOwners {
    List<Owner> filtered = _owners;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((owner) {
        return owner.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            owner.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (owner.phone?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (owner.profile?.companyName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }
    switch (_selectedFilter) {
      case 'Profile Complete':
        filtered = filtered.where((owner) => owner.profile?.companyInfoCompleted == true).toList();
        break;
      case 'Profile Incomplete':
        filtered = filtered.where((owner) => owner.profile?.companyInfoCompleted != true).toList();
        break;
      case 'Has Company':
        filtered = filtered.where((owner) => owner.profile?.companyName != null && owner.profile!.companyName!.isNotEmpty).toList();
        break;
      case 'No Company':
        filtered = filtered.where((owner) => owner.profile?.companyName == null || owner.profile!.companyName!.isEmpty).toList();
        break;
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Owners Management'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOwners,
          ),
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
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: theme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search owners...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.5)),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.5)),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Owners')),
                      DropdownMenuItem(value: 'Profile Complete', child: Text('Profile Complete')),
                      DropdownMenuItem(value: 'Profile Incomplete', child: Text('Profile Incomplete')),
                      DropdownMenuItem(value: 'Has Company', child: Text('Has Company')),
                      DropdownMenuItem(value: 'No Company', child: Text('No Company Info')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
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
                _buildStatCard(
                  'Total Owners',
                  _owners.length.toString(),
                  Icons.business,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'With Companies',
                  _owners.where((o) => o.profile?.companyName != null && o.profile!.companyName!.isNotEmpty).length.toString(),
                  Icons.domain,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Profile Complete',
                  _owners.where((o) => o.profile?.companyInfoCompleted == true).length.toString(),
                  Icons.check_circle,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Filtered Results',
                  _filteredOwners.length.toString(),
                  Icons.filter_list,
                  Colors.purple,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadOwners,
              color: theme.primaryColor,
              backgroundColor: const Color(0xFF1A1A2E),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red[800]!,
                                      Colors.red[600]!,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.5),
                                      blurRadius: 15,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.error,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error: $_error',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.primaryColor,
                                      theme.primaryColor.withOpacity(0.8),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.primaryColor.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _loadOwners,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _filteredOwners.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.grey[800]!,
                                          Colors.grey[600]!,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.business_center,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No owners found',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredOwners.length,
                              itemBuilder: (context, index) {
                                final owner = _filteredOwners[index];
                                return _buildOwnerCard(owner);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
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
                spreadRadius: 0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
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
                        spreadRadius: 0,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerCard(Owner owner) {
    final photoUrl = owner.photoUrl ?? owner.profile?.photoUrl;
    final isProfileComplete = owner.profile?.companyInfoCompleted == true;
    final primaryColor = Colors.orange;
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: primaryColor.withOpacity(0.2),
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty 
                ? NetworkImage(photoUrl) 
                : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? Text(
                    owner.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  )
                : null,
          ),
          title: Text(
            owner.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                owner.email,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (owner.profile?.companyName != null && owner.profile!.companyName!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        border: Border.all(color: Colors.blue.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        owner.profile!.companyName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[200],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isProfileComplete ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      border: Border.all(
                        color: isProfileComplete ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isProfileComplete ? 'Profile Complete' : 'Profile Incomplete',
                      style: TextStyle(
                        fontSize: 12,
                        color: isProfileComplete ? Colors.green[200] : Colors.red[200],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photoUrl != null && photoUrl.isNotEmpty) ...[
                    const Text(
                      'Photos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPhotoRow(context, photoUrl),
                    const SizedBox(height: 16),
                  ],
                  _buildInfoRow('Phone', owner.phone ?? 'Not provided'),
                  _buildInfoRow('Google ID', owner.googleId),
                  _buildInfoRow('Joined Date', _formatDate(owner.createdAt)),
                  if (owner.profile != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Profile Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Company Name', owner.profile!.companyName ?? 'Not specified'),
                    _buildInfoRow('Company Location', owner.profile!.companyLocation ?? 'Not specified'),
                    _buildInfoRow('Gender', owner.profile!.gender ?? 'Not specified'),
                    _buildInfoRow('Company Info Status', isProfileComplete ? 'Completed' : 'Not Completed'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoRow(BuildContext context, String photoUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FullscreenPhotoViewer(imageUrl: photoUrl),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(photoUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}