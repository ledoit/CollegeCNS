import 'package:flutter/material.dart';

// -----------------------------------------------------
//  IMPORT YOUR EXISTING MODEL CLASSES HERE
//  (Paste all of your provided Dart classes into
//   lib/models/university_models.dart for cleanliness.)
// -----------------------------------------------------
import 'models/university_models.dart';

void main() {
  runApp(const UniversityApp());
}

class UniversityApp extends StatelessWidget {
  const UniversityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Manager',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const UniversityHomePage(),
    );
  }
}

class UniversityHomePage extends StatefulWidget {
  const UniversityHomePage({super.key});

  @override
  State<UniversityHomePage> createState() => _UniversityHomePageState();
}

class _UniversityHomePageState extends State<UniversityHomePage> {
  final University uni = University();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("University Manager")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Add Professor"),
            trailing: const Icon(Icons.person_add),
            onTap: () => _openAddProfessor(),
          ),
          ListTile(
            title: const Text("Add Student"),
            trailing: const Icon(Icons.school),
            onTap: () => _openAddStudent(),
          ),
          ListTile(
            title: const Text("Add Course"),
            trailing: const Icon(Icons.book),
            onTap: () => _openAddCourse(),
          ),
          const Divider(),
          _buildSectionHeader("Professors"),
          ...uni.professors.map(_buildProfessorTile),
          const Divider(),
          _buildSectionHeader("Students"),
          ...uni.students.map(_buildStudentTile),
          const Divider(),
          _buildSectionHeader("Courses"),
          ...uni.courses.map(_buildCourseTile),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      );

  // ================================
  //     PROFESSOR UI TILE
  // ================================
  Widget _buildProfessorTile(Professor p) {
    return ListTile(
      title: Text(p.name),
      subtitle: Text("Age: ${p.age} | Salary: \$${p.salary} | Courses: ${p.taughtCourses.length}"),
    );
  }

  // ================================
  //     STUDENT UI TILE
  // ================================
  Widget _buildStudentTile(Student s) {
    return ListTile(
      title: Text(s.name),
      subtitle: Text("Courses: ${s.grades.length} | Avg: ${s.averageScore?.toStringAsFixed(1) ?? 'N/A'}"),
      onTap: () => _showEnrollDialog(s),
    );
  }

  // ================================
  //         COURSE UI TILE
  // ================================
  Widget _buildCourseTile(Course c) {
    return ListTile(
      title: Text("${c.code}: ${c.name}"),
      subtitle: Text("Professors: ${c.professors.length} | Students: ${c.students.length}"),
    );
  }

  // ----------------------------------------------------------
  //                    ADD PROFESSOR FORM
  // ----------------------------------------------------------
  void _openAddProfessor() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Professor"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: salaryCtrl, decoration: const InputDecoration(labelText: 'Salary'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () {
              try {
                final p = Professor(
                  nameCtrl.text,
                  int.parse(ageCtrl.text),
                  phoneCtrl.text,
                  addressCtrl.text,
                  int.parse(salaryCtrl.text),
                );
                setState(() => uni.addProfessor(p));
                Navigator.pop(context);
              } catch (e) {
                _showError(e.toString());
              }
            },
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  //                    ADD STUDENT FORM
  // ----------------------------------------------------------
  void _openAddStudent() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    bool isInternational = false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Student"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
              Row(
                children: [
                  const Text("International"),
                  Switch(
                    value: isInternational,
                    onChanged: (v) => setState(() => isInternational = v),
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () {
              try {
                final s = Student(
                  {},
                  isInternational,
                  nameCtrl.text,
                  int.parse(ageCtrl.text),
                  phoneCtrl.text,
                  addressCtrl.text,
                );
                setState(() => uni.addStudent(s));
                Navigator.pop(context);
              } catch (e) {
                _showError(e.toString());
              }
            },
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  //                    ADD COURSE FORM
  // ----------------------------------------------------------
  void _openAddCourse() {
    final deptCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final maxCtrl = TextEditingController();
    final minCtrl = TextEditingController();

    Professor? selectedProfessor;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text("Add Course"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Dept (2 letters)')),
                TextField(controller: numberCtrl, decoration: const InputDecoration(labelText: 'Number'), keyboardType: TextInputType.number),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: maxCtrl, decoration: const InputDecoration(labelText: 'Max Students'), keyboardType: TextInputType.number),
                TextField(controller: minCtrl, decoration: const InputDecoration(labelText: 'Min Students'), keyboardType: TextInputType.number),
                DropdownButton<Professor>(
                  hint: const Text("Select Professor"),
                  value: selectedProfessor,
                  items: uni.professors
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                      .toList(),
                  onChanged: (p) => setLocal(() => selectedProfessor = p),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () {
                try {
                  if (selectedProfessor == null) throw "Select a professor first.";

                  final c = Course(
                    deptCtrl.text,
                    int.parse(numberCtrl.text),
                    nameCtrl.text,
                    [selectedProfessor!],
                    int.parse(maxCtrl.text),
                    int.parse(minCtrl.text),
                  );

                  setState(() => uni.addCourse(c));
                  Navigator.pop(context);
                } catch (e) {
                  _showError(e.toString());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  //          ENROLL STUDENT IN EXISTING COURSES
  // ----------------------------------------------------------
  void _showEnrollDialog(Student s) {
    final selectable = uni.courses.toList();
    final selected = <Course>{};

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text("Enroll ${s.name}"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ...selectable.map((c) {
                  final isSel = selected.contains(c);
                  return CheckboxListTile(
                    title: Text("${c.code} - ${c.name}"),
                    value: isSel,
                    onChanged: (v) {
                      setLocal(() {
                        v == true ? selected.add(c) : selected.remove(c);
                      });
                    },
                  );
                })
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              child: const Text("Enroll"),
              onPressed: () {
                try {
                  setState(() => uni.enrollStudentInCourses(s, selected));
                  Navigator.pop(context);
                } catch (e) {
                  _showError(e.toString());
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }
}
