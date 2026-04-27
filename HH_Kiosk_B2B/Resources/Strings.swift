import Foundation

enum ClientIDScreenStrings {
    static let title = "Hibiscus Health Wellness Kiosk"
    static let subtitle = "Take a few minutes to check in on your health."
    static let cardTitle = "Client Login"
    static let fieldLabel = "Company Client ID"
    static let fieldPlaceholder = "Enter 8-digit code"
    static let actionButton = "Start Your Health Journey"
    static let formatValidationMessage = "Please enter a valid 8-character client ID."
    static let fallbackInvalidCodeMessage = "Invalid company code"
}

enum ArticleScreenStrings {
    static let imageLoading = "Loading Image..."
    static let body = """
    If you are feeling stiff and uncomfortable while working at a sedentary job, there are exercises you can do without even leaving your desk that will leave you feeling refreshed and healthier.

    Work-related disorders aren’t just limited to heavy manufacturing or construction. They can occur in all types of industries and work environments, including office spaces. Research shows that repetitive motion, poor posture, and staying in the same position can cause or worsen musculoskeletal disorders.

    Staying in one position while doing repetitive motions is typical of a desk job. An analysis of job industry trends over the past 50 years revealed that at least 8 in 10 American workers are desk potatoes. The habits we build at our desk, especially while sitting, can contribute to discomfort and health issues, including:
    """
}


enum HomeScreenStrings {
    enum Weather {
        static let loading = "Loading Weather..."
        static let errorTitle = "Error:"
        static let fetchingLocation = "Fetching location..."
        static let welcomePrefix = "Welcome to the"
        static let companyName = "[ABC Company]"
        static let kioskSuffix = "Kiosk"
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
        static let hrDeskTitle = "From HR Desk"
    }

    enum Schedule {
        static let sectionTitle = "Today's Schedule"
        static let noSchedule = "No Schedule"
        static let dailyStandupTitle = "Daily Stand-Up"
        static let dailyStandupDescription = "A stand-up meeting is a meeting in which attendees typically participate while standing."

        static let eventPool: [(title: String, description: String)] = [
            ("Quarterly Town Hall Meeting", "To discuss about the upcoming project & organization of units"),
            ("Q3 Wellness Challenge begins", "To discuss about the upcoming project & organization of units"),
            ("Diversity, Equity & Inclusion (DEI) Awareness Days", "Panels, training, and celebration of heritage months or cultural milestones."),
            ("Wellness Week / Health Fair", "Activities focused on physical and mental well-being."),
            ("Hackathons / Innovation Days", "Creative sprints where teams develop solutions, tools, or prototypes."),
            ("Team-Building Retreat", "A full-day or overnight program to boost collaboration and morale."),
            ("Company Anniversary", "Celebration of the organization's founding and journey."),
            ("Open Enrollment / Benefits Fair", "Informational sessions on employee benefits, insurance, and perks."),
            ("Community Service / Volunteer Day", "Team-led initiatives supporting local organizations."),
            ("Mid-Year Review", "Alignment on key metrics, shifting priorities, and future plans."),
            ("New Employee Welcome Sessions", "Monthly or quarterly onboarding experiences with leadership meet-and-greets.")
        ]
    }
}


enum PhysicalAttributesScreenStrings {
    static let title = "Physical Attributes"
    static let subtitle = "For best accuracy, kindly complete the form below."
    static let privacyMessage = "We value your privacy. Your information will NOT be shared externally."
    static let watchQuickDemo = "Watch Quick Demo"
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
        static let ageLabel = "Age (years)"
        static let agePlaceholder = "Select age"
        static let heightLabel = "Height (ft/in)"
        static let heightPlaceholder = "Select height"
        static let heightSheetTitle = "Select Height"
        static let feetUnit = "ft"
        static let inchesUnit = "in"
        static let doneButton = "Done"
        static let weightLabel = "Weight (lbs)"
        static let weightPlaceholder = "Select weight"
        static let genderLabel = "Gender (at birth)"
        static let genderPlaceholder = "Select Gender"
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
        static let emailMyResults = "Email my results"
        static let secureAndPrivate = "Secure and Private"
        static let print = "Print"
        static let endSession = "End Session"
    }

    enum EmailPopup {
        static let inboxTitle = "Check your inbox!"
        static let inboxMessage = "Your result has been sent to your email!\nTell a colleague about our Kiosk!"
        static let returnHome = "Return to Home Screen"
        static let title = "Send result to your mail"
        static let emailAddress = "Email address"
        static let emailPlaceholder = "Email"
        static let pinTitle = "Create a 4-digit secret key"
        static let pinPlaceholder = "* * * *"
        static let pinHelp = "This will be used to view your result"
        static let sendMail = "Send mail"
        static let emailFailure = "Failed to send email. Please try again."
        static let secureAndPrivate = "Secure and Private"
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
    static let title = "Welcome to the Hibiscus Wellness Kiosk!"
    static let subtitle = "Take a few minutes to check in on your health."
    static let actionButton = "Start Your Health Journey"
    static let qrPrompt = "Scan to try it on your smartphone!"
}


enum SharedViewStrings {
    enum Toolbar {
        static let companyLogoPlaceholder = "PUT YOUR COMPANY\nLOGO HERE"
        static let resultPartnerLogoPlaceholder = "Partner logo\ngoes here"
    }

    enum WebView {
        static let faceScanDemoTitle = "Face Scan Demo"
        static let doneButtonTitle = "Done"
    }
}
