import Foundation

// Compile alongside HH_Kiosk_B2B/Utils/AutomaticReportEmail.swift and run on macOS.
@main
struct AutomaticReportEmailTests {
    private enum TestError: Error { case unavailable }

    @MainActor static func main() async {
        var retryDelays: [Int] = []
        var failureLogs: [String] = []
        let sender = AutomaticReportEmail(
            waitBeforeRetry: { retryDelays.append($0) },
            logFailure: { failureLogs.append($0) }
        )
        var requests: [(String, String, String)] = []
        let send: (String, String, String) async throws -> Void = { email, pin, id in
            requests.append((email, pin, id))
        }

        let first = await sender.sendOnce(measurementID: "scan-1", email: "test@example.com", pin: "0012", send: send)
        precondition(first == .sent)
        precondition(requests.count == 1)
        precondition(requests[0].0 == "test@example.com" && requests[0].1 == "0012" && requests[0].2 == "scan-1")

        let repeated = await sender.sendOnce(measurementID: "scan-1", email: "test@example.com", pin: "0012", send: send)
        precondition(repeated == .alreadyAttempted && requests.count == 1)

        let nextScan = await sender.sendOnce(measurementID: "scan-2", email: "test@example.com", pin: "1234", send: send)
        precondition(nextScan == .sent && requests.count == 2)

        for (id, email, pin) in [
            ("", "test@example.com", "1234"),
            ("invalid", " ", "1234"),
            ("invalid", "test@example.com", ""),
            ("invalid", "test@example.com", "123"),
            ("invalid", "test@example.com", "12345"),
            ("invalid", "test@example.com", "12ab")
        ] {
            let outcome = await sender.sendOnce(measurementID: id, email: email, pin: pin, send: send)
            precondition(outcome == .failed && requests.count == 2)
        }

        var failedAttempts = 0
        let failure = await sender.sendOnce(measurementID: "failed-scan", email: "test@example.com", pin: "1234") { _, _, _ in
            failedAttempts += 1
            throw TestError.unavailable
        }
        precondition(failure == .failed && failedAttempts == 3)
        precondition(retryDelays == [1, 2])
        precondition(failureLogs.count == 3)
        precondition(failureLogs[0].contains("attempt 1/3 failed"))
        precondition(failureLogs[1].contains("attempt 2/3 failed"))
        precondition(failureLogs[2].contains("attempt 3/3 failed"))
        precondition(failureLogs[2].contains("No further attempts"))
        let afterFailure = await sender.sendOnce(measurementID: "failed-scan", email: "test@example.com", pin: "1234", send: send)
        precondition(afterFailure == .alreadyAttempted && requests.count == 2)

        // Recover on either retry, stopping immediately after a successful response.
        for successAttempt in [2, 3] {
            retryDelays.removeAll()
            failureLogs.removeAll()
            var attempts = 0
            let recovered = await sender.sendOnce(measurementID: "recover-\(successAttempt)", email: "test@example.com", pin: "0012") { email, pin, id in
                precondition(email == "test@example.com" && pin == "0012" && id == "recover-\(successAttempt)")
                attempts += 1
                if attempts < successAttempt { throw TestError.unavailable }
            }
            precondition(recovered == .sent && attempts == successAttempt)
            precondition(retryDelays == Array(1..<successAttempt))
            precondition(failureLogs.count == successAttempt - 1)
        }

        // A second appearance while the first request is suspended must not resend.
        var completion: CheckedContinuation<Void, Never>?
        let inFlight = Task { @MainActor in
            await sender.sendOnce(measurementID: "in-flight", email: "test@example.com", pin: "1234") { _, _, _ in
                await withCheckedContinuation { completion = $0 }
            }
        }
        while completion == nil { await Task.yield() }
        let duplicate = await sender.sendOnce(measurementID: "in-flight", email: "test@example.com", pin: "1234", send: send)
        precondition(duplicate == .alreadyAttempted && requests.count == 2)
        completion?.resume()
        let completed = await inFlight.value
        precondition(completed == .sent)

        // Duplicate appearances during a retry delay must share the original sequence.
        var retryContinuation: CheckedContinuation<Void, Never>?
        var retryAttempts = 0
        let retrySender = AutomaticReportEmail(
            waitBeforeRetry: { _ in await withCheckedContinuation { retryContinuation = $0 } },
            logFailure: { _ in }
        )
        let retrying = Task { @MainActor in
            await retrySender.sendOnce(measurementID: "retrying", email: "test@example.com", pin: "1234") { _, _, _ in
                retryAttempts += 1
                if retryAttempts == 1 { throw TestError.unavailable }
            }
        }
        while retryContinuation == nil { await Task.yield() }
        let duplicateRetry = await retrySender.sendOnce(measurementID: "retrying", email: "test@example.com", pin: "1234", send: send)
        precondition(duplicateRetry == .alreadyAttempted && retryAttempts == 1)
        retryContinuation?.resume()
        let retryCompleted = await retrying.value
        precondition(retryCompleted == .sent && retryAttempts == 2)

        print("Passed: credentials, leading zeros, duplicates, retry deduplication, three-attempt limit, recovery, retry delays, failure logs, and invalid input")
    }
}
