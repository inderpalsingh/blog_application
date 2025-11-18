class CommentEntity {
  final int id;
  final String comments;
  final DateTime? createdAt;

  const CommentEntity({
    required this.id,
    required this.comments,
    this.createdAt,
  });
}
