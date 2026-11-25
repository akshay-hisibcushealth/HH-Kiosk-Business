import Foundation

/// Decode directly from the save response, never from its nested final_results.
struct ReportEmailDelivery: Decodable {
    let sent: Bool
    let message: String

    enum CodingKeys: String, CodingKey {
        case sent = "report_email_sent"
        case message
    }
}
