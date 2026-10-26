CREATE TABLE user_accounts (
    id UUID PRIMARY KEY,
    oidc_subject VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(320) NOT NULL,
    display_name VARCHAR(160) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE companies (
    id UUID PRIMARY KEY,
    name VARCHAR(160) NOT NULL,
    description VARCHAR(2000),
    time_zone VARCHAR(64) NOT NULL,
    default_currency VARCHAR(3) NOT NULL CHECK (default_currency ~ '^[A-Z]{3}$'),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    version BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE company_memberships (
    id UUID PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES companies(id),
    user_id UUID NOT NULL REFERENCES user_accounts(id),
    role VARCHAR(32) NOT NULL CHECK (role IN ('COMPANY_OWNER','COMPANY_ADMIN','PROJECT_MANAGER','DEPARTMENT_HEAD','CREW_MEMBER','FREELANCER')),
    status VARCHAR(16) NOT NULL CHECK (status IN ('INVITED','ACTIVE','SUSPENDED','REMOVED')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    version BIGINT NOT NULL DEFAULT 0,
    UNIQUE (company_id, user_id)
);

CREATE INDEX idx_membership_user_status ON company_memberships(user_id, status);
CREATE INDEX idx_membership_company_status ON company_memberships(company_id, status);
