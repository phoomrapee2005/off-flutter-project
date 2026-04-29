class User {
  final String id;
  final String username;
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String dob;
  final int age;
  final String address;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    required this.age,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'dob': dob,
      'age': age,
      'address': address,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      phone: map['phone'] ?? '',
      dob: map['dob'] ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      address: map['address'] ?? '',
    );
  }
}
