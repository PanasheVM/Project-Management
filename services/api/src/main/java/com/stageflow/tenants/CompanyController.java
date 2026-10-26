package com.stageflow.tenants;

import com.stageflow.tenants.CompanyDtos.CompanyResponse;
import com.stageflow.tenants.CompanyDtos.CreateCompanyRequest;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/companies")
public class CompanyController {
    private final CompanyService service;
    public CompanyController(CompanyService service) { this.service = service; }

    @PostMapping
    ResponseEntity<CompanyResponse> create(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody CreateCompanyRequest request) {
        CompanyResponse company = service.create(jwt, request);
        return ResponseEntity.created(URI.create("/api/v1/companies/" + company.id())).body(company);
    }

    @GetMapping
    List<CompanyResponse> list(@AuthenticationPrincipal Jwt jwt) { return service.list(jwt); }
}
