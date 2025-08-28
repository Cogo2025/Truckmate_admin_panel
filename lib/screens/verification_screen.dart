import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../widgets/admin_drawer.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> pendingRequests = [];
  List<Map<String, dynamic>> allRequests = [];
  bool isLoading = true;
  String? error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchVerificationData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchVerificationData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('📥 Fetching verification data...');

      // Fetch both pending and all verifications
      final [pending, all] = await Future.wait([
        _apiService.getPendingVerifications(),
        _apiService.getAllVerifications()
      ]);

      print('✅ Fetched ${pending.length} pending and ${all.length} total verifications');

      setState(() {
        pendingRequests = List<Map<String, dynamic>>.from(pending);
        allRequests = List<Map<String, dynamic>>.from(all);
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching verification data: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _processRequest(String requestId, String action, String? notes) async {
    try {
      print('📝 Processing request $requestId with action: $action');
      
      await _apiService.processVerification(requestId, action, notes);
      _showSnackBar('Driver ${action}d successfully', Colors.green);
      
      // Refresh data after processing
      await _fetchVerificationData();
    } catch (e) {
      print('❌ Error processing request: $e');
      _showSnackBar('Failed to process request: $e', Colors.red);
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _showSnackBar('$label copied to clipboard', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to copy $label', Colors.red);
    }
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

  Widget _buildStatCards() {
    final stats = _getVerificationStats();
    return Row(
      children: [
        _buildStatCard('Pending', stats['pending'].toString(), Icons.pending, Colors.orange),
        const SizedBox(width: 16),
        _buildStatCard('Approved', stats['approved'].toString(), Icons.check_circle, Colors.green),
        const SizedBox(width: 16),
        _buildStatCard('Rejected', stats['rejected'].toString(), Icons.cancel, Colors.red),
      ],
    );
  }

  Map<String, int> _getVerificationStats() {
    final pending = allRequests.where((req) => req['status'] == 'pending').length;
    final approved = allRequests.where((req) => req['status'] == 'approved').length;
    final rejected = allRequests.where((req) => req['status'] == 'rejected').length;
    
    return {'pending': pending, 'approved': approved, 'rejected': rejected};
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationList(List<Map<String, dynamic>> requests, {bool showActions = true}) {
    print('🔍 Building verification list with ${requests.length} requests, showActions: $showActions');
    
    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text('No verification requests found', 
                 style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchVerificationData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildVerificationCard(request, showActions: showActions);
        },
      ),
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> request, {bool showActions = true}) {
    final status = request['status'] ?? 'pending';
    final requestId = request['_id'] ?? '';
    
    print('🎯 Building card for request: $requestId, status: $status, showActions: $showActions');
    
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending;
    
    switch (status.toLowerCase()) {
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
        statusIcon = Icons.pending;
    }

    return Card(
      elevation: 4,
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    request['driver']?['name'] ?? request['profile']?['name'] ?? 'Unknown Driver',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                  ),
                ),
                _buildStatusChip(status),
                const SizedBox(width: 8),
                _buildPriorityChip(request['priority'] ?? 'medium'),
              ],
            ),
            
            const SizedBox(height: 20),
            Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // Driver Information
            Text(
              'Driver Information',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow('Email', request['driver']?['email'] ?? 'N/A'),
            _buildInfoRow('Phone', request['driver']?['phone'] ?? 'N/A'),
            _buildInfoRow('License Number', request['profile']?['licenseNumber'] ?? 'N/A', showCopyButton: true),
            _buildInfoRow('Experience', request['profile']?['experience']?.toString() ?? 'N/A'),
            _buildInfoRow('Location', request['profile']?['location'] ?? 'N/A'),
            _buildInfoRow('Age', request['profile']?['age']?.toString() ?? 'N/A'),
            _buildInfoRow('Gender', request['profile']?['gender'] ?? 'N/A'),
            
            if (request['profile']?['knownTruckTypes'] != null && 
                (request['profile']['knownTruckTypes'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Truck Types', 
                (request['profile']['knownTruckTypes'] as List).join(', ')
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Status specific information
            if (status != 'pending') ...[
              Divider(color: Colors.white24),
              const SizedBox(height: 16),
              
              Text(
                'Processing Information',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildInfoRow(
                'Processed At', 
                request['processedAt'] != null ? 
                DateTime.parse(request['processedAt']).toString().substring(0, 19) : 'N/A'
              ),
              
              if (request['notes'] != null && request['notes'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Notes', request['notes'].toString()),
              ],
              
              const SizedBox(height: 20),
            ],
            
            // Documents section
            if (request['documents'] != null) ...[
              Divider(color: Colors.white24),
              const SizedBox(height: 16),
              
              Text(
                'Documents',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              
              // Profile Photo
              if (request['documents']['profilePhoto'] != null) ...[
                _buildDocumentPreview('Profile Photo', request['documents']['profilePhoto']),
                const SizedBox(height: 12),
              ],
              
              // License Photos Row
              Row(
                children: [
                  if (request['documents']['licensePhotoFront'] != null)
                    Expanded(
                      child: _buildDocumentPreview('License Front', request['documents']['licensePhotoFront']),
                    ),
                  if (request['documents']['licensePhotoFront'] != null && 
                      request['documents']['licensePhotoBack'] != null)
                    const SizedBox(width: 16),
                  if (request['documents']['licensePhotoBack'] != null)
                    Expanded(
                      child: _buildDocumentPreview('License Back', request['documents']['licensePhotoBack']),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            
            // Action buttons - THIS IS THE KEY PART
            if (showActions && status.toLowerCase() == 'pending' && requestId.isNotEmpty) ...[
              Divider(color: Colors.white24),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print('🚫 Reject button pressed for: $requestId');
                        _showRejectDialog(requestId);
                      },
                      icon: const Icon(Icons.close, size: 20),
                      label: Text('Reject', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print('✅ Approve button pressed for: $requestId');
                        _processRequest(requestId, 'approved', null);
                      },
                      icon: const Icon(Icons.check, size: 20),
                      label: Text('Approve', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (showActions && status.toLowerCase() == 'pending') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Invalid request ID - Cannot process',
                        style: TextStyle(color: Colors.orange, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        label = 'APPROVED';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'REJECTED';
        break;
      default:
        color = Colors.orange;
        label = 'PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label, 
        style: TextStyle(
          fontSize: 12, 
          color: color, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        priority.toUpperCase(), 
        style: TextStyle(
          fontSize: 12, 
          color: color, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showCopyButton = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:', 
              style: TextStyle(
                fontWeight: FontWeight.w500, 
                color: Colors.white70,
                fontSize: 14,
              )
            ),
          ),
          Expanded(
            child: Text(
              value, 
              style: TextStyle(
                fontWeight: FontWeight.w500, 
                color: Colors.white,
                fontSize: 14,
              )
            ),
          ),
          if (showCopyButton && value != 'N/A')
            InkWell(
              onTap: () => _copyToClipboard(value, label),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                ),
                child: const Icon(Icons.copy, size: 16, color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(String title, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => FullscreenPhotoViewer(imageUrl: imageUrl, title: title),
            ));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent, 
                        Colors.black.withOpacity(0.7)
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.zoom_in, 
                      color: Colors.white, 
                      size: 32
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(String requestId) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reject Verification', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for rejection:', 
              style: TextStyle(color: Colors.white70, fontSize: 16)
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 4,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter detailed rejection reason...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel', 
              style: TextStyle(color: Colors.white70)
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                _showSnackBar('Please provide a rejection reason', Colors.orange);
                return;
              }
              Navigator.pop(context);
              _processRequest(requestId, 'rejected', reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Reject',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        title: Text(
          'Driver Verification', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchVerificationData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Pending (${pendingRequests.length})', 
              icon: const Icon(Icons.pending)
            ),
            Tab(
              text: 'History (${allRequests.length})', 
              icon: const Icon(Icons.history)
            ),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.blue,
        ),
      ),
      drawer: AdminDrawer(),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading verification requests...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        error!, 
                        style: TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchVerificationData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildStatCards(),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildVerificationList(pendingRequests, showActions: true),
                          _buildVerificationList(allRequests, showActions: false),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class FullscreenPhotoViewer extends StatelessWidget {
  final String imageUrl;
  final String? title;

  const FullscreenPhotoViewer({Key? key, required this.imageUrl, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title ?? 'Document', 
          style: TextStyle(color: Colors.white)
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load image', 
                    style: TextStyle(color: Colors.white)
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
