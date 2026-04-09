import Foundation

struct ClientCodeValidationResponse: Decodable {
    let valid: Bool
    let message: String?
    let companyName: String?
    let code: String?

    private enum CodingKeys: String, CodingKey {
        case valid
        case message
        case companyName = "company_name"
        case code
    }
}
