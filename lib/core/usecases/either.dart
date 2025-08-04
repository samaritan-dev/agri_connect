import 'package:equatable/equatable.dart';

abstract class Either<L, R> extends Equatable {
  const Either();

  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight);

  bool isLeft() => fold((_) => true, (_) => false);
  bool isRight() => fold((_) => false, (_) => true);

  L getLeft() => fold((l) => l, (_) => throw Exception('getLeft() called on Right'));
  R getRight() => fold((_) => throw Exception('getRight() called on Left'), (r) => r);

  Either<L, R> orElse(Either<L, R> Function() other) => fold((_) => other(), (_) => this);

  Either<L, R> operator |(Either<L, R> other) => orElse(() => other);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight) => ifLeft(value);

  @override
  List<Object?> get props => [value];
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  B fold<B>(B Function(L l) ifLeft, B Function(R r) ifRight) => ifRight(value);

  @override
  List<Object?> get props => [value];
} 