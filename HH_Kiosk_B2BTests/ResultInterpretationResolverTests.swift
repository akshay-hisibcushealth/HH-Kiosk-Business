import XCTest
@testable import HH_Kiosk_B2B

final class ResultInterpretationResolverTests: XCTestCase {
    private struct MessageCase {
        let metric: String
        let sampleValue: Double
        let expectedBucket: String
        let expectedMessage: String
    }

    private let cases: [MessageCase] = [
        .init(metric: "BP_SYSTOLIC", sampleValue: 89, expectedBucket: "low", expectedMessage: "Your screening suggests your systolic blood pressure may be lower than the healthy range."),
        .init(metric: "BP_SYSTOLIC", sampleValue: 90, expectedBucket: "healthy", expectedMessage: "Your screening suggests your systolic blood pressure is within a healthy range."),
        .init(metric: "BP_SYSTOLIC", sampleValue: 130, expectedBucket: "slightly_high", expectedMessage: "Your screening suggests your systolic blood pressure may be slightly above the healthy range."),
        .init(metric: "BP_SYSTOLIC", sampleValue: 140, expectedBucket: "high", expectedMessage: "Your screening suggests your systolic blood pressure may be significantly elevated."),

        .init(metric: "BP_DIASTOLIC", sampleValue: 59, expectedBucket: "low", expectedMessage: "Your screening suggests your diastolic blood pressure may be lower than the healthy range."),
        .init(metric: "BP_DIASTOLIC", sampleValue: 60, expectedBucket: "slightly_low", expectedMessage: "Your screening suggests your diastolic blood pressure may be slightly lower the healthy range."),
        .init(metric: "BP_DIASTOLIC", sampleValue: 70, expectedBucket: "healthy", expectedMessage: "Your screening suggests your diastolic blood pressure is within a healthy range."),
        .init(metric: "BP_DIASTOLIC", sampleValue: 80, expectedBucket: "slightly_high", expectedMessage: "Your screening suggests your diastolic blood pressure may be slightly above the healthy range."),
        .init(metric: "BP_DIASTOLIC", sampleValue: 90, expectedBucket: "high", expectedMessage: "Your screening suggests your diastolic blood pressure may be significantly elevated."),

        .init(metric: "HR_BPM", sampleValue: 59, expectedBucket: "low", expectedMessage: "Your screening suggests your heart rate is below a normal resting range."),
        .init(metric: "HR_BPM", sampleValue: 60, expectedBucket: "normal", expectedMessage: "Your screening suggests your heart rate is within a normal resting range."),
        .init(metric: "HR_BPM", sampleValue: 100, expectedBucket: "high", expectedMessage: "Your screening suggests your heart rate is higher than the typical resting range."),

        .init(metric: "HBA1C_RISK_PROB", sampleValue: 24, expectedBucket: "very_low", expectedMessage: "Your screening suggests your HbA1c markers are within a healthy, stable range."),
        .init(metric: "HBA1C_RISK_PROB", sampleValue: 25, expectedBucket: "low", expectedMessage: "Your screening suggests your HbA1c is likely below the threshold for concern."),
        .init(metric: "HBA1C_RISK_PROB", sampleValue: 45, expectedBucket: "moderate", expectedMessage: "Your screening suggests your HbA1c (blood sugar level) markers are slightly elevated compared to the ideal range."),
        .init(metric: "HBA1C_RISK_PROB", sampleValue: 55, expectedBucket: "high", expectedMessage: "Your screening suggests that your blood sugar levels are currently above the standard healthy range."),
        .init(metric: "HBA1C_RISK_PROB", sampleValue: 77.5, expectedBucket: "very_high", expectedMessage: "Your screening suggests blood sugar markers that are notably above the standard healthy range."),

        .init(metric: "HDLTC_RISK_PROB", sampleValue: 24, expectedBucket: "very_low", expectedMessage: "Your screening suggests a very low probability of elevated cholesterol levels."),
        .init(metric: "HDLTC_RISK_PROB", sampleValue: 25, expectedBucket: "low", expectedMessage: "Your screening suggests your cholesterol markers are within a standard, low-risk profile."),
        .init(metric: "HDLTC_RISK_PROB", sampleValue: 45, expectedBucket: "moderate", expectedMessage: "Your screening suggests your cholesterol levels are within a moderate risk range."),
        .init(metric: "HDLTC_RISK_PROB", sampleValue: 55, expectedBucket: "high", expectedMessage: "Your screening suggests cholesterol levels are currently above the recommended healthy threshold."),
        .init(metric: "HDLTC_RISK_PROB", sampleValue: 77.5, expectedBucket: "very_high", expectedMessage: "Your screening suggests indicators consistent with a high concentration of cholesterol in the blood."),

        .init(metric: "TG_RISK_PROB", sampleValue: 24, expectedBucket: "very_low", expectedMessage: "Your screening suggests a very low probability of elevated triglyceride levels."),
        .init(metric: "TG_RISK_PROB", sampleValue: 25, expectedBucket: "low", expectedMessage: "Your screening suggests your triglyceride markers are within a standard, low-risk profile."),
        .init(metric: "TG_RISK_PROB", sampleValue: 45, expectedBucket: "moderate", expectedMessage: "Your screening suggests your triglyceride levels are within a moderate risk range."),
        .init(metric: "TG_RISK_PROB", sampleValue: 55, expectedBucket: "high", expectedMessage: "Your screening suggests triglyceride levels are currently above the recommended healthy threshold."),
        .init(metric: "TG_RISK_PROB", sampleValue: 77.5, expectedBucket: "very_high", expectedMessage: "Your screening suggests indicators consistent with a high concentration of triglyceride in the blood."),

        .init(metric: "BP_CVD", sampleValue: 4, expectedBucket: "very_low", expectedMessage: "Your screening suggests a very low likelihood of a heart attack or stroke in the next 10 years."),
        .init(metric: "BP_CVD", sampleValue: 5, expectedBucket: "low", expectedMessage: "Your screening suggests a low likelihood of a heart attack or stroke in the next 10 years."),
        .init(metric: "BP_CVD", sampleValue: 7.25, expectedBucket: "moderate_low", expectedMessage: "Your screening suggests a moderate-low likelihood of a heart attack or stroke in the next 10 years."),
        .init(metric: "BP_CVD", sampleValue: 10, expectedBucket: "moderate", expectedMessage: "Your screening suggests a moderate likelihood of a heart attack or stroke in the next 10 years."),
        .init(metric: "BP_CVD", sampleValue: 20, expectedBucket: "high", expectedMessage: "Your screening suggests a higher likelihood of a heart attack or stroke in the next 10 years.")
    ]

