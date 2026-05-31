enum SessionContextType { priority, flash, other }

class SessionContext {
  final SessionContextType type;
  final String label;
  final String? projectId;
  final String? projectName;

  const SessionContext({
    required this.type,
    required this.label,
    this.projectId,
    this.projectName,
  });
}
