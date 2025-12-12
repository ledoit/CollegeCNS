import 'package:projh/projh.dart';
import 'package:test/test.dart';

void main() {
  test('course validation enforces department/number/name', () {
    expect(
      () => Course('CS', 101, '', [], 10, 1),
      throwsArgumentError,
    );
    expect(
      () => Course('cS', 101, 'Intro', [], 10, 1),
      throwsArgumentError,
    );
    expect(
      () => Course('CSE', 101, 'Intro', [], 10, 1),
      throwsArgumentError,
    );
    expect(
      () => Course('CS', 1000, 'Intro', [], 10, 1),
      throwsArgumentError,
    );
    final course = Course('CS', 101, 'Intro', [], 10, 1);
    expect(course.code, 'CS101');
  });

  test('adding a student enrolls and creates a null grade', () {
    final student = Student({}, false, 'Alice', 20, '555', 'Addr');
    final course = Course('MA', 201, 'Calc', [], 1, 1);

    course.addStudent(student);

    expect(course.students, contains(student));
    expect(student.grades.containsKey(course), isTrue);
    expect(student.grades[course]!.score, isNull);
  });

  test('student max courses enforced', () {
    final student = Student({}, false, 'Bob', 19, '555', 'Addr');
    final courses = List.generate(
      6,
      (i) => Course('CS', 100 + i, 'Course $i', [], 5, 1),
    );
    for (final c in courses) {
      c.addStudent(student);
    }
    final extra = Course('CS', 200, 'Extra', [], 5, 1);
    expect(() => extra.addStudent(student), throwsStateError);
  });

  test('probation ignores null scores and triggers below 60 avg', () {
    final c1 = Course('PH', 101, 'Phys', [], 5, 1);
    final c2 = Course('PH', 102, 'Phys2', [], 5, 1);
    final student = Student({}, false, 'Cara', 21, '555', 'Addr');
    c1.addStudent(student); // null score
    c2.addStudent(student);
    student.grades[c2]!.score = 100;
    expect(student.isOnAcademicProbation, isFalse);
    student.grades[c2]!.score = 50;
    expect(student.isOnAcademicProbation, isTrue);
  });

  test('deactivation removes course from university and professors/students links', () {
    final prof = Professor('Prof', 50, '555', 'Addr', 100000);
    final course = Course('BI', 101, 'Bio', [prof], 5, 2);
    final uni = University()..addCourse(course)..addProfessor(prof);
    final student = Student({}, false, 'Stu', 18, '555', 'Addr');
    course.addStudent(student); // now 1 student, still under min 2
    uni.addStudent(student);

    uni.removeUnderEnrolledCourses();

    expect(uni.courses.contains(course), isFalse);
    expect(prof.taughtCourses.contains(course), isFalse);
    expect(student.grades.containsKey(course), isFalse);
  });
}
