import Foundation

struct Company: Codable, Identifiable, Sendable, Equatable {
    let id: UUID
    let name: String
    let description: String?
    let timeZone: String
    let defaultCurrency: String
    let active: Bool
    let role: CompanyRole
}

enum CompanyRole: String, Codable, Sendable {
    case companyOwner = "COMPANY_OWNER"
    case companyAdmin = "COMPANY_ADMIN"
    case projectManager = "PROJECT_MANAGER"
    case departmentHead = "DEPARTMENT_HEAD"
    case crewMember = "CREW_MEMBER"
    case freelancer = "FREELANCER"
}
