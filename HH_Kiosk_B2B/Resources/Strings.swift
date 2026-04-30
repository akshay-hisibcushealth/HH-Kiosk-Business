import Foundation
import SwiftUI

enum ArticleScreenStrings {
    static let imageLoading = "Loading Image..."
}


enum HomeScreenStrings {
    enum Weather {
        static let loading = "Loading Weather..."
        static let errorTitle = "Error:"
        static let fetchingLocation = "Fetching location..."
        static let welcomePrefix = "Welcome to the"
        static let companyName = "[Clinic Name]"
        static let kioskSuffix = "Kiosk!"
    }

    enum Promo {
        static let title = "Curious About Your Health?"
        static let subtitle = "Start with a 30 seconds Face Scan"
        static let demoButtonTitle = "Watch Quick Demo"
        static let tryFaceScan = "Try Face Scan"
        static let demoURL = "https://drive.google.com/file/d/1dPJs1A6aptEh3yTCVxR5BUlRfyLWa3rL/view?usp=sharing"
    }

    enum ReadSection {
        static let loading = "Loading..."
        static let failedToLoadPrefix = "Failed to load:"
        static let todaysReadTitle = "Today's Read"
        static let articleBadge = "Article"
        static let fromYourProvider = "From your Provider"
    }

    enum Schedule {
        static let sectionTitle = "Announcements"
        static let announcements = [
            "Smoking Cessation Class on Wednesdays",
            "Reminder to Wear your Seatbelt",
            "Get your Annual Flu Shot!"
        ]
    }
}


enum PhysicalAttributesScreenStrings {
    static let title = "Tell us about yourself"
    static let subtitle = "We use these details to ensure your scan results are as accurate as possible."
    static let privacyMessage = "We prioritize your privacy. Your information will NOT be stored during this process and will only be used for calculations."
    static let watchQuickDemo = "Watch Demo"
    static let proceedToScan = "Proceed to Scan"
    static let alertDismiss = "OK"
    static let demoURL = "https://drive.google.com/file/d/1dPJs1A6aptEh3yTCVxR5BUlRfyLWa3rL/view?usp=sharing"

    enum Validation {
        static let missingEmail = "Please enter your email."
        static let invalidEmail = "Please enter a valid email."
        static let missingHeight = "Please select your height."
        static let missingWeight = "Weight cannot be empty."
        static let invalidWeight = "Weight cannot be less than 75 lbs."
        static let missingAge = "Please enter your age."
        static let invalidAge = "Age must be between 13 and 120 years."
        static let missingGender = "Please select your gender."
    }

    enum Form {
        static let emailLabel = "Email"
        static let emailPlaceholder = "Enter email"
        static let emailInlineError = "Enter a valid email address"
        static let ageLabel = "Age"
        static let agePlaceholder = "Year"
        static let heightLabel = "Height"
        static let heightPlaceholder = "Feet / Inches"
        static let heightSheetTitle = "Select Height"
        static let feetUnit = "ft"
        static let inchesUnit = "in"
        static let doneButton = "Done"
        static let weightLabel = "Weight"
        static let weightPlaceholder = "Lbs"
        static let genderLabel = "Sex (at birth)"
        static let genderPlaceholder = "Male / Female"
        static let genderOptions = ["Male", "Female"]
    }

    enum Settings {
        static let cameraPreset = "External camera preset"
        static let previewOrientation = "Preview orientation"
        static let mirrorExternalVideo = "Mirror external camera video"
        static let useExternalCameraOnly = "Use external camera only"
        static let externalCameraDescription = "If enabled, only the external camera will be used. If disabled, the app will automatically switch between the built-in camera and an external camera (external camera is prioritized)."
        static let title = "Camera Settings"
        static let closeButton = "Close"
        static let unknownOption = "Unknown"
        static let portrait = "Portrait"
        static let landscapeLeft = "LandscapeLeft"
        static let landscapeRight = "LandscapeRight"
        static let portraitUpsideDown = "PortraitUpsideDown"
    }
}


enum ReadPdfScreenStrings {
    static let loading = "Loading PDF..."
    static let failedToLoad = "Failed to load PDF"
}


