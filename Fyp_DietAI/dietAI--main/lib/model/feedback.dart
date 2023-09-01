class feedback {
  final String name;
  final String email;
  final String subject;
  final String comment;

  feedback({
    required this.name,
    required this.email,
    required this.subject,
    required this.comment,
  });

  factory feedback.fromJson(Map<String, dynamic> json) {
    return feedback(
      name: json['name'] as String,
      email: json['email'] as String,
      subject: json['subject'] as String,
      comment: json['comment'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'subject': subject,
      'comment': comment,
    };
  }
}
