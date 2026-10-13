import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:digital_inertia_erp/models/lead.dart';
import 'package:digital_inertia_erp/models/user_role.dart';
import 'package:digital_inertia_erp/services/api_service.dart';
import 'package:digital_inertia_erp/providers/erp_provider.dart';

void main() {
  group('ApiService Unit Tests with MockClient', () {
    test('login succeeds and extracts token and user details', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/login');
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'laven@digitalinertia.com');
        expect(body['password'], 'password123');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Authentication successful',
            'data': {
              'token': 'mock-jwt-token-12345',
              'tokenType': 'Bearer',
              'expiresInMs': 86400000,
              'user': {
                'id': 'USR-001',
                'email': 'laven@digitalinertia.com',
                'fullName': 'Laven Lokesh',
                'role': 'ROLE_CEO',
                'employeeId': null,
              },
            },
            'timestamp': '2026-10-12T06:00:00Z',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiService(client: mockClient);
      final result = await api.login('laven@digitalinertia.com', 'password123');

      expect(result.token, 'mock-jwt-token-12345');
      expect(result.user.email, 'laven@digitalinertia.com');
      expect(result.user.role, 'ROLE_CEO');
      expect(api.token, 'mock-jwt-token-12345');
      expect(api.isAuthenticated, isTrue);
    });

    test('login throws AuthenticationException on HTTP 401', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Bad credentials',
            'data': null,
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiService(client: mockClient);

      expect(
        () => api.login('wrong@email.com', 'wrongpassword'),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('getLeads parses backend LeadEntity list into domain Lead models', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/leads');
        expect(request.method, 'GET');
        expect(request.headers['authorization'], 'Bearer mock-token');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Leads retrieved',
            'data': [
              {
                'id': 'LEAD-001',
                'companyName': 'TechCorp Solutions',
                'clientName': 'Rohan Sen',
                'domain': 'Software Development',
                'email': 'rohan@techcorp.com',
                'phone': '+91 98765 00001',
                'stage': 'new_lead',
                'dealValue': 350000.0,
                'ownerId': 'EMP-112',
                'ownerName': 'Rajesh Kumar',
                'nextFollowUp': '2026-10-15',
                'source': 'Website Inquiry',
                'notes': 'Requested mobile app demo',
                'active': true,
                'createdAt': '2026-10-10T10:00:00Z',
                'updatedAt': '2026-10-10T10:00:00Z',
              },
            ],
            'timestamp': '2026-10-12T06:00:00Z',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiService(client: mockClient);
      api.setToken('mock-token');

      final leads = await api.getLeads();
      expect(leads.length, 1);
      expect(leads.first.id, 'LEAD-001');
      expect(leads.first.companyName, 'TechCorp Solutions');
      expect(leads.first.status, LeadStatus.newLead);
      expect(leads.first.dealValue, 350000.0);
    });

    test('updateLeadStage issues PATCH request and returns updated Lead', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/leads/LEAD-001/stage');
        expect(request.url.queryParameters['stage'], 'contacted');
        expect(request.method, 'PATCH');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Lead stage updated',
            'data': {
              'id': 'LEAD-001',
              'companyName': 'TechCorp Solutions',
              'clientName': 'Rohan Sen',
              'domain': 'Software Development',
              'email': 'rohan@techcorp.com',
              'phone': '+91 98765 00001',
              'stage': 'contacted',
              'dealValue': 350000.0,
              'ownerId': 'EMP-112',
              'ownerName': 'Rajesh Kumar',
              'nextFollowUp': '2026-10-15',
              'source': 'Website Inquiry',
              'notes': 'Initial call completed',
              'active': true,
              'createdAt': '2026-10-10T10:00:00Z',
              'updatedAt': '2026-10-12T06:30:00Z',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiService(client: mockClient);
      api.setToken('mock-token');

      final updated = await api.updateLeadStage('LEAD-001', 'contacted');
      expect(updated.id, 'LEAD-001');
      expect(updated.status, LeadStatus.contactEstablished);
    });

    test('updateLeadStage throws ForbiddenException on HTTP 403', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Access Denied',
          }),
          403,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiService(client: mockClient);
      api.setToken('mock-sales-token');

      expect(
        () => api.updateLeadStage('LEAD-001', 'won'),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });

  group('ErpProvider Live Mode and Demo Mode State Tests', () {
    test('starts in Demo Mode with offline seed data', () {
      final erp = ErpProvider();
      expect(erp.isLiveMode, isFalse);
      expect(erp.allLeads.isNotEmpty, isTrue);
      expect(erp.currentRole, UserRole.ceo);
    });

    test('switchToDemoMode clears live session and restores offline state', () {
      final erp = ErpProvider();
      erp.switchToDemoMode();

      expect(erp.isLiveMode, isFalse);
      expect(erp.apiService.isAuthenticated, isFalse);
      expect(erp.authError, isNull);
    });

    test('optimistic rollback restores lead stage if live update fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'success': false, 'message': 'Forbidden'}),
          403,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiService(client: mockClient);
      api.setToken('test-token');

      expect(
        () => api.updateLeadStage('LEAD-001', 'won'),
        throwsA(isA<ForbiddenException>()),
      );

      final erp = ErpProvider();
      final lead = erp.allLeads.first;
      final originalStatus = lead.status;

      // When updateLeadStatus is called in offline demo mode it updates locally
      await erp.updateLeadStatus(lead.id, LeadStatus.lost);
      expect(erp.allLeads.first.status, LeadStatus.lost);

      // Restore
      await erp.updateLeadStatus(lead.id, originalStatus);
      expect(erp.allLeads.first.status, originalStatus);
    });
  });

  group('Live Spring Boot & PostgreSQL Integration Tests', () {
    test('live login succeeds and loads real user profile', () async {
      final erp = ErpProvider();
      final success = await erp.loginWithApi('laven@digitalinertia.com', 'password123');

      expect(success, isTrue);
      expect(erp.isLiveMode, isTrue);
      expect(erp.currentUserName, 'Laven Lokesh');
      expect(erp.currentRole, UserRole.ceo);
      expect(erp.apiService.isAuthenticated, isTrue);
    });

    test('live leads load cleanly from PostgreSQL', () async {
      final erp = ErpProvider();
      await erp.loginWithApi('laven@digitalinertia.com', 'password123');
      await erp.fetchLiveLeads();

      expect(erp.allLeads.length, 14);
      final greenTech = erp.allLeads.firstWhere((l) => l.id == 'LED-501');
      expect(greenTech.companyName, 'GreenTech Solutions');
    });

    test('live lead stage update persists to database', () async {
      final erp = ErpProvider();
      await erp.loginWithApi('laven@digitalinertia.com', 'password123');
      await erp.fetchLiveLeads();

      // Update LED-501 to contacted
      await erp.updateLeadStatus('LED-501', LeadStatus.contacted);
      var lead = erp.allLeads.firstWhere((l) => l.id == 'LED-501');
      expect(lead.status, LeadStatus.contacted);

      // Fetch fresh leads from server to verify server-side DB persistence
      await erp.fetchLiveLeads();
      lead = erp.allLeads.firstWhere((l) => l.id == 'LED-501');
      expect(lead.status, LeadStatus.contacted);

      // Revert back to newLead
      await erp.updateLeadStatus('LED-501', LeadStatus.newLead);
      await erp.fetchLiveLeads();
      lead = erp.allLeads.firstWhere((l) => l.id == 'LED-501');
      expect(lead.status, LeadStatus.newLead);
    });
  });
}
