part of 'home_cubit.dart';

@immutable
abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeFailed extends HomeState {}

class HomeLoaded extends HomeState {
  final List<PasswordModel> passesList;

  const HomeLoaded(this.passesList);
}
