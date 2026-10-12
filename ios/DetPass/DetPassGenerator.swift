import CommonCrypto
import Foundation

enum DetPassError: LocalizedError, Equatable {
    case missingDetails
    case derivationFailed(Int32)

    var errorDescription: String? {
        switch self {
        case .missingDetails:
            return "Enter Details"
        case .derivationFailed:
            return "Could not generate password"
        }
    }
}

enum DetPassGenerator {
    static let defaultLength = 12
    static let defaultIterations = 100_000

    private static let lower = Array("abcdefghijklmnopqrstuvwxyz")
    private static let upper = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    private static let digits = Array("0123456789")
    private static let specials = Array("@$-_")
    private static let all = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@$-_")

    static func derivePassword(
        secret: String,
        site: String,
        length: Int = defaultLength,
        iterations: Int = defaultIterations
    ) throws -> String {
        guard !secret.isEmpty, !site.isEmpty else {
            throw DetPassError.missingDetails
        }

        let passwordData = Data(secret.utf8)
        let saltData = Data("detpass-v1|\(site)".utf8)
        var bytes = [UInt8](repeating: 0, count: 32)

        let status = passwordData.withUnsafeBytes { passwordRawBuffer in
            saltData.withUnsafeBytes { saltRawBuffer in
                let passwordPointer = passwordRawBuffer.bindMemory(to: Int8.self).baseAddress
                let saltPointer = saltRawBuffer.bindMemory(to: UInt8.self).baseAddress

                return CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    passwordPointer,
                    passwordData.count,
                    saltPointer,
                    saltData.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    UInt32(iterations),
                    &bytes,
                    bytes.count
                )
            }
        }

        guard status == kCCSuccess else {
            throw DetPassError.derivationFailed(status)
        }

        let outputLength = max(8, length)
        var output = (0..<outputLength).map { index in
            all[Int(bytes[index % bytes.count]) % all.count]
        }

        func ensureClass(_ set: [Character], posIndex: Int) {
            let position = Int(bytes[(outputLength + posIndex) % bytes.count]) % outputLength
            output[position] = set[Int(bytes[(posIndex + 10) % bytes.count]) % set.count]
        }

        ensureClass(upper, posIndex: 0)
        ensureClass(lower, posIndex: 1)
        ensureClass(digits, posIndex: 2)
        ensureClass(specials, posIndex: 3)

        return String(output)
    }
}
