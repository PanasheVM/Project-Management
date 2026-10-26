package com.stageflow.tenants;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "companies")
public class Company {
    @Id private UUID id;
    @Column(nullable = false) private String name;
    private String description;
    @Column(name = "time_zone", nullable = false) private String timeZone;
    @Column(name = "default_currency", nullable = false, length = 3) private String defaultCurrency;
    @Column(nullable = false) private boolean active;
    @Column(name = "created_at", nullable = false, updatable = false) private Instant createdAt;
    @Column(name = "updated_at", nullable = false) private Instant updatedAt;
    @Version private long version;

    protected Company() {}

    public Company(String name, String description, String timeZone, String defaultCurrency) {
        this.id = UUID.randomUUID();
        this.name = name;
        this.description = description;
        this.timeZone = timeZone;
        this.defaultCurrency = defaultCurrency;
        this.active = true;
        this.createdAt = Instant.now();
        this.updatedAt = this.createdAt;
    }

    public UUID getId() { return id; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public String getTimeZone() { return timeZone; }
    public String getDefaultCurrency() { return defaultCurrency; }
    public boolean isActive() { return active; }
}
