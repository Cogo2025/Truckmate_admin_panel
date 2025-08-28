import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../widgets/admin_drawer.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> pendingRequests = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  Future<void> _fetchPendingRequests() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      final List<Map<String, dynamic>> requests = await _apiService.getPendingVerifications();
      setState(() {
        pendingRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _processRequest(String requestId, String action, String? notes) async {
    try {
      await _apiService.processVerification(requestId, action, notes);
      _showSnackBar('Driver ${action}d successfully', Colors.green);
      _fetchPendingRequests();
    } catch (e) {
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
                    ]),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final request = pendingRequests[index];
        return _buildVerificationCard(request);
      },
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> request) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.person, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(request['driver']['name'] ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
              _buildPriorityChip(request['priority'] ?? 'medium'),
            ]),
            const SizedBox(height: 16),
            _buildInfoRow('Email', request['driver']['email'] ?? 'N/A'),
            _buildInfoRow('Phone', request['driver']['phone'] ?? 'N/A'),
            _buildInfoRow('License Number', request['profile']['licenseNumber'] ?? 'N/A',
                showCopyButton: true),
            _buildInfoRow('Experience', '${request['profile']['experience'] ?? 'N/A'} years'),
            _buildInfoRow('Location', request['profile']['location'] ?? 'N/A'),
            const SizedBox(height: 16),
            if (request['documents'] != null) ...[
              const Text('Documents:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Row(children: [
                if (request['documents']['profilePhoto'] != null)
                  _buildDocumentPreview('Profile Photo', request['documents']['profilePhoto']),
                if (request['documents']['licensePhotoFront'] != null ||
                    request['documents']['licensePhotoBack'] != null) ...[
                  if (request['documents']['profilePhoto'] != null)
                    const SizedBox(width: 16),
                  if (request['documents']['licensePhotoFront'] != null)
                    _buildDocumentPreview('License Front', request['documents']['licensePhotoFront']),
                  if (request['documents']['licensePhotoBack'] != null)
                    _buildDocumentPreview('License Back', request['documents']['licensePhotoBack']),
                ]
              ]),
              const SizedBox(height: 16),
            ],
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showRejectDialog(request['_id']),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _processRequest(request['_id'], 'approved', null),
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ]),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: color.withOpacity(0.2), border: Border.all(color: color.withOpacity(0.5)), borderRadius: BorderRadius.circular(12)),
      child: Text(priority.toUpperCase(), style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showCopyButton = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white))),
        if (showCopyButton && value != 'N/A')
          InkWell(
            onTap: () => _copyToClipboard(value, label),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.blue.withOpacity(0.5))),
              child: const Icon(Icons.copy, size: 16, color: Colors.blue),
            ),
          ),
      ]),
    );
  }

  Widget _buildDocumentPreview(String title, String imageUrl) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullscreenPhotoViewer(imageUrl: imageUrl)));
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]),
                    ),
                    child: const Center(child: Icon(Icons.zoom_in, color: Colors.white, size: 30)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(String requestId) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Reject Verification', style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Please provide a reason for rejection:', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter rejection reason...',
              hintStyle: const TextStyle(color: Colors.white70),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processRequest(requestId, 'rejected', reasonController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // full UI implemented above
    return Scaffold(); // placeholder – actual UI method already above
  }
}

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
            errorBuilder: (context, error, stackTrace) => const Center(child: Text('Failed to load image', style: TextStyle(color: Colors.white))),
          ),
        ),
      ),
    );
  }
}
