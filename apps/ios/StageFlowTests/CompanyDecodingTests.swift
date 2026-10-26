import XCTest
@testable import StageFlow

final class CompanyDecodingTests: XCTestCase {
    func testDecodesTenantMembershipRole() throws {
        let data = Data(#"{"id":"550e8400-e29b-41d4-a716-446655440000","name":"Lumina","description":null,"timeZone":"Africa/Harare","defaultCurrency":"USD","active":true,"role":"COMPANY_OWNER"}"#.utf8)
        let company = try JSONDecoder().decode(Company.self, from: data)
        XCTAssertEqual(company.name, "Lumina")
        XCTAssertEqual(company.role, .companyOwner)
    }
}
