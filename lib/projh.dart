void _require(bool condition, String message) {
  if (!condition) throw ArgumentError(message);
}

class Person {
  String name;
  int age;
  String phone;
  String address;

  Person(this.name, this.age, this.phone, this.address) {
    _require(name.isNotEmpty, 'Name must not be empty.');
    _require(age >= 0, 'Age must be non-negative.');
    _require(phone.isNotEmpty, 'Phone must not be empty.');
    _require(address.isNotEmpty, 'Address must not be empty.');
  }
}

class Professor extends Person {
  final Set<Course> _taughtCourses = <Course>{};
  int salary;

  Professor(
    String name,
    int age,
    String phone,
    String address,
    this.salary,
  ) : super(name, age, phone, address) {
    _require(salary >= 0, 'Salary must be non-negative.');
  }

  Set<Course> get taughtCourses => Set.unmodifiable(_taughtCourses);

  bool get isBonusEligible => _taughtCourses.length >= 4;

  void _addCourse(Course course) {
    _taughtCourses.add(course);
  }

  void _removeCourse(Course course) {
    _taughtCourses.remove(course);
  }
}

class Student extends Person {
  static const int maxCourses = 6;

  final Map<Course, Grade> _grades;
  bool isInternational;

  Student(
    Map<Course, Grade> grades,
    this.isInternational,
    String name,
    int age,
    String phone,
    String address,
  )   : _grades = Map.of(grades),
        super(name, age, phone, address) {
    _ensureCourseBounds();
  }

  Map<Course, Grade> get grades => Map.unmodifiable(_grades);

  bool get isFullTime => _grades.length >= 3;

  double? get averageScore {
    final scored = _grades.values.where((g) => g.score != null).map((g) => g.score!).toList();
    if (scored.isEmpty) return null;
    return scored.reduce((a, b) => a + b) / scored.length;
  }

  bool get isOnAcademicProbation {
    final avg = averageScore;
    if (avg == null) return false;
    return avg < 60;
  }

  void addGrade(Grade grade) {
    _grades[grade.course] = grade;
    _ensureCourseBounds();
  }

  void ensureGradeForCourse(Course course) {
    _grades.putIfAbsent(course, () => Grade(course, null));
    _ensureCourseBounds();
  }

  void removeGradeByCourse(Course course) {
    _grades.remove(course);
    _ensureCourseBounds();
  }

  void _ensureCourseBounds() {
    if (_grades.length > maxCourses) {
      throw StateError('Students may not enroll in more than $maxCourses courses.');
    }
  }
}

class Course {
  final String department; // 2-3 uppercase letters
  final int number; // 0-999
  final String name;
  final Set<Professor> _professors;
  final Set<Student> _students;
  final int maxStudents;
  final int minStudents;

  Course(
    this.department,
    this.number,
    this.name,
    Iterable<Professor> professors,
    this.maxStudents,
    this.minStudents,
  )   : _professors = Set.from(professors),
        _students = <Student>{} {
    _validate();
    _registerProfessors();
    _enforceMax();
  }

  String get code => '$department${number.toString().padLeft(3, '0')}';

  Set<Professor> get professors => Set.unmodifiable(_professors);
  Set<Student> get students => Set.unmodifiable(_students);

  bool get isUnderEnrolled => _students.length < minStudents;

  void addStudent(Student student) {
    if (_students.contains(student)) return;
    if (_students.length >= maxStudents) {
      throw StateError('Course $code is at capacity ($maxStudents).');
    }
    _students.add(student);
    student.ensureGradeForCourse(this);
    _enforceMax();
  }

  void _validate() {
    _require(RegExp(r'^[A-Z]{2}$').hasMatch(department), 'Department must be exactly 2 uppercase letters.');
    _require(number >= 0 && number <= 999, 'Course number must be between 000 and 999.');
    _require(name.isNotEmpty, 'Course name must not be empty.');
    _require(maxStudents >= 1, 'maxStudents must be at least 1.');
    _require(minStudents >= 1, 'minStudents must be at least 1.');
    _require(maxStudents >= minStudents, 'maxStudents must be >= minStudents.');
  }

  void _enforceMax() {
    if (_students.length > maxStudents) {
      throw StateError('Course $code cannot exceed $maxStudents students.');
    }
  }

  void _registerProfessors() {
    for (final professor in _professors) {
      professor._addCourse(this);
    }
  }
}

class University {
  final Set<Person> _people = <Person>{};
  final Set<Professor> _professors = <Professor>{};
  final Set<Student> _students = <Student>{};
  final Set<Course> _courses = <Course>{};

  University();

  Set<Person> get people => Set.unmodifiable(_people);
  Set<Professor> get professors => Set.unmodifiable(_professors);
  Set<Student> get students => Set.unmodifiable(_students);
  Set<Course> get courses => Set.unmodifiable(_courses);

  void addPerson(Person person) {
    _people.add(person);
    if (person is Professor) {
      _professors.add(person);
    } else if (person is Student) {
      _students.add(person);
    }
  }

  void addProfessor(Professor professor) {
    _professors.add(professor);
    _people.add(professor);
  }

  void addStudent(Student student) {
    _students.add(student);
    _people.add(student);
  }

  void addCourse(Course course) {
    _courses.add(course);
  }

  void removeCourse(Course course) {
    _courses.remove(course);
    // Clean up links.
    for (final professor in _professors) {
      professor._removeCourse(course);
    }
    for (final student in _students) {
      student.removeGradeByCourse(course);
    }
  }

  void removeUnderEnrolledCourses() {
    for (final course in _courses.toList()) {
      if (course.isUnderEnrolled) {
        removeCourse(course);
      }
    }
  }

  void enrollStudentInCourses(Student student, Iterable<Course> targetCourses) {
    for (final course in targetCourses) {
      course.addStudent(student);
      _courses.add(course); // ensure registry knows about it
      _students.add(student);
      _people.add(student);
    }
  }
}

class Grade {
  Course course;
  int? _score;

  Grade(this.course, int? score) {
    this.score = score;
  }

  int? get score => _score;

  set score(int? value) {
    if (value != null && (value < 0 || value > 100)) {
      throw ArgumentError('Score must be between 0 and 100 inclusive.');
    }
    _score = value;
  }
}

/*

phases:
0 - create all people
1 - create all tentative courses with professors assigned
2 - use enroll function to add students to courses (6 courses max per student) and courses to their grades (scores initially null)
3 - deactivate courses if they don't have enough students (remove from professors' taught courses and students' grades)
4 - assign scores to students' grades

*/