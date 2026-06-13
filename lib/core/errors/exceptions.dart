class EnvironmentNotConfiguredException implements Exception {
  final String message;
  
  EnvironmentNotConfiguredException([this.message = 'Environment variables are not configured. Please run build_runner.']);

  @override
  String toString() => 'EnvironmentNotConfiguredException: $message';
}
