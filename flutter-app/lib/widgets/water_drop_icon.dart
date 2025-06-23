import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum DropSize { small, medium, large }

enum DropIntensity { light, medium, heavy, spotting }

class WaterDropIcon extends StatelessWidget {
  final DropSize size;
  final DropIntensity intensity;
  final Color? color;
  final bool animated;
  final VoidCallback? onTap;

  const WaterDropIcon({
    super.key,
    this.size = DropSize.medium,
    this.intensity = DropIntensity.medium,
    this.color,
    this.animated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: _buildDropIcon(),
      ),
    );
  }

  Widget _buildDropIcon() {
    final dropColor = color ?? _getIntensityColor();
    final dropSize = _getDropSize();

    return Container(
      width: dropSize,
      height: dropSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            dropColor.withOpacity(0.8),
            dropColor,
          ],
          stops: const [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.water_drop,
          color: Colors.white,
          size: dropSize * 0.6,
        ),
      ),
    );
  }

  Color _getIntensityColor() {
    switch (intensity) {
      case DropIntensity.light:
        return AppColors.primary;
      case DropIntensity.medium:
        return AppColors.secondary;
      case DropIntensity.heavy:
        return AppColors.accent;
      case DropIntensity.spotting:
        return AppColors.tertiary;
    }
  }

  double _getDropSize() {
    switch (size) {
      case DropSize.small:
        return 16;
      case DropSize.medium:
        return 24;
      case DropSize.large:
        return 32;
    }
  }
}

class AnimatedWaterDrop extends StatefulWidget {
  final DropSize size;
  final DropIntensity intensity;
  final Color? color;
  final VoidCallback? onTap;

  const AnimatedWaterDrop({
    super.key,
    this.size = DropSize.medium,
    this.intensity = DropIntensity.medium,
    this.color,
    this.onTap,
  });

  @override
  State<AnimatedWaterDrop> createState() => _AnimatedWaterDropState();
}

class _AnimatedWaterDropState extends State<AnimatedWaterDrop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: WaterDropIcon(
                size: widget.size,
                intensity: widget.intensity,
                color: widget.color,
              ),
            ),
          );
        },
      ),
    );
  }
}

class FlowIndicator extends StatelessWidget {
  final DropIntensity intensity;
  final String label;
  final bool showLabel;

  const FlowIndicator({
    super.key,
    required this.intensity,
    this.label = '',
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WaterDropIcon(
          size: DropSize.medium,
          intensity: intensity,
        ),
        if (showLabel && label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class FlowSelector extends StatelessWidget {
  final DropIntensity selectedIntensity;
  final Function(DropIntensity) onIntensityChanged;
  final bool showLabels;

  const FlowSelector({
    super.key,
    required this.selectedIntensity,
    required this.onIntensityChanged,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: DropIntensity.values.map((intensity) {
        final isSelected = selectedIntensity == intensity;
        return GestureDetector(
          onTap: () => onIntensityChanged(intensity),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: FlowIndicator(
              intensity: intensity,
              label: _getIntensityLabel(intensity),
              showLabel: showLabels,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getIntensityLabel(DropIntensity intensity) {
    switch (intensity) {
      case DropIntensity.light:
        return 'Light';
      case DropIntensity.medium:
        return 'Medium';
      case DropIntensity.heavy:
        return 'Heavy';
      case DropIntensity.spotting:
        return 'Spotting';
    }
  }
}
