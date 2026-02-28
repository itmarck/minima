import 'dart:typed_data';

/// Represents an installed package on the device.
/// Read-only data class — not a synced entity.
class PackageInfo {
  final String packageName;
  final String label;
  final Uint8List? icon;

  const PackageInfo({
    required this.packageName,
    required this.label,
    this.icon,
  });
}
