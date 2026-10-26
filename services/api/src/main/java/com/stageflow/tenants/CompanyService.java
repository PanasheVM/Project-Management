package com.stageflow.tenants;

import com.stageflow.identity.UserAccount;
import com.stageflow.identity.UserAccountRepository;
import com.stageflow.tenants.CompanyDtos.CompanyResponse;
import com.stageflow.tenants.CompanyDtos.CreateCompanyRequest;
import java.util.List;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CompanyService {
    private final CompanyRepository companies;
    private final CompanyMembershipRepository memberships;
    private final UserAccountRepository users;

    public CompanyService(CompanyRepository companies, CompanyMembershipRepository memberships, UserAccountRepository users) {
        this.companies = companies;
        this.memberships = memberships;
        this.users = users;
    }

    @Transactional
    public CompanyResponse create(Jwt jwt, CreateCompanyRequest request) {
        UserAccount user = users.findByOidcSubject(jwt.getSubject()).orElseGet(() -> users.save(new UserAccount(
            jwt.getSubject(), requiredClaim(jwt, "email"), jwt.getClaimAsString("name") == null ? requiredClaim(jwt, "email") : jwt.getClaimAsString("name"))));
        Company company = companies.save(new Company(request.name().trim(), request.description(), request.timeZone(), request.defaultCurrency()));
        CompanyMembership membership = memberships.save(new CompanyMembership(company, user, CompanyMembership.Role.COMPANY_OWNER));
        return response(company, membership.getRole());
    }

    @Transactional(readOnly = true)
    public List<CompanyResponse> list(Jwt jwt) {
        return memberships.findAllByUserOidcSubjectAndStatus(jwt.getSubject(), CompanyMembership.Status.ACTIVE).stream()
            .map(membership -> response(membership.getCompany(), membership.getRole())).toList();
    }

    private static String requiredClaim(Jwt jwt, String name) {
        String value = jwt.getClaimAsString(name);
        if (value == null || value.isBlank()) throw new IllegalArgumentException("Identity token is missing required claim: " + name);
        return value;
    }

    private static CompanyResponse response(Company company, CompanyMembership.Role role) {
        return new CompanyResponse(company.getId(), company.getName(), company.getDescription(), company.getTimeZone(), company.getDefaultCurrency(), company.isActive(), role);
    }
}
