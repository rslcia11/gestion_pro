import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/user_profile_repository.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository();
});

class UserProfileState {
  final bool isLoading;
  final String fullName;
  final String phone;
  final String? avatarUrl;
  final String? error;
  final String? email;

  UserProfileState({
    this.isLoading = true,
    this.fullName = '',
    this.phone = '',
    this.avatarUrl,
    this.error,
    this.email,
  });

  UserProfileState copyWith({
    bool? isLoading,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? error,
    String? email,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      error: error, // Clear error if not provided
      email: email ?? this.email,
    );
  }
}

// Stub: sin backend conectado — pendiente de integrar nueva DB.
class UserProfileNotifier extends Notifier<UserProfileState> {
  late UserProfileRepository _repository;

  @override
  UserProfileState build() {
    _repository = ref.watch(userProfileRepositoryProvider);
    Future.microtask(() => _loadProfile());
    return UserProfileState();
  }

  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    final profile = await _repository.getProfile('') ?? {};
    state = state.copyWith(
      isLoading: false,
      fullName: profile['full_name'] ?? '',
      phone: profile['phone'] ?? '',
      avatarUrl: profile['avatar_url'],
    );
  }

  Future<bool> saveProfile({
    required String fullName,
    required String phone,
    XFile? newAvatarFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    await _repository.updateProfile(
      userId: '',
      fullName: fullName,
      phone: phone,
      avatarFile: newAvatarFile,
    );
    await _loadProfile();
    return true;
  }

  Future<bool> changePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    await _repository.changePassword(newPassword);
    state = state.copyWith(isLoading: false);
    return true;
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    await _repository.deleteAccount('');
    state = state.copyWith(isLoading: false);
    return true;
  }

  Future<bool> logout() async {
    return true;
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfileState>(() {
  return UserProfileNotifier();
});