enum ResultScreenStrings {
    static let pdfFileName = "Hibiscus_Health_Report"
    static let title = "Great job taking a proactive step for your health!"
    static let heroDescription = "Below is a summary of your key biomarkers based on your 30-second scan."
    static let titleBlockDescription = "This report is intended to improve your awareness of general wellness. It is not a substitute for the clinical judgment of a health care professional.  These results provide a non-diagnostic screening to help you understand your current wellness trends."
    static let infoFooter = "Hibiscus Health is intended to improve your awareness of general wellness. Hibiscus Health does not diagnose, treat, mitigate or prevent any disease, symptom, disorder or abnormal physical state. Consult with a healthcare professional or emergency services if you believe you may have a medical issue."
    static let privacyMessage = "The results from this face scan are not intended to diagnose, treat, or replace professional medical advice. For any health concerns, please consult a healthcare provider."
    static let nextStepsTitle = "Next Steps"
    static let nextStepsPrefix = "We know every organization is unique. Whether you’re an employer, health plan, or solution partner, Hibiscus can integrate seamlessly into your existing ecosystem, or provide full end-to-end support from "
    static let nextStepsEmphasis = "Face Scan -> Care Guide -> Clinician"
    static let nextStepsSuffix = " for maximum impact. Choose the components that best complement your current resources."
    static let footerResources = "Find even more resources\ntips & insights on the app,"
    static let footerAddress = "575 LEXINGTON AVE, FL 14TH NEW YORK, NY 10022-6102 United States"
    static let appStoreURL = "https://apps.apple.com/tn/app/hibiscus-health/id6478411080"
    static let playStoreURL = "https://play.google.com/store/apps/details?id=com.nutritionApp.hibiscus_health&hl"

    enum Actions {
        static let closeResult = "Close result"
        static let emailMyResults = "Mail Results"
        static let secureAndPrivate = "Secure and Private"
        static let print = "Print"
        static let endSession = "End Session"
    }

    enum EmailPopup {
        static let inboxTitle = "Check your inbox!"
        static let inboxMessage = "Your result has been sent to your email!\nTell a colleague about our Kiosk!"
        static let returnHome = "Return to Home Screen"
        static let title = "Send your result to your email"
        static let emailAddress = "Email address"
        static let emailPlaceholder = "Email"
        static let pinTitle = "Create a 4-digit secret key"
        static let pinPlaceholder = "* * * *"
        static let pinHelp = "This will be used to view your result"
        static let sendMail = "Send mail"
        static let emailFailure = "Failed to send email. Please try again."
        static let secureAndPrivate = "Secure and Private"
    }

    enum Guide {
        static let next = "NEXT"
        static let back = "BACK"
        static let close = "CLOSE"
        static let firstTitle = "User-friendly Face Scan Results"
        static let secondTitle = "Easy Integration to Workflow"

        static var firstBody: AttributedString {
            var text = AttributedString("""
            This is a sample member-facing report that highlights key areas where small changes can drive meaningful health improvements and financial outcomes.

            Earlier risk identification can support shared savings, quality performance, CCM-related economics, preventive care revenue, and better performance under value-based contracts.
            """)
            emphasize("sample member-facing report", in: &text)
            return text
        }

        static var secondBody: AttributedString {
            var text = AttributedString("""
            We can also send the backend data file of the scan's outputs on a regular cadence directly into your EMR system, complementing your existing workflows and reducing clinical burden.

            As an ACO, you can choose whether the report is sent directly to the patient, shared only with your care team, or delivered as a backend data file to your EMR.
            """)
            return text
        }

        private static func emphasize(_ phrase: String, in text: inout AttributedString) {
            guard let range = text.range(of: phrase) else { return }
            text[range].font = .system(size: 24.sp, weight: .bold)
        }
    }

