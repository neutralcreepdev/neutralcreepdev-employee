enum UserType { Customer, Staff }

class User {
  String firstName, lastName, id, contactNum;
  Map dob;
  Map address;
  UserType type;

  User(this.id, this.firstName, this.lastName, this.dob, this.contactNum,
      this.address);

  @override
  String toString() {
    return "id=$id, firstName=$firstName, lastName=$lastName, dob=$dob, contactNum=$contactNum, address=$address";
  }
}
