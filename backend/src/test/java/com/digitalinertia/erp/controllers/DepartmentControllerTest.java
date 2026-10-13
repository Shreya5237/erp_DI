package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.dto.employee.EmployeeUpsertRequest;
import com.digitalinertia.erp.entities.DepartmentEntity;
import com.digitalinertia.erp.entities.enums.RoleCategory;
import com.digitalinertia.erp.repositories.DepartmentRepository;
import com.digitalinertia.erp.services.DepartmentService;
import com.digitalinertia.erp.services.EmployeeService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class DepartmentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private DepartmentRepository departmentRepository;

    @Autowired
    private DepartmentService departmentService;

    @Autowired
    private EmployeeService employeeService;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        if (departmentRepository.count() == 0) {
            // Seed the 5 approved root departments
            DepartmentEntity fin = new DepartmentEntity("DEPT-FIN", "Finance", "FIN", null, "Finance desc");
            DepartmentEntity sal = new DepartmentEntity("DEPT-SAL", "Sales", "SAL", null, "Sales desc");
            DepartmentEntity mkt = new DepartmentEntity("DEPT-MKT", "Marketing", "MKT", null, "Marketing desc");
            DepartmentEntity hr = new DepartmentEntity("DEPT-HR", "HR", "HR", null, "HR desc");
            DepartmentEntity tech = new DepartmentEntity("DEPT-TECH", "Technical", "TECH", null, "Tech desc");

            departmentRepository.saveAll(List.of(fin, sal, mkt, hr, tech));

            // Seed subcategories
            DepartmentEntity finAcc = new DepartmentEntity("DEPT-FIN-ACC", "Accounts", "FIN-ACC", "DEPT-FIN", "Accounts desc");
            DepartmentEntity techFe = new DepartmentEntity("DEPT-TEC-FE", "Frontend", "TEC-FE", "DEPT-TECH", "Frontend desc");
            DepartmentEntity techBe = new DepartmentEntity("DEPT-TEC-BE", "Backend", "TEC-BE", "DEPT-TECH", "Backend desc");
            DepartmentEntity hrRec = new DepartmentEntity("DEPT-HR-REC", "Recruitment", "HR-REC", "DEPT-HR", "Recruitment desc");
            DepartmentEntity salBd = new DepartmentEntity("DEPT-SAL-BD", "Business Development", "SAL-BD", "DEPT-SAL", "BD desc");
            DepartmentEntity mktDig = new DepartmentEntity("DEPT-MKT-DIG", "Digital Marketing", "MKT-DIG", "DEPT-MKT", "Digital Marketing desc");

            departmentRepository.saveAll(List.of(finAcc, techFe, techBe, hrRec, salBd, mktDig));
        }
    }

    @Test
    @DisplayName("Verify exactly 5 top-level departments exist in repository")
    void testExactlyFiveTopLevelDepartmentsExist() {
        List<DepartmentEntity> roots = departmentRepository.findByParentIdIsNullAndActiveTrueOrderByNameAsc();
        assertEquals(5, roots.size(), "System must have exactly 5 top-level departments");

        List<String> names = roots.stream().map(DepartmentEntity::getName).toList();
        assertTrue(names.contains("Finance"));
        assertTrue(names.contains("Sales"));
        assertTrue(names.contains("Marketing"));
        assertTrue(names.contains("HR"));
        assertTrue(names.contains("Technical"));
    }

    @Test
    @WithMockUser
    @DisplayName("GET /departments/roots returns the 5 approved top-level departments")
    void testGetRootDepartmentsApi() throws Exception {
        mockMvc.perform(get("/departments/roots"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data", hasSize(5)))
                .andExpect(jsonPath("$.data[*].name", containsInAnyOrder("Finance", "Sales", "Marketing", "HR", "Technical")));
    }

    @Test
    @WithMockUser
    @DisplayName("GET /departments returns tree with subcategories")
    void testGetDepartmentTreeApi() throws Exception {
        mockMvc.perform(get("/departments"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data", hasSize(5)))
                .andExpect(jsonPath("$.data[?(@.id == 'DEPT-TECH')].subcategories", notNullValue()));
    }

    @Test
    @WithMockUser
    @DisplayName("GET /departments/{id}/subcategories returns children for valid root")
    void testGetSubcategoriesForRoot() throws Exception {
        mockMvc.perform(get("/departments/DEPT-TECH/subcategories"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data", hasSize(greaterThanOrEqualTo(2))));
    }

    @Test
    @DisplayName("Validation rejects non-root department as primary department")
    void testValidationRejectsSubcategoryAsPrimary() {
        assertThrows(Exception.class, () -> {
            departmentService.validateDepartmentAssignment("DEPT-TEC-FE", null);
        });
    }

    @Test
    @DisplayName("Validation rejects mismatched subcategory from different parent")
    void testValidationRejectsMismatchedSubcategory() {
        assertThrows(Exception.class, () -> {
            departmentService.validateDepartmentAssignment("DEPT-FIN", "DEPT-TEC-FE");
        });
    }

    @Test
    @DisplayName("Validation succeeds for valid root and child subcategory")
    void testValidationSucceedsForValidPair() {
        assertDoesNotThrow(() -> {
            departmentService.validateDepartmentAssignment("DEPT-TECH", "DEPT-TEC-FE");
        });
    }

    @Test
    @WithMockUser
    @DisplayName("POST /employees fails when department is mismatched")
    void testEmployeeCreationValidationFailure() throws Exception {
        EmployeeUpsertRequest req = new EmployeeUpsertRequest();
        req.setName("Test Employee");
        req.setEmail("test.emp@digitalinertia.com");
        req.setPhone("+91 99999 88888");
        req.setRoleId("ROLE-FE");
        req.setRoleTitle("Frontend Developer");
        req.setTeamId("TEAM-FE");
        req.setTeamName("Client Experience Engineering");
        req.setCategory(RoleCategory.technical);
        req.setDepartmentId("DEPT-FIN"); // Finance root
        req.setSubDepartmentId("DEPT-TEC-FE"); // Technical subcategory (mismatch!)

        mockMvc.perform(post("/employees")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isBadRequest());
    }
}
