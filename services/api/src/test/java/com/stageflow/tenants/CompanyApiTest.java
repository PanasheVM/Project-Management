package com.stageflow.tenants;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.stageflow.identity.UserAccountRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class CompanyApiTest {
    @Autowired MockMvc mvc;
    @Autowired CompanyMembershipRepository memberships;
    @Autowired CompanyRepository companies;
    @Autowired UserAccountRepository users;

    @BeforeEach void clean() { memberships.deleteAll(); companies.deleteAll(); users.deleteAll(); }

    @Test void rejectsUnauthenticatedCompanyListing() throws Exception {
        mvc.perform(get("/api/v1/companies")).andExpect(status().isUnauthorized());
    }

    @Test void ownerCreatesAndListsOnlyTheirCompany() throws Exception {
        mvc.perform(post("/api/v1/companies")
                .with(jwt().jwt(token -> token.subject("owner-1").claim("email", "owner@example.com").claim("name", "Owner")))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"name":"Lumina Events","description":"Live production","timeZone":"Africa/Harare","defaultCurrency":"USD"}
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.role").value("COMPANY_OWNER"));

        mvc.perform(get("/api/v1/companies").with(jwt().jwt(token -> token.subject("owner-1"))))
            .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(1));

        mvc.perform(get("/api/v1/companies").with(jwt().jwt(token -> token.subject("outsider"))))
            .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(0));
    }
}
