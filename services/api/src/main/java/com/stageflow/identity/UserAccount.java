package com.stageflow.identity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "user_accounts")
public class UserAccount {
    @Id private UUID id;
    @Column(name = "oidc_subject", nullable = false, unique = true, updatable = false) private String oidcSubject;
    @Column(nullable = false) private String email;
    @Column(name = "display_name", nullable = false) private String displayName;
    @Column(name = "created_at", nullable = false, updatable = false) private Instant createdAt;
    @Column(name = "updated_at", nullable = false) private Instant updatedAt;
    @Version private long version;

    protected UserAccount() {}

    public UserAccount(String oidcSubject, String email, String displayName) {
        this.id = UUID.randomUUID();
        this.oidcSubject = oidcSubject;
        this.email = email;
        this.displayName = displayName;
        this.createdAt = Instant.now();
        this.updatedAt = this.createdAt;
    }

    public UUID getId() { return id; }
    public String getOidcSubject() { return oidcSubject; }
    public String getEmail() { return email; }
    public String getDisplayName() { return displayName; }
}
