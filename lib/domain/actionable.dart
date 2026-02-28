/// Types of actions available from the launcher input.
enum ActionableType { package }

/// Represents something the user can execute from the input field.
/// Packages now, but extensible to settings, commands, etc.
class Actionable {
  final String label;
  final String id;
  final ActionableType type;

  const Actionable({
    required this.label,
    required this.id,
    required this.type,
  });
}
