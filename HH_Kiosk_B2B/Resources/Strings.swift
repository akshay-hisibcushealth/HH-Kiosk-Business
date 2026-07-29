import Foundation

enum ArticleScreenStrings {
    static let imageLoading = "Loading Image..."
    static let body = """
    If you are feeling stiff and uncomfortable while working at a sedentary job, there are exercises you can do without even leaving your desk that will leave you feeling refreshed and healthier.

    Work-related disorders aren’t just limited to heavy manufacturing or construction. They can occur in all types of industries and work environments, including office spaces. Research shows that repetitive motion, poor posture, and staying in the same position can cause or worsen musculoskeletal disorders.

    Staying in one position while doing repetitive motions is typical of a desk job. An analysis of job industry trends over the past 50 years revealed that at least 8 in 10 American workers are desk potatoes. The habits we build at our desk, especially while sitting, can contribute to discomfort and health issues, including:
    """
}


enum HomeScreenStrings {
    static let responseReceivedToast = "Response Received"

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
        static let unavailableTitle = "Content Temporarily Unavailable"
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
    static let title = "Tell us about yourself"
    static let subtitle = "We use these details to ensure your scan results are as accurate as possible."
    static let privacyMessage = "We value your privacy. Your information will NOT be shared externally."
    static let watchQuickDemo = "Watch Demo"
    static let proceedToScan = "Proceed to Scan"
    #if DEBUG
    static let debugHitAPI = "Hit API"
    static let debugProceedToResults = "Skip to Results"
    #endif
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
        static let agePlaceholder = "How old are you?"
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
    static let reportLabel = "YOUR 30-SECOND WELLNESS REPORT"
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
        static let emailResults = "Email Results"
        static let back = "Back"
        static let secureAndPrivate = "Secure and Private"
        static let print = "Print"
        static let endSession = "End Session"
        static let viewNextSteps = "View Next Steps"
    }

    enum EmailPopup {
        static let emailSentConfirmation = "Your result has been sent to your email!"
        static let whatNextTitle = "What next?"
        static let oneLastThingTitle = "One last thing before you leave,"
        static let supportSubtitle = "How can we support you from here?"
        static let close = "Close"
        static let confirm = "Confirm"
        static let title = "Email me my results"
        static let subtitle = "We'll send a secure document.\nYour 4-digit PIN unlocks the results, only you can open them."
        static let emailAddress = "Email Address"
        static let emailPlaceholder = "Email"
        static let pinTitle = "Create a 4-digit PIN (used to open your report)"
        static let pinPlaceholder = "* * * *"
        static let pinHelp = "This will be used to view your result"
        static let sendMail = "Send my results"
        static let emailFailure = "Failed to send email. Please try again."
        static let secureAndPrivate = "Secure and Private"
        static let checkInboxTitle = "Check your inbox!"
        static let emailSentMessage = "Your result has been sent to your email!\nTell a colleague about our Kiosk!"
        static let done = "Done"

        enum NextSteps {
            static let talkToDoctorTitle = "Talk to a Hibiscus Doctor"
            static let talkToDoctorSubtitle = "Connect with a Hibiscus Health physician to review your results."
            static let talkToDoctorBodyPrefix = "Your results are in -- and a Hibiscus Health physician is ready to walk you through them. Schedule at this link: "
            static let talkToDoctorLink = "https://calendly.com/david-hibiscushealth/30min"
            static let talkToDoctorBodySuffix = ". Alternatively, the scheduling link will be emailed to you if you emailed your results."
            static let dietitianTitle = "Explore Hibiscus Dietitian Care"
            static let dietitianSubtitle = "Get personalized nutrition guidance from a registered dietitian."
            static let dietitianBody = "Turn your data into a plan. A Registered Dietitian can review your results and build a nutrition plan around your specific needs to improve your health. A scheduling link will be sent to your email."
            static let monitoringTitle = "Keep monitoring my health"
            static let monitoringSubtitle = "Schedule regular scans to track my biomarkers over time."
            static let monitoringBodyPrefix = "One scan is a snapshot. Regular scans show the full picture. Download the mobile app by scanning the appropriate QR code and use dietitian code "
            static let monitoringCode = "\"KIRKLAND\""
            static let monitoringBodySuffix = " to sign-up. Take a picture of this pop-up to remember the code later on."
        }
    }

    enum PostSession {
        static let nextStepsHeading = "Thank you for taking the time to complete this important scan"
        static let nextStepsSubtitle = "Based on your results, here are some common next steps"
        static let continueTitle = "Continue"
        static let allDoneTitle = "All done.\nThank you for visiting our kiosk!"
        static let allDoneDescription = "Your wellness report and selected next steps have been sent to your email.\nWe hope you found this experience valuable."
        static let completionBody = "Your selected next steps have been saved."
        static let completionSubtitle = "We hope you found this experience valuable."
        static let npsEyebrow = "ONE QUICK QUESTION"
        static let npsQuestion = "Would you recommend this experience to others?"
        static let notLikely = "Not at all likely"
        static let extremelyLikely = "Extremely likely"
        static let skip = "SKIP"
        static let submitAndReturnHome = "Submit and return home"
        static let submitFailure = "Failed to submit response. Please try again."

        enum NextSteps {
            static let annualPhysical = "Schedule an annual physical with my primary care provider for a comprehensive health exam"
            static let biometricScreening = "Sign up for an on-site biometric screening with Empower Health Services in October"
            static let nutritionCounseling = "Sign up for nutrition counseling with a registered dietitian"
            static let ongoingMonitoring = "Keep monitoring my health — complete scans ongoing to track my biomarkers over time"
        }
    }

    enum Metrics {
        static let interpretations: [String: [String: String]] = [
            "Adverse Cardiovascular Event Risk": [
                "very_low": "Your screening suggests a very low likelihood of a heart attack or stroke in the next 10 years.",
                "low": "Your screening suggests a low likelihood of a heart attack or stroke in the next 10 years.",
                "moderate_low": "Your screening suggests a moderate-low likelihood of a heart attack or stroke in the next 10 years.",
                "moderate": "Your screening suggests a moderate likelihood of a heart attack or stroke in the next 10 years.",
                "high": "Your screening suggests a higher likelihood of a heart attack or stroke in the next 10 years."
            ],
            "Systolic Blood Pressure": [
                "healthy": "Your screening suggests your systolic blood pressure is within a healthy range.",
                "low": "Your screening suggests your systolic blood pressure may be lower than the healthy range.",
                "slightly_high": "Your screening suggests your systolic blood pressure may be slightly above the healthy range.",
                "high": "Your screening suggests your systolic blood pressure may be significantly elevated."
            ],
            "Diastolic Blood Pressure": [
                "healthy": "Your screening suggests your diastolic blood pressure is within a healthy range.",
                "low": "Your screening suggests your diastolic blood pressure may be lower than the healthy range.",
                "slightly_low": "Your screening suggests your diastolic blood pressure may be slightly lower the healthy range.",
                "slightly_high": "Your screening suggests your diastolic blood pressure may be slightly above the healthy range.",
                "high": "Your screening suggests your diastolic blood pressure may be significantly elevated."
            ],
            "Heart Rate": [
                "low": "Your screening suggests your heart rate is below a normal resting range.",
                "normal": "Your screening suggests your heart rate is within a normal resting range.",
                "high": "Your screening suggests your heart rate is higher than the typical resting range."
            ],
            "Diabetes/Prediabetes Risk (HbA1c)": [
                "very_low": "Your screening suggests your HbA1c markers are within a healthy, stable range.",
                "low": "Your screening suggests your HbA1c is likely below the threshold for concern.",
                "moderate": "Your screening suggests your HbA1c (blood sugar level) markers are slightly elevated compared to the ideal range.",
                "high": "Your screening suggests that your blood sugar levels are currently above the standard healthy range.",
                "very_high": "Your screening suggests blood sugar markers that are notably above the standard healthy range."
            ],
            "Risk of High Cholesterol": [
                "very_low": "Your screening suggests a very low probability of elevated cholesterol levels.",
                "low": "Your screening suggests your cholesterol markers are within a standard, low-risk profile.",
                "moderate": "Your screening suggests your cholesterol levels are within a moderate risk range.",
                "high": "Your screening suggests cholesterol levels are currently above the recommended healthy threshold.",
                "very_high": "Your screening suggests indicators consistent with a high concentration of cholesterol in the blood."
            ],
            "Risk of High Triglycerides": [
                "very_low": "Your screening suggests a very low probability of elevated triglyceride levels.",
                "low": "Your screening suggests your triglyceride markers are within a standard, low-risk profile.",
                "moderate": "Your screening suggests your triglyceride levels are within a moderate risk range.",
                "high": "Your screening suggests triglyceride levels are currently above the recommended healthy threshold.",
                "very_high": "Your screening suggests indicators consistent with a high concentration of triglyceride in the blood."
            ]
        ]

        static func displayTitle(for key: String) -> String {
            switch key {
            case "BP_CVD": return "Adverse Cardiovascular Event Risk"
            case "HR_BPM": return "Heart Rate"
            case "HBA1C_RISK_PROB": return "Diabetes/Prediabetes Risk (HbA1c)"
            case "BP_SYSTOLIC": return "Systolic Blood Pressure"
            case "BP_DIASTOLIC": return "Diastolic Blood Pressure"
            case "HDLTC_RISK_PROB": return "Risk of High Cholesterol"
            case "TG_RISK_PROB": return "Risk of High Triglycerides"
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
            case "BP_CVD": return "This is our estimation of how likely you are to experience a heart attack or stroke within the next 10 years. This is based on signals from your face scan."
            case "BP_SYSTOLIC": return "This is the pressure your heart creates when it pumps blood out. Too high over time and it puts extra strain on your blood vessels. A normal reading is usually around 90–120 mmHg."
            case "BP_DIASTOLIC": return "This is the pressure in your blood vessels when your heart is resting between beats.\nA normal reading is usually around 60–80 mmHg."
            case "HBA1C_RISK_PROB": return "This is our estimation of your long term blood sugar patterns over the past three months based on signals from your face scan. High blood sugar over time is linked to pre-diabetes and type 2 diabetes."
            case "HDLTC_RISK_PROB": return "This is our estimation of how likely you are to have high cholesterol levels based on signals from your face scan. Too much cholesterol in your blood can clog your blood vessels over time."
            case "TG_RISK_PROB": return "This is our estimation of how likely you are to have high triglyceride levels based on signals from your face scan. Triglycerides are the most common type of fat in your body. Having too much of them can increase your risk of heart disease and stroke."
            case "HR_BPM": return "This is how many times your heart beats per minute during your scan. Most healthy adults are between 60 and 100 beats per minute (BPM) when resting. If this is too high or too low consistently, it is something to discuss with your doctor."
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
