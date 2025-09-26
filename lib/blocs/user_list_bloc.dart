import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final UserService _userService;

  UserListBloc({required UserService userService})
      : _userService = userService,
        super(UserListInitial()) {
    on<UserListFetchRequested>(_onFetchRequested);
    on<UserListRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onFetchRequested(
    UserListFetchRequested event,
    Emitter<UserListState> emit,
  ) async {
    emit(UserListLoading());
    
    try {
      final users = await _userService.fetchUsers();
      emit(UserListLoaded(users));
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    UserListRefreshRequested event,
    Emitter<UserListState> emit,
  ) async {
    try {
      final users = await _userService.fetchUsers();
      emit(UserListLoaded(users));
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }
}

// Events
abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object?> get props => [];
}

class UserListFetchRequested extends UserListEvent {}

class UserListRefreshRequested extends UserListEvent {}

// States
abstract class UserListState extends Equatable {
  const UserListState();

  @override
  List<Object?> get props => [];
}

class UserListInitial extends UserListState {}

class UserListLoading extends UserListState {}

class UserListLoaded extends UserListState {
  final List<User> users;

  const UserListLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserListError extends UserListState {
  final String message;

  const UserListError(this.message);

  @override
  List<Object?> get props => [message];
}









