import 'package:flutter_test/flutter_test.dart';
import 'package:digital_inertia_erp/models/department.dart';
import 'package:digital_inertia_erp/models/employee.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';

void main() {
  group('Department Hierarchy and Top-Level Structure Tests', () {
    test('Exactly five top-level departments exist in CompanyDepartment', () {
      final departments = CompanyDepartment.values;
      expect(departments.length, equals(5));

      final names = departments.map((d) => d.title).toSet();
      expect(
        names,
        equals({'Finance', 'Sales', 'Marketing', 'HR', 'Technical'}),
      );
    });

    test('Each top-level department has defined subcategories', () {
      expect(CompanyDepartment.finance.subcategories, containsAll(['Accounts', 'Payroll', 'Budgeting', 'Invoicing']));
      expect(CompanyDepartment.sales.subcategories, containsAll(['Business Development', 'Lead Management', 'Client Acquisition', 'Account Management']));
      expect(CompanyDepartment.marketing.subcategories, containsAll(['Digital Marketing', 'SEO', 'Social Media', 'Content Marketing', 'Branding']));
      expect(CompanyDepartment.hr.subcategories, containsAll(['Recruitment', 'Onboarding', 'Training', 'Leave Management', 'Performance Management']));
      expect(CompanyDepartment.technical.subcategories, containsAll(['Frontend', 'Backend', 'Full-stack', 'Mobile Development', 'UI/UX', 'QA', 'DevOps', 'AI/ML']));
    });

    test('All employees in ErpProvider have valid primary departments and subcategories', () {
      final provider = ErpProvider();
      final employees = provider.allEmployees;

      expect(employees.isNotEmpty, isTrue);
      final validDepartmentNames = {'Finance', 'Sales', 'Marketing', 'HR', 'Technical'};
      final validDepartmentIds = {'DEPT-FIN', 'DEPT-SAL', 'DEPT-MKT', 'DEPT-HR', 'DEPT-TECH'};

      for (final emp in employees) {
        expect(validDepartmentNames.contains(emp.department), isTrue,
            reason: 'Employee ${emp.id} has invalid department: ${emp.department}');
        expect(validDepartmentIds.contains(emp.departmentId), isTrue,
            reason: 'Employee ${emp.id} has invalid departmentId: ${emp.departmentId}');
        expect(emp.subDepartmentName != null && emp.subDepartmentName!.isNotEmpty, isTrue,
            reason: 'Employee ${emp.id} is missing subDepartmentName');
        expect(emp.subDepartmentId != null && emp.subDepartmentId!.isNotEmpty, isTrue,
            reason: 'Employee ${emp.id} is missing subDepartmentId');
      }
    });

    test('Employee model serialization preserves department and subcategory fields', () {
      final employee = Employee(
        id: 'EMP-999',
        name: 'Jane Doe',
        email: 'jane@digitalinertia.com',
        phone: '+1-555-0199',
        department: 'Technical',
        departmentId: 'DEPT-TECH',
        subDepartmentName: 'Backend',
        subDepartmentId: 'DEPT-SUB-BACKEND',
        role: 'Senior Backend Developer',
        joiningDate: DateTime(2025, 1, 15),
        employmentStatus: 'Full-time',
      );

      final json = employee.toJson();
      expect(json['department'], equals('Technical'));
      expect(json['departmentId'], equals('DEPT-TECH'));
      expect(json['subDepartmentName'], equals('Backend'));
      expect(json['subDepartmentId'], equals('DEPT-SUB-BACKEND'));

      final reconstructed = Employee.fromJson(json);
      expect(reconstructed.department, equals('Technical'));
      expect(reconstructed.departmentId, equals('DEPT-TECH'));
      expect(reconstructed.subDepartmentName, equals('Backend'));
      expect(reconstructed.subDepartmentId, equals('DEPT-SUB-BACKEND'));
    });

    test('DepartmentItem correctly models hierarchical tree from backend JSON', () {
      final json = {
        'id': 'DEPT-TECH',
        'name': 'Technical',
        'code': 'TECH',
        'parentId': null,
        'description': 'Engineering and technical systems',
        'active': true,
        'subcategories': [
          {
            'id': 'DEPT-SUB-BACKEND',
            'name': 'Backend',
            'code': 'TECH-BE',
            'parentId': 'DEPT-TECH',
            'parentName': 'Technical',
            'description': 'Server-side development',
            'active': true,
            'subcategories': [],
          },
          {
            'id': 'DEPT-SUB-FRONTEND',
            'name': 'Frontend',
            'code': 'TECH-FE',
            'parentId': 'DEPT-TECH',
            'parentName': 'Technical',
            'description': 'Web user interface engineering',
            'active': true,
            'subcategories': [],
          }
        ]
      };

      final item = DepartmentItem.fromJson(json);
      expect(item.id, equals('DEPT-TECH'));
      expect(item.name, equals('Technical'));
      expect(item.isTopLevel, isTrue);
      expect(item.subcategories.length, equals(2));
      expect(item.subcategories[0].name, equals('Backend'));
      expect(item.subcategories[0].parentId, equals('DEPT-TECH'));
      expect(item.subcategories[0].isTopLevel, isFalse);
    });

    test('ErpProvider topLevelDepartmentNames and departmentSubcategories getters operate correctly', () {
      final provider = ErpProvider();
      final topLevels = provider.topLevelDepartmentNames;
      expect(topLevels.length, equals(5));
      expect(topLevels, containsAll(['Finance', 'Sales', 'Marketing', 'HR', 'Technical']));

      final techSubs = provider.departmentSubcategories['Technical'];
      expect(techSubs, isNotNull);
      expect(techSubs, contains('Backend'));
      expect(techSubs, contains('Frontend'));

      final finSubs = provider.departmentSubcategories['Finance'];
      expect(finSubs, isNotNull);
      expect(finSubs, contains('Accounts'));
      expect(finSubs, contains('Payroll'));
    });
  });
}
