import Foundation

@MainActor
final class AutomaticReportEmail {
    enum Outcome: Equatable {
        case sent, failed, alreadyAttempted
    }

    private var attemptedMeasurementIDs: Set<String> = []
    private let maximumAttempts = 3
    private let waitBeforeRetry: (Int) async throws -> Void
    private let logFailure: (String) -> Void

    init(
        waitBeforeRetry: @escaping (Int) async throws -> Void = { attempt in
            try await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
        },
        logFailure: @escaping (String) -> Void = { NSLog("%@", $0) }
    ) {
        self.waitBeforeRetry = waitBeforeRetry
        self.logFailure = logFailure
    }

    func sendOnce(
        measurementID: String,
        email: String,
        pin: String,
        send: (String, String, String) async throws -> Void
    ) async -> Outcome {
        guard !measurementID.isEmpty,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              pin.count == 4,
              pin.allSatisfy({ $0 >= "0" && $0 <= "9" }) else {
            return .failed
        }
        // Reserve the entire retry sequence so repeated appearances cannot start another one.
        guard attemptedMeasurementIDs.insert(measurementID).inserted else {
            return .alreadyAttempted
        }

        for attempt in 1...maximumAttempts {
            guard !Task.isCancelled else { return .failed }
            do {
                try await send(email, pin, measurementID)
                return .sent
            } catch {
                let failure = error as NSError
                let willRetry = attempt < maximumAttempts && !Task.isCancelled && !(error is CancellationError)
                // Keep email addresses, PINs, and server response bodies out of this log.
                logFailure("Report email API attempt \(attempt)/\(maximumAttempts) failed (\(failure.domain), code \(failure.code)). \(willRetry ? "Retrying in \(attempt) second(s)." : "No further attempts.")")
                guard willRetry else { return .failed }

                do {
                    try await waitBeforeRetry(attempt)
                } catch {
                    return .failed
                }
            }
        }
        return .failed
    }
}
