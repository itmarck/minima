/// User preference for a specific package.
/// Local only — not synced to Notion.
class PackagePreference {
  final String packageName;
  final bool isHome;
  final bool isHidden;
  final int homeOrder;

  const PackagePreference({
    required this.packageName,
    this.isHome = false,
    this.isHidden = false,
    this.homeOrder = 0,
  });
}
