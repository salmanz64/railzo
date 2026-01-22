class UserRepository {
  String? _currentRole;

  String? get currentRole => _currentRole;

  Future<void> selectRole(String role) async {
    _currentRole = role;
  }

  void clearRole() {
    _currentRole = null;
  }
}
