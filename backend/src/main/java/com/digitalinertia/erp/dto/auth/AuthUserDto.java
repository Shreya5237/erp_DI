package com.digitalinertia.erp.dto.auth;

public class AuthUserDto {
    private String id;
    private String email;
    private String fullName;
    private String role;
    private String employeeId;

    public AuthUserDto() {}

    public AuthUserDto(String id, String email, String fullName, String role, String employeeId) {
        this.id = id;
        this.email = email;
        this.fullName = fullName;
        this.role = role;
        this.employeeId = employeeId;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getEmployeeId() { return employeeId; }
    public void setEmployeeId(String employeeId) { this.employeeId = employeeId; }
}
