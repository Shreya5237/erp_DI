package com.digitalinertia.erp.security;

import com.digitalinertia.erp.entities.UserEntity;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

public class UserPrincipal implements UserDetails {

    private final String id;
    private final String email;
    private final String password;
    private final String fullName;
    private final String role;
    private final String employeeId;
    private final boolean active;
    private final Collection<? extends GrantedAuthority> authorities;

    public UserPrincipal(UserEntity user) {
        this.id = user.getId();
        this.email = user.getEmail();
        this.password = user.getPasswordHash();
        this.fullName = user.getFullName();
        this.role = user.getRole();
        this.employeeId = user.getEmployeeId();
        this.active = user.isActive();
        java.util.List<GrantedAuthority> authList = new java.util.ArrayList<>();
        if (user.getRole() != null && !user.getRole().isBlank()) {
            authList.add(new SimpleGrantedAuthority(user.getRole()));
            if (user.getRole().startsWith("ROLE_")) {
                authList.add(new SimpleGrantedAuthority(user.getRole().substring(5)));
                authList.add(new SimpleGrantedAuthority("ROLE_" + user.getRole()));
            } else {
                authList.add(new SimpleGrantedAuthority("ROLE_" + user.getRole()));
            }
        }
        this.authorities = Collections.unmodifiableList(authList);
    }

    public String getId() { return id; }
    public String getEmail() { return email; }
    public String getFullName() { return fullName; }
    public String getRole() { return role; }
    public String getEmployeeId() { return employeeId; }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return active;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return active;
    }
}