    func testEveryRangeReturnsExpectedBucketAndExactScreenMessage() {
        for testCase in cases {
            XCTAssertEqual(
                ResultInterpretationResolver.riskBucket(for: testCase.metric, value: testCase.sampleValue),
                testCase.expectedBucket,
                "\(testCase.metric) at \(testCase.sampleValue)"
            )
            XCTAssertEqual(
                ResultInterpretationResolver.message(for: testCase.metric, value: testCase.sampleValue),
                testCase.expectedMessage,
                "\(testCase.metric) at \(testCase.sampleValue)"
            )
        }
    }

    func testValuesImmediatelyBelowEveryBoundaryRemainInPreviousRange() {
        let boundaries: [(metric: String, value: Double, previousBucket: String)] = [
            ("BP_SYSTOLIC", 90, "low"),
            ("BP_SYSTOLIC", 130, "healthy"),
            ("BP_SYSTOLIC", 140, "slightly_high"),
            ("BP_DIASTOLIC", 60, "low"),
            ("BP_DIASTOLIC", 70, "slightly_low"),
            ("BP_DIASTOLIC", 80, "healthy"),
            ("BP_DIASTOLIC", 90, "slightly_high"),
            ("HR_BPM", 60, "low"),
            ("HR_BPM", 100, "normal"),
            ("HBA1C_RISK_PROB", 25, "very_low"),
            ("HBA1C_RISK_PROB", 45, "low"),
            ("HBA1C_RISK_PROB", 55, "moderate"),
            ("HBA1C_RISK_PROB", 77.5, "high"),
            ("HDLTC_RISK_PROB", 25, "very_low"),
            ("HDLTC_RISK_PROB", 45, "low"),
            ("HDLTC_RISK_PROB", 55, "moderate"),
            ("HDLTC_RISK_PROB", 77.5, "high"),
            ("TG_RISK_PROB", 25, "very_low"),
            ("TG_RISK_PROB", 45, "low"),
            ("TG_RISK_PROB", 55, "moderate"),
            ("TG_RISK_PROB", 77.5, "high"),
            ("BP_CVD", 5, "very_low"),
            ("BP_CVD", 7.25, "low"),
            ("BP_CVD", 10, "moderate_low"),
            ("BP_CVD", 20, "moderate")
        ]

        for boundary in boundaries {
            XCTAssertEqual(
                ResultInterpretationResolver.riskBucket(for: boundary.metric, value: boundary.value.nextDown),
                boundary.previousBucket,
                "\(boundary.metric) immediately below \(boundary.value)"
            )
        }
    }
}
