package com.stageflow.tenants;

import com.stageflow.identity.UserAccount;
import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "company_memberships", uniqueConstraints = @UniqueConstraint(columnNames = {"company_id", "user_id"}))
public class CompanyMembership {
    public enum Role { COMPANY_OWNER, COMPANY_ADMIN, PROJECT_MANAGER, DEPARTMENT_HEAD, CREW_MEMBER, FREELANCER }
    public enum Status { INVITED, ACTIVE, SUSPENDED, REMOVED }

    @Id private UUID id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "company_id") private Company company;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "user_id") private UserAccount user;
    @Enumerated(EnumType.STRING) @Column(nullable = false) private Role role;
    @Enumerated(EnumType.STRING) @Column(nullable = false) private Status status;
    @Column(name = "created_at", nullable = false, updatable = false) private Instant createdAt;
    @Version private long version;

    protected CompanyMembership() {}

    public CompanyMembership(Company company, UserAccount user, Role role) {
        this.id = UUID.randomUUID();
        this.company = company;
        this.user = user;
        this.role = role;
        this.status = Status.ACTIVE;
        this.createdAt = Instant.now();
    }

    public Company getCompany() { return company; }
    public Role getRole() { return role; }
}