    enum Metrics {
        static let interpretations: [String: [String: String]] = [
            "Cardiovascular Disease Risk": [
                "very_low": "Your screening suggests a <tag color=\"\(AppColors.tagRiskLow)\">very low likelihood</tag> of a heart attack or stroke in the next 10 years.",
                "low": "Your screening suggests a <tag color=\"\(AppColors.tagRiskLow)\">low likelihood</tag> of a heart attack or stroke in the next 10 years.",
                "moderate_low": "Your screening suggests a <tag color=\"\(AppColors.tagRiskWarning)\">moderate-low likelihood</tag> of a heart attack or stroke in the next 10 years.",
                "moderate": "Your screening suggests a <tag color=\"\(AppColors.tagRiskMedium)\">moderate likelihood</tag> of a heart attack or stroke in the next 10 years.",
                "high": "Your screening suggests a <tag color=\"\(AppColors.tagRiskHigh)\">higher likelihood</tag> of a heart attack or stroke in the next 10 years."
            ],
            "Systolic Blood Pressure": [
                "healthy": "Your screening suggests your systolic blood pressure is <tag color=\"\(AppColors.tagRiskLow)\">within a healthy range</tag>.",
                "low": "Your screening suggests your systolic blood pressure may be <tag color=\"\(AppColors.tagRiskWarning)\">lower than the healthy range</tag>.",
                "slightly_high": "Your screening suggests your systolic blood pressure may be <tag color=\"\(AppColors.tagRiskWarning)\">slightly above the healthy range</tag>.",
                "high": "Your screening suggests your systolic blood pressure may be <tag color=\"\(AppColors.tagRiskHigh)\">significantly elevated</tag>."
            ],
            "Diastolic Blood Pressure": [
                "healthy": "Your screening suggests your diastolic blood pressure is <tag color=\"\(AppColors.tagRiskLow)\">within a healthy range</tag>.",
                "low": "Your screening suggests your diastolic blood pressure may be <tag color=\"\(AppColors.tagRiskWarning)\">lower than the healthy range</tag>.",
                "slightly_high": "Your screening suggests your diastolic blood pressure may be <tag color=\"\(AppColors.tagRiskWarning)\">slightly above the healthy range</tag>.",
                "high": "Your screening suggests your diastolic blood pressure may be <tag color=\"\(AppColors.tagRiskHigh)\">significantly elevated</tag>."
            ],
            "Heart Rate": [
                "normal": "Your screening suggests your heart rate is <tag color=\"\(AppColors.tagRiskLow)\">within a normal resting range</tag>.",
                "moderate": "Your screening suggests your heart rate is <tag color=\"\(AppColors.tagRiskLow)\">within a moderate resting range</tag>.",
                "slightly_high": "Your screening suggests your heart rate is <tag color=\"\(AppColors.tagRiskWarning)\">slightly above the typical resting range</tag>.",
                "high": "Your screening suggests your heart rate may be <tag color=\"\(AppColors.tagRiskMedium)\">higher than the typical resting range</tag>.",
                "very_high": "Your screening suggests your heart rate may be <tag color=\"\(AppColors.tagRiskHigh)\">significantly higher than the typical resting range</tag>."
            ],
            "HbA1c Risk": [
                "very_low": "Your screening suggests your HbA1c markers are <tag color=\"\(AppColors.tagRiskLow)\">within a healthy, stable range</tag>.",
                "low": "Your screening suggests your HbA1c is <tag color=\"\(AppColors.tagRiskLow)\">likely below the threshold for concern</tag>.",
                "moderate": "Your screening suggests <tag color=\"\(AppColors.tagRiskWarning)\">slightly elevated glycemic markers</tag> compared to the ideal range.",
                "high": "Your screening suggests that your blood sugar levels are <tag color=\"\(AppColors.tagRiskMedium)\">currently above the standard healthy range</tag>.",
                "very_high": "Your screening suggests blood sugar markers that are <tag color=\"\(AppColors.tagRiskHigh)\">notably above the standard healthy range</tag>."
            ],
            "High Cholesterol Risk": [
                "very_low": "Your screening suggests a <tag color=\"\(AppColors.tagRiskLow)\">very low probability</tag> of elevated cholesterol levels.",
                "low": "Your screening suggests your cholesterol markers are <tag color=\"\(AppColors.tagRiskLow)\">within a standard, low-risk profile</tag>.",
                "moderate": "Your screening suggests your cholesterol markers are <tag color=\"\(AppColors.tagRiskWarning)\">currently sitting in a moderate range</tag>.",
                "high": "Your screening suggests cholesterol levels are <tag color=\"\(AppColors.tagRiskMedium)\">currently above the recommended healthy threshold</tag>.",
                "very_high": "Your screening suggests indicators consistent with a <tag color=\"\(AppColors.tagRiskHigh)\">high concentration of cholesterol in the blood</tag>."
            ],
            "High Triglycerides Risk": [
                "very_low": "Your screening suggests a <tag color=\"\(AppColors.tagRiskLow)\">very low probability</tag> of elevated triglyceride levels.",
                "low": "Your screening suggests your triglyceride markers are <tag color=\"\(AppColors.tagRiskLow)\">within a standard, low-risk profile</tag>.",
                "moderate": "Your screening suggests your triglyceride markers are <tag color=\"\(AppColors.tagRiskWarning)\">currently sitting in a moderate range</tag>.",
                "high": "Your screening suggests triglyceride levels are <tag color=\"\(AppColors.tagRiskMedium)\">currently above the recommended healthy threshold</tag>.",
                "very_high": "Your screening suggests indicators consistent with a <tag color=\"\(AppColors.tagRiskHigh)\">high concentration of triglyceride in the blood</tag>."
            ]
        ]

