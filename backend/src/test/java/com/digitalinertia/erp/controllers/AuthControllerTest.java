package com.digitalinertia.erp.controllers;

import com.digitalinertia.erp.entities.UserEntity;
import com.digitalinertia.erp.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @BeforeEach
    void setup() {
        userRepository.deleteAll();
        UserEntity testUser = new UserEntity(
                "USR-TEST",
                "laven@digitalinertia.com",
                passwordEncoder.encode("password123"),
                "Laven Lokesh",
                "ROLE_CEO",
                null
        );
        userRepository.save(testUser);
    }

    @Test
    void testSuccessfulLogin() throws Exception {
        String loginPayload = """
            {
                "email": "laven@digitalinertia.com",
                "password": "password123"
            }
        """;

        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginPayload))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.token").isNotEmpty())
                .andExpect(jsonPath("$.data.user.email").value("laven@digitalinertia.com"))
                .andExpect(jsonPath("$.data.user.role").value("ROLE_CEO"));
    }

    @Test
    void testInvalidPasswordFails() throws Exception {
        String invalidPayload = """
            {
                "email": "laven@digitalinertia.com",
                "password": "wrongpassword"
            }
        """;

        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(invalidPayload))
                .andExpect(status().isUnauthorized());
    }
}
