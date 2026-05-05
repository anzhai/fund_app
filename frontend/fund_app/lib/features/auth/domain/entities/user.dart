import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String phone;
  final String? email;
  final String? avatar;
  final bool hasFundAccount;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.phone,
    this.email,
    this.avatar,
    required this.hasFundAccount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, username, phone, hasFundAccount];
}