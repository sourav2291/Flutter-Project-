// screens/material_request/material_request_list_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';

class AnimatedVehicleStatusImage extends StatefulWidget {
  final String stage;
  final double width;
  final double height;

  const AnimatedVehicleStatusImage({
    super.key,
    required this.stage,
    this.width = 116,
    this.height = 96,
  });

  @override
  State<AnimatedVehicleStatusImage> createState() =>
      _AnimatedVehicleStatusImageState();
}

class _AnimatedVehicleStatusImageState extends State<AnimatedVehicleStatusImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration(widget.stage),
    );
    _controller.repeat(reverse: true);
  }

  Duration _duration(String stage) {
    switch (stage) {
      case 'approved':
        return const Duration(milliseconds: 650);
      case 'verify':
        return const Duration(milliseconds: 850);
      case 'rejected':
        return const Duration(milliseconds: 420);
      default:
        return const Duration(milliseconds: 1500);
    }
  }

  String get _asset {
    switch (widget.stage) {
      case 'verify':
        return 'assets/verify.png';
      case 'approved':
        return 'assets/approved.png';
      case 'rejected':
        return 'assets/rejected.png';
      default:
        return 'assets/pending.png';
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedVehicleStatusImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.stage != widget.stage) {
      _controller
        ..stop()
        ..reset()
        ..duration = _duration(widget.stage)
        ..repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = _controller.value;

          switch (widget.stage) {
            case 'approved':
              return Transform.translate(
                offset: Offset((value - 0.5) * 8, 0),
                child: child,
              );

            case 'verify':
              return Transform.scale(
                scale: 0.94 + value * 0.12,
                child: Transform.translate(
                  offset: Offset(0, (value - 0.5) * 2),
                  child: child,
                ),
              );

            case 'rejected':
              return Transform.translate(
                offset: Offset((value - 0.5) * 3, 0),
                child: child,
              );

            default:
              return Transform.translate(
                offset: Offset(0, (value - 0.5) * 3),
                child: Transform.scale(
                  scale: 0.98 + value * 0.04,
                  child: child,
                ),
              );
          }
        },
        child: Transform.scale(
          // Zoom the transparent vehicle artwork to fill more of its box.
          // This scales the image only; the card/container dimensions stay the same.
          scale: 1.45,
          child: Image.asset(
            _asset,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Vehicle image failed to load: $_asset');
              debugPrint('Asset error: $error');
              return const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.redAccent,
                  size: 28,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MaterialRequestListScreen extends StatefulWidget {
  const MaterialRequestListScreen({super.key});

  @override
  State<MaterialRequestListScreen> createState() =>
      _MaterialRequestListScreenState();
}

class _MaterialRequestListScreenState extends State<MaterialRequestListScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _trackingRecords = [];
  String? _trackingError;

  late AnimationController _animationController;

  static const Color _background = Color(0xFF061F24);
  static const Color _green = Color(0xFF1DB954);
  static const Color _lightGreen = Color(0xFF7EE787);
  static const Color _gold = Color(0xFFFFD166);
  static const Color _teal = Color(0xFF54D6C1);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _loadMaterialRequests();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterialRequests() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final cookie = prefs.getString('cookie');

      if (cookie == null || cookie.trim().isEmpty) {
        throw Exception('Login session not found. Please log in again.');
      }

      // Load Material Requests first. Vehicle tracking is loaded separately
      // so a tracking API issue does not prevent requests from appearing.
      final result = await ApiService.getMyMaterialRequests(cookie: cookie);
      final trackingResult = await ApiService.getSiteMaterialTracking(
        cookie: cookie,
      );

      if (!mounted) return;

      final trackingData = trackingResult['data'];
      final trackingRecords = trackingData is List
          ? trackingData
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      if (result['success'] == true) {
        final rawData = result['data'] as List? ?? [];

        final requests = rawData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        setState(() {
          _requests = requests;
          _trackingRecords = trackingRecords;
          _trackingError = trackingResult['success'] == true
              ? null
              : trackingResult['message']?.toString();
          _loading = false;
        });
      } else {
        setState(() {
          _error =
              result['message']?.toString() ??
              'Unable to load Material Requests.';
          _trackingRecords = trackingRecords;
          _trackingError = trackingResult['success'] == true
              ? null
              : trackingResult['message']?.toString();
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _value(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return '-';
    }

    return value
        .toString()
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  Map<String, List<Map<String, dynamic>>> _groupRequests() {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final request in _requests) {
      final salesOrder = _value(request['custom_sales_order']);
      grouped.putIfAbsent(salesOrder, () => []);
      grouped[salesOrder]!.add(request);
    }

    return grouped;
  }

  String _requestStage(Map<String, dynamic> request) {
    final value = (request['workflow_state'] ?? request['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    if (value.contains('reject') ||
        value.contains('cancel') ||
        value == 'stopped') {
      return 'rejected';
    }

    if (value.contains('verif')) {
      return 'verify';
    }

    if (value.contains('approv') ||
        value == 'ordered' ||
        value == 'completed' ||
        value == 'partially ordered') {
      return 'approved';
    }

    return 'pending';
  }

  String _groupStage(List<Map<String, dynamic>> requests) {
    if (requests.any((r) => _requestStage(r) == 'rejected')) {
      return 'rejected';
    }

    if (requests.any((r) => _requestStage(r) == 'verify')) {
      return 'verify';
    }

    if (requests.any((r) => _requestStage(r) == 'approved')) {
      return 'approved';
    }

    return 'pending';
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase();

    if (value.contains('reject') || value.contains('cancel')) {
      return const Color(0xFFFF7777);
    }

    if (value.contains('approv') ||
        value == 'ordered' ||
        value == 'completed') {
      return _lightGreen;
    }

    if (value.contains('verif')) {
      return _teal;
    }

    if (value == 'draft' || value == 'pending') {
      return _gold;
    }

    return Colors.white70;
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value;

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF041A1F),
                    Color(0xFF073D3A),
                    Color(0xFF0B5E4D),
                    Color(0xFF102F2D),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 80 + value * 30,
              left: -130,
              child: _buildGlow(size: 300, color: _green),
            ),
            Positioned(
              top: 240 - value * 25,
              right: -150,
              child: _buildGlow(size: 320, color: _gold),
            ),
            Positioned(
              bottom: 100 + value * 20,
              left: 40,
              child: _buildGlow(size: 260, color: _lightGreen),
            ),
            Positioned(
              bottom: -120,
              right: -80,
              child: _buildGlow(size: 300, color: _green),
            ),
            const Positioned(
              top: 180,
              right: 18,
              child: Icon(
                Icons.eco_rounded,
                size: 46,
                color: Color(0x557EE787),
              ),
            ),
            const Positioned(
              bottom: 180,
              left: 10,
              child: Icon(
                Icons.eco_rounded,
                size: 36,
                color: Color(0x44FFD166),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlow({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.24),
              color.withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double radius = 20,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.19)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 17, bottom: 11),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _lightGreen),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            _value(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleTrackingSection(Map<String, dynamic> request) {
    final salesOrder = _value(request['custom_sales_order']);

    final matchingRecords = _trackingRecords.where((record) {
      final trackingSalesOrder = _value(record['sales_order']);
      return salesOrder != '-' && trackingSalesOrder == salesOrder;
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VehicleTrackingScreen(
                  salesOrder: salesOrder,
                  materialRequestWorkflowState:
                      (request['workflow_state'] ?? request['status'] ?? '')
                          .toString(),
                  trackingRecords: matchingRecords,
                  trackingError: _trackingError,
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _teal.withValues(alpha: 0.28)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _teal.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: _lightGreen,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle Tracking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        matchingRecords.isEmpty
                            ? 'Tap to view vehicle delivery animation and tracking'
                            : '${matchingRecords.length} tracking record(s) available',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 17,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> request) {
    final name = _value(request['name']);
    final status = _value(request['status']);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
      child: _glassCard(
        radius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enlarged Material Request status image
                Container(
                  width: 120,
                  height: 100,
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.19),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _lightGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: AnimatedVehicleStatusImage(
                    stage: _requestStage(request),
                    width: 116,
                    height: 96,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _value(request['material_request_type']),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _statusBadge(status),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.17),
              ),
            ),
            _sectionTitle(
              'Material Request Information',
              Icons.description_outlined,
            ),
            _detailRow('Material Request ID', request['name']),
            _detailRow('Naming Series', request['naming_series']),
            _detailRow('Request Type', request['material_request_type']),
            _detailRow('Sales Order', request['custom_sales_order']),
            _sectionTitle('Customer Details', Icons.person_outline_rounded),
            _detailRow('Customer Name', request['custom_customer_name']),
            _detailRow('Customer Address', request['custom_customer_address']),
            _detailRow('Capacity (KW)', request['custom_kw']),
            _sectionTitle('Site Engineer Details', Icons.engineering_outlined),
            _detailRow(
              'Site Engineer Name',
              request['custom_site_engineer_name'],
            ),
            _detailRow(
              'Engineer Contact Number',
              request['custom_engineer_contact_number'],
            ),
            _sectionTitle('Tracking Information', Icons.track_changes_rounded),
            _detailRow('Sales User', request['custom_sales_user']),
            _detailRow(
              'Current Status',
              request['workflow_state'] ?? request['status'],
            ),
            _vehicleTrackingSection(request),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: _lightGreen));
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _glassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: _gold, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Unable to Load Material Requests',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _error ?? 'Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _loadMaterialRequests,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: _loadMaterialRequests,
      color: _lightGreen,
      backgroundColor: const Color(0xFF103F39),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 150),
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.65),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'No Material Requests Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Pull down to refresh your request status.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequests() {
    final grouped = _groupRequests();
    final salesOrders = grouped.keys.toList();

    return RefreshIndicator(
      onRefresh: _loadMaterialRequests,
      color: _lightGreen,
      backgroundColor: const Color(0xFF103F39),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 30),
        itemCount: salesOrders.length,
        itemBuilder: (context, index) {
          final salesOrder = salesOrders[index];
          final requests = grouped[salesOrder]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: _glassCard(
              padding: EdgeInsets.zero,
              radius: 22,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.white.withValues(alpha: 0.04),
                  highlightColor: Colors.white.withValues(alpha: 0.03),
                ),
                child: ExpansionTile(
                  initiallyExpanded: salesOrders.length == 1,
                  iconColor: _lightGreen,
                  collapsedIconColor: Colors.white70,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 7,
                  ),
                  childrenPadding: EdgeInsets.zero,

                  // Enlarged Sales Order status image
                  leading: Container(
                    width: 120,
                    height: 100,
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: _teal.withValues(alpha: 0.17),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _teal.withValues(alpha: 0.25)),
                    ),
                    child: AnimatedVehicleStatusImage(
                      stage: _groupStage(requests),
                      width: 116,
                      height: 96,
                    ),
                  ),
                  title: Text(
                    salesOrder == '-' ? 'Sales Order not linked' : salesOrder,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '${requests.length} Material Request'
                      '${requests.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  children: requests
                      .map((request) => _requestCard(request))
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Container(
                  height: 66,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Expanded(
                        child: Text(
                          'Material Request Status',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _loading ? null : _loadMaterialRequests,
                        tooltip: 'Refresh',
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? _buildLoading()
                      : _error != null
                      ? _buildError()
                      : _requests.isEmpty
                      ? _buildEmpty()
                      : _buildRequests(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dedicated vehicle tracking page. The animated GIF is played by Flutter's
/// Image.asset widget once the asset is registered in pubspec.yaml.
class VehicleTrackingScreen extends StatelessWidget {
  final String salesOrder;
  final String materialRequestWorkflowState;
  final List<Map<String, dynamic>> trackingRecords;
  final String? trackingError;

  const VehicleTrackingScreen({
    super.key,
    required this.salesOrder,
    required this.materialRequestWorkflowState,
    required this.trackingRecords,
    this.trackingError,
  });

  static const Color _lightGreen = Color(0xFF7EE787);
  static const Color _teal = Color(0xFF54D6C1);

  // The workflow state comes from the selected Material Request.
  // The Site Material Tracking API does not need to return an approval field.
  String get _deliveryAnimation {
    final state = materialRequestWorkflowState.trim().toLowerCase();
    final isApproved = state.contains('approv');

    return isApproved
        ? 'assets/Delivery in Motion.gif'
        : 'assets/pending animation.gif';
  }

  String _value(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '-';
    return value
        .toString()
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            _value(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.19)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061F24),
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF041A1F),
                  Color(0xFF073D3A),
                  Color(0xFF0B5E4D),
                  Color(0xFF102F2D),
                ],
              ),
            ),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  height: 66,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Vehicle Tracking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    children: [
                      _glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Material Dispatch',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Sales Order: $salesOrder',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.70),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: AspectRatio(
                                aspectRatio: 553 / 309,
                                child: Image.asset(
                                  _deliveryAnimation,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                      'Delivery GIF failed ($_deliveryAnimation): $error',
                                    );
                                    return Container(
                                      color: Colors.black.withValues(
                                        alpha: 0.18,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Delivery animation not found.\nCheck the GIF asset path.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.local_shipping_rounded,
                                  color: _lightGreen,
                                  size: 21,
                                ),
                                SizedBox(width: 9),
                                Text(
                                  'Tracking Information',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (trackingError != null &&
                                trackingRecords.isEmpty)
                              Text(
                                'Unable to load tracking information: $trackingError',
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                ),
                              )
                            else if (trackingRecords.isEmpty)
                              Text(
                                'No vehicle tracking record found for this Sales Order yet. The delivery animation is shown above.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  height: 1.5,
                                ),
                              )
                            else
                              ...trackingRecords.map((record) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _detailRow('Tracking ID', record['name']),
                                    _detailRow(
                                      'Sales Order',
                                      record['sales_order'],
                                    ),
                                    _detailRow(
                                      'Material Request',
                                      record['material_request'],
                                    ),
                                    _detailRow(
                                      'Vehicle Number',
                                      record['vehicle_number'],
                                    ),
                                    _detailRow('Driver', record['driver']),
                                    _detailRow(
                                      'Driver Contact Number',
                                      record['driver_contact_number'],
                                    ),
                                    _detailRow(
                                      'Material Dispose Date',
                                      record['material_dispose_date'],
                                    ),
                                    _detailRow(
                                      'Customer Name',
                                      record['customer_name'],
                                    ),
                                    _detailRow(
                                      'Customer Address',
                                      record['customer_address'],
                                    ),
                                    _detailRow('Capacity (KW)', record['kw']),
                                    _detailRow(
                                      'Verified Person',
                                      record['verified_person_name'],
                                    ),
                                    _detailRow(
                                      'Verified Person Contact',
                                      record['verified_person_contact_number'],
                                    ),
                                    if (record != trackingRecords.last)
                                      Divider(
                                        color: _teal.withValues(alpha: 0.25),
                                        height: 20,
                                      ),
                                  ],
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
