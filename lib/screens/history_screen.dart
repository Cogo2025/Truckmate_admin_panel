// screens/history_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/admin_drawer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> allRequests = [];
  List<Map<String, dynamic>> filteredRequests = [];
  bool isLoading = true;
  String? error;
  
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  final List<String> _statusFilters = ['all', 'pending', 'approved', 'rejected'];
  final List<String> _tabTitles = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchAllVerifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      _filterRequests(_statusFilters[_currentTabIndex]);
    }
  }

  Future<void> _fetchAllVerifications() async {
  try {
    setState(() {
      isLoading = true;
      error = null;
    });
    
    print('Fetching all verifications...'); // Debug log
    final requests = await _apiService.getAllVerifications();
    print('Received ${requests.length} verification requests'); // Debug log
    
    setState(() {
      allRequests = requests;
      filteredRequests = requests;
      isLoading = false;
    });
    
    // Apply current filter
    _filterRequests(_statusFilters[_currentTabIndex]);
  } catch (e) {
    print('Error fetching verifications: $e'); // Debug log
    setState(() {
      error = 'Failed to load verification history. Please check your connection and try again.\n\nError: ${e.toString()}';
      isLoading = false;
    });
  }
}


  void _filterRequests(String status) {
    setState(() {
      if (status == 'all') {
        filteredRequests = List.from(allRequests);
      } else {
        filteredRequests = allRequests
            .where((request) => request['status'] == status)
            .toList();
      }
      
      // Sort by date (newest first)
      filteredRequests.sort((a, b) {
        DateTime dateA = DateTime.parse(a['createdAt'] ?? a['processedAt'] ?? '');
        DateTime dateB = DateTime.parse(b['createdAt'] ?? b['processedAt'] ?? '');
        return dateB.compareTo(dateA);
      });
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Verification History'),
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
            onPressed: _fetchAllVerifications,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
        ),
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          // Statistics Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
              ),
            ),
            child: _buildStatsSection(),
          ),
          
          // Content Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchAllVerifications,
              color: theme.primaryColor,
              backgroundColor: const Color(0xFF1A1A2E),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHistoryList(), // All
                  _buildHistoryList(), // Pending
                  _buildHistoryList(), // Approved
                  _buildHistoryList(), // Rejected
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final pendingCount = allRequests.where((r) => r['status'] == 'pending').length;
    final approvedCount = allRequests.where((r) => r['status'] == 'approved').length;
    final rejectedCount = allRequests.where((r) => r['status'] == 'rejected').length;

    return Row(
      children: [
        Expanded(child: _buildStatCard('Pending', pendingCount.toString(), Icons.pending_actions, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Approved', approvedCount.toString(), Icons.check_circle, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Rejected', rejectedCount.toString(), Icons.cancel, Colors.red)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (error != null) {
      return _buildErrorState();
    }

    if (filteredRequests.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        final request = filteredRequests[index];
        return _buildHistoryCard(request);
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.red[800]!, Colors.red[600]!]),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: const Icon(Icons.error, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchAllVerifications,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    
    switch (_statusFilters[_currentTabIndex]) {
      case 'pending':
        message = 'No pending verifications';
        subtitle = 'All verification requests have been processed';
        break;
      case 'approved':
        message = 'No approved verifications';
        subtitle = 'No driver profiles have been approved yet';
        break;
      case 'rejected':
        message = 'No rejected verifications';
        subtitle = 'No driver profiles have been rejected';
        break;
      default:
        message = 'No verification history';
        subtitle = 'No verification requests found';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.grey[800]!, Colors.grey[600]!]),
            ),
            child: const Icon(Icons.history, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> request) {
    final status = request['status'] as String;
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
    }

    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with driver info and status
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['driver']?['name'] ?? 'Unknown Driver',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          request['driver']?['email'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(status, statusColor),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Driver details
              _buildInfoRow('Phone', request['driver']?['phone'] ?? 'N/A'),
              _buildInfoRow('License Type', request['profile']?['licenseType'] ?? 'N/A'),
              _buildInfoRow('License Number', request['profile']?['licenseNumber'] ?? 'N/A'),
              _buildInfoRow('Experience', '${request['profile']?['experience'] ?? 'N/A'} years'),
              _buildInfoRow('Location', request['profile']?['location'] ?? 'N/A'),
              
              const SizedBox(height: 12),
              
              // Status specific information
              if (status == 'approved' && request['processedAt'] != null) ...[
                _buildInfoRow('Approved Date', _formatDate(request['processedAt'])),
                if (request['processedBy'] != null)
                  _buildInfoRow('Approved By', 'Admin'),
              ],
              
              if (status == 'rejected') ...[
                if (request['processedAt'] != null)
                  _buildInfoRow('Rejected Date', _formatDate(request['processedAt'])),
                if (request['notes'] != null && request['notes'].isNotEmpty)
                  _buildInfoRow('Rejection Reason', request['notes']),
              ],
              
              if (status == 'pending' && request['createdAt'] != null)
                _buildInfoRow('Submitted Date', _formatDate(request['createdAt'])),
              
              // Document preview section
              if (request['documents'] != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Documents:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (request['documents']['profilePhoto'] != null)
                      _buildDocumentPreview('Profile Photo', request['documents']['profilePhoto']),
                    if (request['documents']['licensePhoto'] != null) ...[
                      if (request['documents']['profilePhoto'] != null) const SizedBox(width: 16),
                      _buildDocumentPreview('License Photo', request['documents']['licensePhoto']),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(String title, String imageUrl) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FullscreenPhotoViewer(imageUrl: imageUrl),
            ),
          );
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.zoom_in, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

// Reuse the FullscreenPhotoViewer from verification_screen.dart
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
