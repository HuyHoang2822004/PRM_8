import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _storeLocation = LatLng(10.72967, 106.72198);

  void _copyAddress() {
    Clipboard.setData(const ClipboardData(text: '123 Nguyễn Văn Linh, Quận 7, TP.HCM'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Đã sao chép địa chỉ cửa hàng!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNavigationInstructions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 350),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.navigation_rounded, color: AppColors.accent),
                const SizedBox(width: 8),
                const Text(
                  'Chỉ đường tới Chrono Luxury',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary, letterSpacing: 0.5),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 24),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tuyến đường chính', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 2),
                      Text(
                        'Đi theo Nguyễn Văn Linh qua ngã tư Nguyễn Hữu Thọ khoảng 500m. Cửa hàng nằm phía tay phải.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_parking_rounded, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Đỗ xe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 2),
                      Text(
                        'Hỗ trợ đỗ xe ô tô và xe máy miễn phí, có nhân viên bảo vệ trông giữ trước cửa hàng.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
                _copyAddress();
              },
              label: 'SAO CHÉP ĐỊA CHỈ & MỞ BẢN ĐỒ',
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          kIsWeb
              ? const PremiumInteractiveMockMap()
              : GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _storeLocation,
                    zoom: 15.5,
                  ),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: {
                    const Marker(
                      markerId: MarkerId('chrono_luxury_store'),
                      position: _storeLocation,
                      infoWindow: InfoWindow(
                        title: 'Chrono Luxury',
                        snippet: '123 Nguyễn Văn Linh, Q7, TP.HCM',
                      ),
                    ),
                  },
                ),
          
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Text(
                            'SHOWROOM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '4.9 (240 đánh giá)',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Chrono Luxury Store',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_rounded, color: AppColors.accent, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '123 Nguyễn Văn Linh, Quận 7, TP.HCM',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.phone_rounded, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Hotline: 0909 123 456',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.access_time_filled_rounded, color: Colors.amber, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Giờ hoạt động: 8:00 - 21:00 (Hàng ngày)',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.border),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border, width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              foregroundColor: AppColors.textPrimary,
                              backgroundColor: Colors.white,
                            ),
                            onPressed: _copyAddress,
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: const Text(
                              'Sao chép',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _showNavigationInstructions,
                            icon: const Icon(Icons.navigation_rounded, size: 16),
                            label: const Text(
                              'Chỉ đường',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumInteractiveMockMap extends StatefulWidget {
  const PremiumInteractiveMockMap({super.key});

  @override
  State<PremiumInteractiveMockMap> createState() => _PremiumInteractiveMockMapState();
}

class _PremiumInteractiveMockMapState extends State<PremiumInteractiveMockMap> with TickerProviderStateMixin {
  final _transformationController = TransformationController();
  late AnimationController _zoomAnimationController;
  Animation<Matrix4>? _zoomAnimation;
  bool _isSatelliteMode = false;

  @override
  void initState() {
    super.initState();
    _zoomAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_zoomAnimation != null) {
          _transformationController.value = _zoomAnimation!.value;
        }
      });

    final initialMatrix = Matrix4.identity()
      ..translate(-250.0, -250.0)
      ..scale(1.5);
    _transformationController.value = initialMatrix;
  }

  @override
  void dispose() {
    _zoomAnimationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _animateToMatrix(Matrix4 targetMatrix) {
    _zoomAnimationController.stop();
    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: targetMatrix,
    ).animate(
      CurvedAnimation(parent: _zoomAnimationController, curve: Curves.easeOutCubic),
    );
    _zoomAnimationController.forward(from: 0);
  }

  void _zoomIn() {
    final matrix = _transformationController.value.clone();
    final currentScale = matrix.getMaxScaleOnAxis();
    if (currentScale < 4.0) {
      matrix.scale(1.25);
      _animateToMatrix(matrix);
    }
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone();
    final currentScale = matrix.getMaxScaleOnAxis();
    if (currentScale > 0.5) {
      matrix.scale(0.8);
      _animateToMatrix(matrix);
    }
  }

  void _resetView() {
    final resetMatrix = Matrix4.identity()
      ..translate(-250.0, -250.0)
      ..scale(1.5);
    _animateToMatrix(resetMatrix);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _isSatelliteMode ? const Color(0xFF070B12) : AppColors.primary,
      child: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(500),
            child: SizedBox(
              width: 1000,
              height: 1000,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: LuxuryMapPainter(isSatelliteMode: _isSatelliteMode),
                    ),
                  ),
                  
                  const Positioned(
                    left: 500 - 30,
                    top: 500 - 30,
                    child: PulsingMarker(),
                  ),
                  
                  Positioned(
                    left: 280,
                    top: 220,
                    child: Text(
                      'Đại học RMIT',
                      style: TextStyle(
                        color: _isSatelliteMode ? Colors.white24 : Colors.grey.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 720,
                    top: 680,
                    child: Text(
                      'Crescent Mall',
                      style: TextStyle(
                        color: _isSatelliteMode ? Colors.white24 : Colors.grey.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 512,
                    top: 450,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 0.5),
                      ),
                      child: const Text(
                        'Chrono Luxury HQ',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 16,
            top: kIsWeb ? 16 : 80,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.add_rounded,
                  onPressed: _zoomIn,
                  tooltip: 'Phóng to',
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.remove_rounded,
                  onPressed: _zoomOut,
                  tooltip: 'Thu nhỏ',
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.my_location_rounded,
                  onPressed: _resetView,
                  tooltip: 'Căn giữa',
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: _isSatelliteMode ? Icons.map_outlined : Icons.satellite_alt_outlined,
                  onPressed: () => setState(() => _isSatelliteMode = !_isSatelliteMode),
                  tooltip: _isSatelliteMode ? 'Bản đồ thường' : 'Vệ tinh',
                ),
              ],
            ),
          ),

          Positioned(
            left: 16,
            top: kIsWeb ? 16 : 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gps_fixed_rounded, color: AppColors.accent, size: 14),
                  SizedBox(width: 8),
                  Text(
                    '10.72967° N, 106.72198° E',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          hoverColor: AppColors.accent.withOpacity(0.15),
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class LuxuryMapPainter extends CustomPainter {
  const LuxuryMapPainter({required this.isSatelliteMode});

  final bool isSatelliteMode;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isSatelliteMode
          ? Colors.blue.withOpacity(0.02)
          : AppColors.accent.withOpacity(0.03)
      ..strokeWidth = 1.0;
    
    const step = 50.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    final waterPaint = Paint()
      ..color = isSatelliteMode ? const Color(0xFF0F1B2F) : const Color(0xFF161F2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50.0
      ..strokeCap = StrokeCap.round;
    
    final riverPath = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.15, size.width * 0.5, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.75, size.width, size.height * 0.7);
    
    final waterBorderPaint = Paint()
      ..color = isSatelliteMode ? Colors.blue.withOpacity(0.05) : AppColors.accent.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 54.0
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(riverPath, waterBorderPaint);
    canvas.drawPath(riverPath, waterPaint);

    final secondaryRoadPaint = Paint()
      ..color = isSatelliteMode ? const Color(0xFF1C222E) : const Color(0xFF1F1F1F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), secondaryRoadPaint);
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), secondaryRoadPaint);

    final mainRoadBorder = Paint()
      ..color = isSatelliteMode ? Colors.white.withOpacity(0.12) : AppColors.accent.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26.0
      ..strokeCap = StrokeCap.round;

    final mainRoadPaint = Paint()
      ..color = isSatelliteMode ? const Color(0xFF282F3E) : const Color(0xFF2C2C2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22.0
      ..strokeCap = StrokeCap.round;

    final mainRoadPath = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.45);
    
    canvas.drawPath(mainRoadPath, mainRoadBorder);
    canvas.drawPath(mainRoadPath, mainRoadPaint);

    final markingPaint = Paint()
      ..color = isSatelliteMode ? Colors.white30 : AppColors.accent.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    
    final dashPath = Path();
    double currentX = 0;
    const dashLength = 12.0;
    const spaceLength = 10.0;
    final double angle = (size.height * 0.45 - size.height * 0.55) / size.width;
    while (currentX < size.width) {
      final y = size.height * 0.55 + currentX * angle;
      dashPath.moveTo(currentX, y);
      final nextX = currentX + dashLength;
      final nextY = size.height * 0.55 + nextX * angle;
      dashPath.lineTo(nextX, nextY);
      currentX += dashLength + spaceLength;
    }
    canvas.drawPath(dashPath, markingPaint);

    final ringsPaint = Paint()
      ..color = AppColors.accent.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 80, ringsPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 180, ringsPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 280, ringsPaint);
  }

  @override
  bool shouldRepaint(covariant LuxuryMapPainter oldDelegate) =>
      oldDelegate.isSatelliteMode != isSatelliteMode;
}

class PulsingMarker extends StatefulWidget {
  const PulsingMarker({super.key});

  @override
  State<PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<PulsingMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(2, (index) {
              final delay = index * 0.5;
              final progress = (_controller.value + delay) % 1.0;
              return Container(
                width: 68 * progress,
                height: 68 * progress,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.35 * (1.0 - progress)),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.7 * (1.0 - progress)),
                    width: 1.0,
                  ),
                ),
              );
            }),
            
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
            
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