        static func displayTitle(for key: String) -> String {
            switch key {
            case "BP_CVD": return "Cardiovascular Disease Risk"
            case "HR_BPM": return "Heart Rate"
            case "HBA1C_RISK_PROB": return "HbA1c Risk"
            case "BP_SYSTOLIC": return "Systolic Blood Pressure"
            case "BP_DIASTOLIC": return "Diastolic Blood Pressure"
            case "HDLTC_RISK_PROB": return "High Cholesterol Risk"
            case "TG_RISK_PROB": return "High Triglycerides Risk"
            default: return key.replacingOccurrences(of: "_", with: " ")
            }
        }

        static func gridTitle(for key: String) -> String {
            switch key {
            case "BP_CVD": return "Cardiovascular Risk"
            case "HBA1C_RISK_PROB": return "Hemoglobin A1C Risk"
            case "HR_BPM": return "Heart Rate"
            default: return displayTitle(for: key)
            }
        }

        static func description(for key: String) -> String {
            switch key {
            case "BP_CVD": return "Think of this as your heart's 10-year weather forecast. It estimates how likely you are to experience a heart attack or stroke based on signals from your face scan. The lower the number, the clearer the skies."
            case "HR_BPM": return "Heart rate is the number of times your heart beats per minute."
            case "BP_SYSTOLIC": return "Systolic blood pressure is the peak pressure in your brachial arteries during the contraction of your heart muscle, measured in millimeters of mercury (mmHg)."
            case "BP_DIASTOLIC": return "Diastolic blood pressure is the amount of pressure in your brachial arteries when your heart muscle is relaxed, measured in millimeters of mercury (mmHg)."
            case "HBA1C_RISK_PROB": return "A hemoglobin A1C (HbA1C) test is a blood test that measures the amount of glucose (sugar) attached to the hemoglobin in your red blood cells."
            case "HDLTC_RISK_PROB": return "Hypercholesterolemia is when you have high amounts of cholesterol in the blood. High cholesterol can limit blood flow, increasing the risk of a heart attack or stroke."
            case "TG_RISK_PROB": return "Hypertriglyceridemia is when you have an abnormally high level of a certain type of fat (triglycerides) in the blood, defined above 1.7 mmol/L or 150 mg/dL."
            default: return ""
            }
        }
    }
}


enum ScreenSaverStrings {
    static let loading = "Loading..."
    static let title = "Welcome to the Hibiscus Health Kiosk!"
    static let subtitle = "30-second face scan that identifies patient/member risk before, during, and between visits."
    static let actionButton = "Start Patient/Member Demo Here"
    static let qrPrompt = "Try on your smartphone"
}


enum SharedViewStrings {
    enum Toolbar {
        static let companyLogoPlaceholder = "PUT YOUR CLINIC\nLOGO HERE"
        static let resultPartnerLogoPlaceholder = "Partner logo\ngoes here"
    }

    enum WebView {
        static let faceScanDemoTitle = "Face Scan Demo"
        static let doneButtonTitle = "Done"
    }
}
