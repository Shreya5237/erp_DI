import 'package:flutter_test/flutter_test.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';
import 'package:digital_inertia_erp/models/user_role.dart';

void main() {
  group('Authentication, Role Mapping & Portal Consistency Tests', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
      erp.switchToDemoMode();
    });

    test('All 18 canonical corporate employee accounts authenticate successfully with password123!', () async {
      final accounts = [
        // Technical
        'arjun.sharma@digitalinertia.com',
        'priya.nair@digitalinertia.com',
        'karthik.r@digitalinertia.com',
        'sneha.v@digitalinertia.com',
        'rohan.mehta@digitalinertia.com',
        'ananya.deshmukh@digitalinertia.com',
        'vikram.singh@digitalinertia.com',
        'neha.patel@digitalinertia.com',
        'rahul.verma@digitalinertia.com',
        'divya.iyer@digitalinertia.com',
        // HR
        'meera.joshi@digitalinertia.com',
        'shreya.kulkarni@digitalinertia.com',
        // Sales & Marketing
        'rajesh.kumar@digitalinertia.com',
        'kavita.rao@digitalinertia.com',
        // Digital Marketing
        'sanjay.menon@digitalinertia.com',
        'aditya.sen@digitalinertia.com',
        // Finance
        'siddharth.roy@digitalinertia.com',
        'pooja.hegde@digitalinertia.com',
      ];

      for (final email in accounts) {
        final success = await erp.authenticateUser(email, 'password123!');
        expect(success, isTrue, reason: 'Failed to authenticate $email');
        expect(erp.currentUserEmail, equals(email));
      }
    });

    test('Sales & Marketing and Digital Marketing roles map to SalesNavigationScreen roles', () async {
      await erp.authenticateUser('rajesh.kumar@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.salesMarketing));

      await erp.authenticateUser('kavita.rao@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.salesMarketing));

      await erp.authenticateUser('sanjay.menon@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.digitalMarketing));

      await erp.authenticateUser('aditya.sen@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.digitalMarketing));
    });

    test('HR personnel map to UserRole.hr', () async {
      await erp.authenticateUser('meera.joshi@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.hr));
    });

    test('Finance personnel map to UserRole.finance', () async {
      await erp.authenticateUser('siddharth.roy@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.finance));

      await erp.authenticateUser('pooja.hegde@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.finance));
    });

    test('Technical personnel map to UserRole.poc or UserRole.technical', () async {
      await erp.authenticateUser('arjun.sharma@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.poc));

      await erp.authenticateUser('priya.nair@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.poc));

      await erp.authenticateUser('karthik.r@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.poc));

      await erp.authenticateUser('sneha.v@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.technical));
    });

    test('Interns always map to UserRole.intern (never elevated to manager/department roles)', () async {
      // Collegemail format
      await erp.authenticateUser('lavanya.s@collegemail.edu', 'password123!');
      expect(erp.currentRole, equals(UserRole.intern));

      // Corporate alias format
      await erp.authenticateUser('lavanya.sundaram@digitalinertia.com', 'password123!');
      expect(erp.currentRole, equals(UserRole.intern));

      await erp.authenticateUser('manish.chawla@collegemail.edu', 'password123!');
      expect(erp.currentRole, equals(UserRole.intern));

      await erp.authenticateUser('kunal.trivedi@collegemail.edu', 'password123!');
      expect(erp.currentRole, equals(UserRole.intern));

      await erp.authenticateUser('nandini.rao@collegemail.edu', 'password123!');
      expect(erp.currentRole, equals(UserRole.intern));

      await erp.authenticateUser('aarav.gupta@collegemail.edu', 'password123!');
      expect(erp.currentRole, equals(UserRole.intern));
    });

    test('Invalid credentials correctly reject login without silent bypass', () async {
      expect(
        () => erp.authenticateUser('rajesh.kumar@digitalinertia.com', 'wrongpassword'),
        throwsA(isA<Exception>()),
      );

      expect(
        () => erp.authenticateUser('nonexistent.user@digitalinertia.com', 'password123!'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
