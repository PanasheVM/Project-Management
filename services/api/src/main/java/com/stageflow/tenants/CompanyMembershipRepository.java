package com.stageflow.tenants;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CompanyMembershipRepository extends JpaRepository<CompanyMembership, UUID> {
    List<CompanyMembership> findAllByUserOidcSubjectAndStatus(String subject, CompanyMembership.Status status);
    Optional<CompanyMembership> findByCompanyIdAndUserOidcSubjectAndStatus(UUID companyId, String subject, CompanyMembership.Status status);
}
