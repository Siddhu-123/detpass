import XCTest
@testable import DetPass

final class DetPassGeneratorTests: XCTestCase {
    func testMatchesCurrentExtensionVectors() throws {
        let vectors = [
            ("my little secret", "example.com", "Cfgd_lAexV9@"),
            ("correct horse battery staple", "github.com", "EwVWGRd$xTpP"),
            ("päss🔐", "sub.example.co.uk", "8l4bvBZ6aVR@"),
            ("secret", "Example.COM", "1KjF0QBrM-TV"),
            ("secret ", "example.com", "mQpgs_$19tPD"),
            ("secret", "example.com", "f34Gy@$ak6Qk")
        ]

        for (secret, site, expectedPassword) in vectors {
            let actualPassword = try DetPassGenerator.derivePassword(secret: secret, site: site)
            XCTAssertEqual(actualPassword, expectedPassword, "Mismatch for \(site)")
        }
    }

    func testMissingDetailsMatchesExtensionError() {
        XCTAssertThrowsError(try DetPassGenerator.derivePassword(secret: "", site: "example.com")) { error in
            XCTAssertEqual(error.localizedDescription, "Enter Details")
        }
        XCTAssertThrowsError(try DetPassGenerator.derivePassword(secret: "secret", site: "")) { error in
            XCTAssertEqual(error.localizedDescription, "Enter Details")
        }
    }
}
