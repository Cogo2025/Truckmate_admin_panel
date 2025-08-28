import 'package:flutter/material.dart';

class NeonDashboardCards extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const NeonDashboardCards({Key? key, required this.statistics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return GridView.count(
      crossAxisCount: isLargeScreen ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: isLargeScreen ? 1 : 1.1,
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        _buildNeonCard(
          'Total Users',
          statistics['totalUsers'].toString(),
          Icons.people_outline,
          const Color(0xFF00F5FF), // Cyan
          const Color(0xFF0080FF), // Blue
        ),
        _buildNeonCard(
          'Drivers',
          statistics['totalDrivers'].toString(),
          Icons.local_shipping_outlined,
          const Color(0xFF39FF14), // Neon Green
          const Color(0xFF00CC11), // Dark Green
        ),
        _buildNeonCard(
          'Owners',
          statistics['totalOwners'].toString(),
          Icons.business_outlined,
          const Color(0xFFFF6600), // Orange
          const Color(0xFFCC5200), // Dark Orange
        ),
        _buildNeonCard(
          'Active Drivers',
          statistics['activeDrivers'].toString(),
          Icons.online_prediction_outlined,
          const Color(0xFFFF1744), // Pink/Red
          const Color(0xFFCC1136), // Dark Red
        ),
      ],
    );
  }

  Widget _buildNeonCard(
    String title,
    String value,
    IconData icon,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E), // Dark background
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: primaryColor,
              width: 2,
            ),
            boxShadow: [
              // Outer glow
              BoxShadow(
                color: primaryColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 0),
              ),
              // Inner glow effect
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: -5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                // Add tap functionality if needed
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Neon Icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryColor, secondaryColor],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.6),
                            blurRadius: 15,
                            spreadRadius: 0,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Value with neon glow text effect
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [primaryColor, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFCCCCCC),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced version with hover animations (for better interaction)
class NeonDashboardCardsAnimated extends StatefulWidget {
  final Map<String, dynamic> statistics;

  const NeonDashboardCardsAnimated({Key? key, required this.statistics}) : super(key: key);

  @override
  State<NeonDashboardCardsAnimated> createState() => _NeonDashboardCardsAnimatedState();
}

class _NeonDashboardCardsAnimatedState extends State<NeonDashboardCardsAnimated> {
  int hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    final cardData = [
      {
        'title': 'Total Users',
        'value': widget.statistics['totalUsers'].toString(),
        'icon': Icons.people_outline,
        'primaryColor': const Color(0xFF00F5FF),
        'secondaryColor': const Color(0xFF0080FF),
      },
      {
        'title': 'Drivers',
        'value': widget.statistics['totalDrivers'].toString(),
        'icon': Icons.local_shipping_outlined,
        'primaryColor': const Color(0xFF39FF14),
        'secondaryColor': const Color(0xFF00CC11),
      },
      {
        'title': 'Owners',
        'value': widget.statistics['totalOwners'].toString(),
        'icon': Icons.business_outlined,
        'primaryColor': const Color(0xFFFF6600),
        'secondaryColor': const Color(0xFFCC5200),
      },
      {
        'title': 'Active Drivers',
        'value': widget.statistics['activeDrivers'].toString(),
        'icon': Icons.online_prediction_outlined,
        'primaryColor': const Color(0xFFFF1744),
        'secondaryColor': const Color(0xFFCC1136),
      },
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLargeScreen ? 4 : 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: isLargeScreen ? 1 : 1.1,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: cardData.length,
      itemBuilder: (context, index) {
        final data = cardData[index];
        final isHovered = hoveredIndex == index;
        
        return _buildAnimatedNeonCard(
          data['title'] as String,
          data['value'] as String,
          data['icon'] as IconData,
          data['primaryColor'] as Color,
          data['secondaryColor'] as Color,
          index,
          isHovered,
        );
      },
    );
  }

  Widget _buildAnimatedNeonCard(
    String title,
    String value,
    IconData icon,
    Color primaryColor,
    Color secondaryColor,
    int index,
    bool isHovered,
  ) {
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredIndex = index),
      onExit: (_) => setState(() => hoveredIndex = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: primaryColor,
                width: isHovered ? 3 : 2,
              ),
              boxShadow: [
                // Enhanced glow when hovered
                BoxShadow(
                  color: primaryColor.withOpacity(isHovered ? 0.8 : 0.5),
                  blurRadius: isHovered ? 30 : 20,
                  spreadRadius: isHovered ? 2 : 0,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: -5,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  // Add tap functionality
                  _showCardDetails(title, value);
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Neon Icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isHovered ? 80 : 70,
                        height: isHovered ? 80 : 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryColor, secondaryColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(isHovered ? 0.8 : 0.6),
                              blurRadius: isHovered ? 20 : 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          size: isHovered ? 36 : 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Animated Value
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: isHovered ? 36 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [primaryColor, Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text(value),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: isHovered ? Colors.white : const Color(0xFFCCCCCC),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCardDetails(String title, String value) {
    // Optional: Show more details when card is tapped
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Current count: $value',
          style: const TextStyle(color: Color(0xFFCCCCCC)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}