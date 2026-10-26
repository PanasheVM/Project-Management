package com.stageflow.tenants;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.util.UUID;

public final class CompanyDtos {
    private CompanyDtos() {}

    public record CreateCompanyRequest(
        @NotBlank @Size(max = 160) String name,
        @Size(max = 2000) String description,
        @NotBlank @Size(max = 64) String timeZone,
        @NotBlank @Pattern(regexp = "[A-Z]{3}") String defaultCurrency
    ) {}

    public record CompanyResponse(UUID id, String name, String description, String timeZone,
                                  String defaultCurrency, boolean active, CompanyMembership.Role role) {}
}
