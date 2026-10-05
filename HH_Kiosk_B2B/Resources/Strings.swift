import Foundation

enum ArticleScreenStrings {
    static var imageLoading: String { AppLocalization.string("app.current.Loading_Image", defaultValue: "Loading Image...") }
    static var body: String { AppLocalization.string("app.current.ArticleScreenStrings.body", defaultValue: "If you are feeling stiff and uncomfortable while working at a sedentary job, there are exercises you can do without even leaving your desk that will leave you feeling refreshed and healthier.\n\nWork-related disorders aren’t just limited to heavy manufacturing or construction. They can occur in all types of industries and work environments, including office spaces. Research shows that repetitive motion, poor posture, and staying in the same position can cause or worsen musculoskeletal disorders.\n\nStaying in one position while doing repetitive motions is typical of a desk job. An analysis of job industry trends over the past 50 years revealed that at least 8 in 10 American workers are desk potatoes. The habits we build at our desk, especially while sitting, can contribute to discomfort and health issues, including:") }
}


enum HomeScreenStrings {
    static var responseReceivedToast: String { AppLocalization.string("app.HomeScreenStrings.Response_Received", defaultValue: "Response Received") }

    enum Weather {
        static var loading: String { AppLocalization.string("app.HomeScreenStrings.Weather.Loading_Weather", defaultValue: "Loading Weather...") }
        static var errorTitle: String { AppLocalization.string("app.HomeScreenStrings.Weather.Error", defaultValue: "Error:") }
        static var fetchingLocation: String { AppLocalization.string("app.HomeScreenStrings.Weather.Fetching_location", defaultValue: "Fetching location...") }
        static var welcomePrefix: String { AppLocalization.string("app.HomeScreenStrings.Weather.Welcome_to_the", defaultValue: "Welcome to the") }
        static var companyName: String { AppLocalization.string("app.HomeScreenStrings.Weather.ABC_Company", defaultValue: "[ABC Company]") }
        static var kioskSuffix: String { AppLocalization.string("app.HomeScreenStrings.Weather.Kiosk", defaultValue: "Kiosk") }
    }

    enum Promo {
        static var title: String { AppLocalization.string("app.HomeScreenStrings.Promo.Curious_About_Your_Health", defaultValue: "Curious About Your Health?") }
        static var subtitle: String { AppLocalization.string("app.HomeScreenStrings.Promo.Start_with_a_30_seconds_Face_Scan", defaultValue: "Start with a 30 seconds Face Scan") }
        static var demoButtonTitle: String { AppLocalization.string("app.HomeScreenStrings.Promo.Watch_Quick_Demo", defaultValue: "Watch Quick Demo") }
        static var tryFaceScan: String { AppLocalization.string("app.HomeScreenStrings.Promo.Try_Face_Scan", defaultValue: "Try Face Scan") }
        static let demoURL = "https://drive.google.com/file/d/1dPJs1A6aptEh3yTCVxR5BUlRfyLWa3rL/view?usp=sharing"
    }

    enum ReadSection {
        static var loading: String { AppLocalization.string("app.HomeScreenStrings.ReadSection.Loading", defaultValue: "Loading...") }
        static var unavailableTitle: String { AppLocalization.string("app.HomeScreenStrings.ReadSection.Content_Temporarily_Unavailable", defaultValue: "Content Temporarily Unavailable") }
        static var todaysReadTitle: String { AppLocalization.string("app.HomeScreenStrings.ReadSection.Today_s_Read", defaultValue: "Today's Read") }
        static var articleBadge: String { AppLocalization.string("app.HomeScreenStrings.ReadSection.Article", defaultValue: "Article") }
        static var hrDeskTitle: String { AppLocalization.string("app.HomeScreenStrings.ReadSection.From_HR_Desk", defaultValue: "From HR Desk") }
    }

    enum Schedule {
        static var sectionTitle: String { AppLocalization.string("app.HomeScreenStrings.Schedule.Today_s_Schedule", defaultValue: "Today's Schedule") }
        static var noSchedule: String { AppLocalization.string("app.HomeScreenStrings.Schedule.No_Schedule", defaultValue: "No Schedule") }
        static var dailyStandupTitle: String { AppLocalization.string("app.HomeScreenStrings.Schedule.Daily_Stand_Up", defaultValue: "Daily Stand-Up") }
        static var dailyStandupDescription: String { AppLocalization.string("app.HomeScreenStrings.Schedule.A_stand_up_meeting_is_a_meeting_in_which_attendees_typically", defaultValue: "A stand-up meeting is a meeting in which attendees typically participate while standing.") }

        static var eventPool: [(title: String, description: String)] { [
            (AppLocalization.string("app.HomeScreenStrings.Schedule.Quarterly_Town_Hall_Meeting", defaultValue: "Quarterly Town Hall Meeting"), AppLocalization.string("app.HomeScreenStrings.Schedule.To_discuss_about_the_upcoming_project_organization_of_units_2", defaultValue: "To discuss about the upcoming project & organization of units")),
            (AppLocalization.string("app.HomeScreenStrings.Schedule.Q3_Wellness_Challenge_begins", defaultValue: "Q3 Wellness Challenge begins"), AppLocalization.string("app.HomeScreenStrings.Schedule.To_discuss_about_the_upcoming_project_organization_of_units_2", defaultValue: "To discuss about the upcoming project & organization of units")),
            (AppLocalization.string("app.HomeScreenStrings.Schedule.Diversity_Equity_Inclusion_DEI_Awareness_Days", defaultValue: "Diversity, Equity & Inclusion (DEI) Awareness Days"), AppLocalization.string("app.HomeScreenStrings.Schedule.Panels_training_and_celebration_of_heritage_months_or_cultur", defaultValue: "Panels, training, and celebration of heritage months or cultural milestones.")),
            (AppLocalization.string("app.HomeScreenStrings.Schedule.Wellness_Week_Health_Fair", defaultValue: "Wellness Week / Health Fair"), AppLocalization.string("app.HomeScreenStrings.Schedule.Activities_focused_on_physical_and_mental_well_being", defaultValue: "Activities focused on physical and mental well-being.")),
            (AppLocalization.string("app.HomeScreenStrings.Schedule.Hackathons_Innovation_Days", defaultValue: "Hackathons / Innovation Days"), AppLocalization.string("app.HomeScreenStrings.Schedule.Creative_sprints_where_teams_develop_solutions_tools_or_prot", defaultValue: "Creative sprints where teams develop solutions, tools, or prototypes.")),
            (AppLocalization.string("app.HomeScreenStrings.Schedule.Team_Building_Retreat", defaultValue: "Team-Building Retreat"), AppLocalization.string("app.HomeScreenStrings.Schedule.A_full_day_or_overnight_program_to_boost_collaboration_and_m", defaultValue: "A full-day or overnight program to boost collaboration and morale.")),
            (AppLocalization.string("app.HomeScreenStrings.Schedule.Company_Anniversary", defaultValue: "Company Anniversary"), AppLocalization.string("app.HomeScreenStrings.Schedule.Celebration_of_the_organization_s_founding_and_journey", defaultValue: "Celebration of the organization's founding and journey.")),
            (AppLocalization.string("app.HomeScreenStrings.Schedule.Open_Enrollment_Benefits_Fair", defaultValue: "Open Enrollment / Benefits Fair"), AppLocalization.string("app.HomeScreenStrings.Schedule.Informational_sessions_on_employee_benefits_insurance_and_pe", defaultValue: "Informational sessions on employee benefits, insurance, and perks.")),
            (AppLocalization.string("app.HomeScreenStrings.Schedule.Community_Service_Volunteer_Day", defaultValue: "Community Service / Volunteer Day"), AppLocalization.string("app.HomeScreenStrings.Schedule.Team_led_initiatives_supporting_local_organizations", defaultValue: "Team-led initiatives supporting local organizations.")),
            (AppLocalization.string("app.HomeScreenStrings.Schedule.Mid_Year_Review", defaultValue: "Mid-Year Review"), AppLocalization.string("app.HomeScreenStrings.Schedule.Alignment_on_key_metrics_shifting_priorities_and_future_plan", defaultValue: "Alignment on key metrics, shifting priorities, and future plans.")),
            (AppLocalization.string("app.HomeScreenStrings.Schedule.New_Employee_Welcome_Sessions", defaultValue: "New Employee Welcome Sessions"), AppLocalization.string("app.HomeScreenStrings.Schedule.Monthly_or_quarterly_onboarding_experiences_with_leadership", defaultValue: "Monthly or quarterly onboarding experiences with leadership meet-and-greets."))
        ] }
    }
}


enum PhysicalAttributesScreenStrings {
    static var title: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Tell_us_about_yourself", defaultValue: "Tell us about yourself") }
    static var subtitle: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.We_use_these_details_to_ensure_your_scan_results_are_as_accu", defaultValue: "We use these details to ensure your scan results are as accurate as possible.") }
    static var privacyMessage: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.We_value_your_privacy_Your_information_will_NOT_be_shared_ex", defaultValue: "We value your privacy. Your information will NOT be shared externally.") }
    static var watchQuickDemo: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Watch_Demo", defaultValue: "Watch Demo") }
    static var proceedToScan: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Proceed_to_Scan", defaultValue: "Proceed to Scan") }
    static var debugProceedToResults: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Skip_to_Results", defaultValue: "Skip to Results") }
    static var debugRefresh: String { AppLocalization.string("app.current.Refresh", defaultValue: "Refresh") }
    static var alertDismiss: String { AppLocalization.string("app.ResultScreenStrings.Print.OK", defaultValue: "OK") }
    static let demoURL = "https://drive.google.com/file/d/1dPJs1A6aptEh3yTCVxR5BUlRfyLWa3rL/view?usp=sharing"

    enum Validation {
        static var missingEmail: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Please_enter_your_email", defaultValue: "Please enter your email.") }
        static var invalidEmail: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Please_enter_a_valid_email", defaultValue: "Please enter a valid email.") }
        static var invalidPIN: String { AppLocalization.string("app.current.Please_enter_a_4_digit_PIN", defaultValue: "Please enter a 4-digit PIN.") }
        static var missingHeight: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Please_select_your_height", defaultValue: "Please select your height.") }
        static var missingWeight: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Weight_cannot_be_empty", defaultValue: "Weight cannot be empty.") }
        static var invalidWeight: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Weight_cannot_be_less_than_75_lbs", defaultValue: "Weight cannot be less than 75 lbs.") }
        static var missingAge: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Please_enter_your_age", defaultValue: "Please enter your age.") }
        static var invalidAge: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Age_must_be_between_13_and_120_years", defaultValue: "Age must be between 13 and 120 years.") }
        static var missingGender: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Please_select_your_gender", defaultValue: "Please select your gender.") }
    }

    enum Debug {
        static var fillDummyData: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Debug.Fill_Dummy_Data", defaultValue: "Fill Dummy Data") }
        static var submitScanAPI: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Debug.Submit_Debug_Scan_API", defaultValue: "Submit Debug Scan API") }
        static var scanAPISubmitted: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Debug.Debug_scan_API_submitted_successfully", defaultValue: "Debug scan API submitted successfully.") }
        static var scanAPIFailed: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Debug.Failed_to_submit_debug_scan_API", defaultValue: "Failed to submit debug scan API.") }
    }

    enum Form {
        static var emailLabel: String { AppLocalization.string("app.current.Email_We_send_your_results_here", defaultValue: "Email (We send your results here)") }
        static var emailPlaceholder: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Enter_email", defaultValue: "Enter email") }
        static var emailInlineError: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Enter_a_valid_email_address", defaultValue: "Enter a valid email address") }
        static var pinLabel: String { AppLocalization.string("app.current.Enter_4_digit_PIN_used_to_open_your_report", defaultValue: "Enter 4-digit PIN (used to open your report)") }
        static var pinPlaceholder: String { AppLocalization.string("app.current.", defaultValue: "_ _ _ _") }
        static var ageLabel: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Age", defaultValue: "Age") }
        static var agePlaceholder: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.How_old_are_you", defaultValue: "How old are you?") }
        static var heightLabel: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Height", defaultValue: "Height") }
        static var heightPlaceholder: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Feet_Inches", defaultValue: "Feet / Inches") }
        static var heightSheetTitle: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Select_Height", defaultValue: "Select Height") }
        static var feetUnit: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.ft", defaultValue: "ft") }
        static var inchesUnit: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.in", defaultValue: "in") }
        static var doneButton: String { AppLocalization.string("app.SharedViewStrings.WebView.Done", defaultValue: "Done") }
        static var weightLabel: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Weight", defaultValue: "Weight") }
        static var weightPlaceholder: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Lbs", defaultValue: "Lbs") }
        static var genderLabel: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Sex_at_birth", defaultValue: "Sex (at birth)") }
        static var genderPlaceholder: String { AppLocalization.string("app.current.Male_Female", defaultValue: "Male / Female") }
        // Values are persisted and submitted to the SDK; only their labels are translated.
        static let genderOptions = ["Male", "Female"]
        static func genderTitle(for value: String) -> String {
            switch value {
            case "Male": return AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Male", defaultValue: "Male")
            case "Female": return AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Female", defaultValue: "Female")
            default: return value
            }
        }
    }

    enum Settings {
        static var cameraPreset: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.External_camera_preset", defaultValue: "External camera preset") }
        static var previewOrientation: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.Preview_orientation", defaultValue: "Preview orientation") }
        static var mirrorExternalVideo: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.Mirror_external_camera_video", defaultValue: "Mirror external camera video") }
        static var useExternalCameraOnly: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.Use_external_camera_only", defaultValue: "Use external camera only") }
        static var externalCameraDescription: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.If_enabled_only_the_external_camera_will_be_used_If_disabled", defaultValue: "If enabled, only the external camera will be used. If disabled, the app will automatically switch between the built-in camera and an external camera (external camera is prioritized).") }
        static var title: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.Camera_Settings", defaultValue: "Camera Settings") }
        static var closeButton: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.Close", defaultValue: "Close") }
        static var unknownOption: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.Unknown", defaultValue: "Unknown") }
        static var portrait: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.Portrait", defaultValue: "Portrait") }
        static var landscapeLeft: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.LandscapeLeft", defaultValue: "LandscapeLeft") }
        static var landscapeRight: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.LandscapeRight", defaultValue: "LandscapeRight") }
        static var portraitUpsideDown: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Settings.PortraitUpsideDown", defaultValue: "PortraitUpsideDown") }
    }
}


enum ReadPdfScreenStrings {
    static var loading: String { AppLocalization.string("app.ReadPdfScreenStrings.Loading_PDF", defaultValue: "Loading PDF...") }
    static var failedToLoad: String { AppLocalization.string("app.ReadPdfScreenStrings.Failed_to_load_PDF", defaultValue: "Failed to load PDF") }
}


enum ResultScreenStrings {
    static let pdfFileName = "Hibiscus_Health_Report"
    static var reportLabel: String { AppLocalization.string("app.current.YOUR_30_SECOND_WELLNESS_REPORT", defaultValue: "YOUR 30-SECOND WELLNESS REPORT") }
    static var title: String { AppLocalization.string("app.ResultScreenStrings.Great_job_taking_a_proactive_step_for_your_health", defaultValue: "Great job taking a proactive step for your health!") }
    static var heroDescription: String { AppLocalization.string("app.ResultScreenStrings.Below_is_a_summary_of_your_key_biomarkers_based_on_your_30_s", defaultValue: "Below is a summary of your key biomarkers based on your 30-second scan.") }
    static var titleBlockDescription: String { AppLocalization.string("app.ResultScreenStrings.This_report_is_intended_to_improve_your_awareness_of_general", defaultValue: "This report is intended to improve your awareness of general wellness. It is not a substitute for the clinical judgment of a health care professional.  These results provide a non-diagnostic screening to help you understand your current wellness trends.") }
    static var infoFooter: String { AppLocalization.string("app.ResultScreenStrings.Hibiscus_Health_is_intended_to_improve_your_awareness_of_gen", defaultValue: "Hibiscus Health is intended to improve your awareness of general wellness. Hibiscus Health does not diagnose, treat, mitigate or prevent any disease, symptom, disorder or abnormal physical state. Consult with a healthcare professional or emergency services if you believe you may have a medical issue.") }
    static var privacyMessage: String { AppLocalization.string("app.ResultScreenStrings.The_results_from_this_face_scan_are_not_intended_to_diagnose", defaultValue: "The results from this face scan are not intended to diagnose, treat, or replace professional medical advice. For any health concerns, please consult a healthcare provider.") }
    static var nextStepsTitle: String { AppLocalization.string("app.current.Next_Steps", defaultValue: "Next Steps") }
    static var nextStepsPrefix: String { AppLocalization.string("app.current.We_know_every_organization_is_unique_Whether_you_re_an_employer_health_plan_or_solution_pa", defaultValue: "We know every organization is unique. Whether you’re an employer, health plan, or solution partner, Hibiscus can integrate seamlessly into your existing ecosystem, or provide full end-to-end support from ") }
    static var nextStepsEmphasis: String { AppLocalization.string("app.current.Face_Scan_Care_Guide_Clinician", defaultValue: "Face Scan -> Care Guide -> Clinician") }
    static var nextStepsSuffix: String { AppLocalization.string("app.current.for_maximum_impact_Choose_the_components_that_best_complement_your_current_resources", defaultValue: " for maximum impact. Choose the components that best complement your current resources.") }
    static var footerResources: String { AppLocalization.string("app.current.Find_even_more_resources_tips_insights_on_the_app", defaultValue: "Find even more resources\ntips & insights on the app,") }
    static let footerAddress = "575 LEXINGTON AVE, FL 14TH NEW YORK, NY 10022-6102 United States"
    static let appStoreURL = "https://apps.apple.com/tn/app/hibiscus-health/id6478411080"
    static let playStoreURL = "https://play.google.com/store/apps/details?id=com.nutritionApp.hibiscus_health&hl"

    enum Actions {
        static var closeResult: String { AppLocalization.string("app.current.Close_result", defaultValue: "Close result") }
        static var back: String { AppLocalization.string("app.ResultScreenStrings.Actions.Back", defaultValue: "Back") }
        static var secureAndPrivate: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.Secure_and_Private", defaultValue: "Secure and Private") }
        static var print: String { AppLocalization.string("app.current.Print", defaultValue: "Print") }
        static var endSession: String { AppLocalization.string("app.current.End_Session", defaultValue: "End Session") }
        static var viewNextSteps: String { AppLocalization.string("app.ResultScreenStrings.Actions.View_Next_Steps", defaultValue: "View Next Steps") }
    }

    enum EmailDelivery {
        static var success: String { AppLocalization.string("app.current.Your_results_have_been_sent_to_your_email", defaultValue: "Your results have been sent to your email!") }
        static var failure: String { AppLocalization.string("app.current.Unable_to_email_your_results_Please_contact_kiosk_support", defaultValue: "Unable to email your results. Please contact kiosk support.") }
    }

    enum PostSession {
        static var nextStepsHeading: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Your_next_step", defaultValue: "Your next step") }
        static var nextStepsSubtitle: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.What_will_you_do_based_on_your_results_select_all_that_apply", defaultValue: "What will you do based on your results? (select all that apply)") }
        static var continueTitle: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Continue", defaultValue: "Continue") }
        static var allDoneTitle: String { AppLocalization.string("app.current.Thank_you_for_visiting_our_kiosk", defaultValue: "Thank you for visiting our kiosk!") }
        static var allDoneDescription: String { AppLocalization.string("app.current.Your_wellness_report_and_selected_next_steps_have_been_sent_to_your_email_We_hope_you_foun", defaultValue: "Your wellness report and selected next steps have been sent to your email.\nWe hope you found this experience valuable.") }
        static var completionBody: String { AppLocalization.string("app.current.Your_selected_next_steps_have_been_saved", defaultValue: "Your selected next steps have been saved.") }
        static var completionSubtitle: String { AppLocalization.string("app.current.We_hope_you_found_this_experience_valuable", defaultValue: "We hope you found this experience valuable.") }
        static var npsEyebrow: String { AppLocalization.string("app.current.ONE_LAST_QUESTION", defaultValue: "ONE LAST QUESTION") }
        static var npsQuestion: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Would_you_recommend_this_experience_to_others", defaultValue: "Would you recommend this experience to others?") }
        static var notLikely: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Not_at_all_likely", defaultValue: "Not at all likely") }
        static var extremelyLikely: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Extremely_likely", defaultValue: "Extremely likely") }
        static var skip: String { AppLocalization.string("app.current.SKIP", defaultValue: "SKIP") }
        static var submitAndReturnHome: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Submit_and_return_home", defaultValue: "Submit and return home") }
        static var submitFailure: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Failed_to_submit_response_Please_try_again", defaultValue: "Failed to submit response. Please try again.") }

        enum NextSteps {
            static var annualPhysical: String { AppLocalization.string("app.current.Schedule_an_exam_with_my_primary_care_provider_and_share_these_results", defaultValue: "Schedule an exam with my primary care provider and share these results") }
            static var biometricScreening: String { AppLocalization.string("app.current.Schedule_a_biometric_screening_or_other_follow_up_labs_i_e_HBA1c_for_blood_sugar", defaultValue: "Schedule a biometric screening or other follow-up labs (i.e. HBA1c for blood sugar)") }
            static var nutritionCounseling: String { AppLocalization.string("app.current.Get_support_from_a_Registered_Dietitian", defaultValue: "Get support from a Registered Dietitian") }
            static var ongoingMonitoring: String { AppLocalization.string("app.current.Continue_tracking_my_health_biomarkers_over_time_with_Hibiscus_Health_s_scans", defaultValue: "Continue tracking my health biomarkers over time with Hibiscus Health’s scans") }
        }
    }

    enum Metrics {
        static var interpretations: [String: [String: String]] { [
            "BP_CVD": [
                "very_low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_a_very_low_likelihood_of_a_heart_att", defaultValue: "Your screening suggests a very low likelihood of a heart attack or stroke in the next 10 years."),
                "low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_a_low_likelihood_of_a_heart_attack_o", defaultValue: "Your screening suggests a low likelihood of a heart attack or stroke in the next 10 years."),
                "moderate_low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_a_moderate_low_likelihood_of_a_heart", defaultValue: "Your screening suggests a moderate-low likelihood of a heart attack or stroke in the next 10 years."),
                "moderate": AppLocalization.string("app.current.Your_screening_suggests_a_moderate_likelihood_of_a_heart_attack_or_stroke_in_the_next_10_y", defaultValue: "Your screening suggests a moderate likelihood of a heart attack or stroke in the next 10 years. Follow-up with a healthcare professional is advised."),
                "high": AppLocalization.string("app.current.Your_screening_suggests_a_higher_likelihood_of_a_heart_attack_or_stroke_in_the_next_10_yea", defaultValue: "Your screening suggests a higher likelihood of a heart attack or stroke in the next 10 years. Follow-up with a healthcare professional is advised.")
            ],
            "BP_SYSTOLIC": [
                "low": AppLocalization.string("app.current.Your_screening_suggests_your_systolic_blood_pressure_may_be_lower_than_the_healthy_range_I", defaultValue: "Your screening suggests your systolic blood pressure may be lower than the healthy range. If it is persistently low, or if you experience symptoms,like fatigue, dizziness or blurred vision, follow-up with a healthcare professional is advised."),
                "healthy": AppLocalization.string("app.current.Your_screening_suggests_that_your_systolic_blood_pressure_is_within_a_healthy_range_Contin", defaultValue: "Your screening suggests that your systolic blood pressure is within a healthy range. Continue monitoring your health and making healthy lifestyle choices."),
                "slightly_high": AppLocalization.string("app.current.Your_screening_suggests_your_systolic_blood_pressure_may_be_slightly_higher_than_normal_Us", defaultValue: "Your screening suggests your systolic blood pressure may be slightly higher than normal. Usually, this is not a cause for concern, continue monitoring your health and  making healthy lifestyle choices. If your blood pressure is persistently elevated, or you experience symptoms, checking with a healthcare professional is advised."),
                "high": AppLocalization.string("app.current.Your_screening_suggests_your_systolic_blood_pressure_may_be_elevated_If_your_blood_pressur", defaultValue: "Your screening suggests your systolic blood pressure may be elevated. If your blood pressure is persistently elevated, or you experience symptoms such as blurred vision or dizziness, checking with a healthcare professional is advised."),
                "very_high": AppLocalization.string("app.current.Your_screening_suggests_your_systolic_blood_pressure_may_be_significantly_elevated_You_sho", defaultValue: "Your screening suggests your systolic blood pressure may be significantly elevated. You should sit for 5 minutes and recheck your blood pressure. Follow-up with a health professional is recommended if it is persistently elevated or if you experience any symptoms such as headaches, blurry vision, dizziness or difficulty breathing.")
            ],
            "BP_DIASTOLIC": [
                "low": AppLocalization.string("app.current.Your_screening_suggests_your_diastolic_blood_pressure_may_be_lower_than_the_healthy_range_", defaultValue: "Your screening suggests your diastolic blood pressure may be lower than the healthy range. If it is persistently low, or if you experience any symptoms like fatigue, dizziness or blurred vision, follow-up with a healthcare professional is advised."),
                "healthy": AppLocalization.string("app.current.Your_screening_suggests_your_diastolic_blood_pressure_is_within_a_healthy_range_Continue_m", defaultValue: "Your screening suggests your diastolic blood pressure is within a healthy range. Continue monitoring your health and making healthy lifestyle choices."),
                "high": AppLocalization.string("app.current.Your_screening_suggests_your_diastolic_blood_pressure_may_be_elevated_If_your_blood_pressu", defaultValue: "Your screening suggests your diastolic blood pressure may be elevated. If your blood pressure is persistently elevated, or you experience symptoms such as blurred vision or dizziness, checking with a healthcare professional is advised."),
                "very_high": AppLocalization.string("app.current.Your_screening_suggests_your_diastolic_blood_pressure_may_be_significantly_elevated_You_sh", defaultValue: "Your screening suggests your diastolic blood pressure may be significantly elevated. You should sit for 5 minutes and recheck your blood pressure. Follow-up with a health professional is recommended if it is persistently elevated or if you experience any symptoms such as headaches, blurry vision, dizziness or difficulty breathing.")
            ],
            "HR_BPM": [
                "low": AppLocalization.string("app.current.Your_screening_suggests_your_heart_rate_may_be_lower_than_the_typical_resting_range_If_you", defaultValue: "Your screening suggests your heart rate may be lower than the typical resting range. If your heart rate is persistently low, or if you experience any symptoms, follow up with your doctor is advised."),
                "normal": AppLocalization.string("app.current.Your_Screening_suggests_that_your_heart_rate_is_within_a_normal_resting_range", defaultValue: "Your Screening suggests that your heart rate is within a normal resting range."),
                "high": AppLocalization.string("app.current.Your_screening_suggests_your_heart_rate_may_be_higher_than_the_typical_resting_range_If_yo", defaultValue: "Your screening suggests your heart rate may be higher than the typical resting range. If your heart rate is persistently high, or if you experience any symptoms, follow up with your doctor is advised.")
            ],
            "HBA1C_RISK_PROB": [
                "very_low": AppLocalization.string("app.current.Your_screening_suggests_a_very_low_risk_for_A1c_levels_outside_the_healthy_range_Continue_", defaultValue: "Your screening suggests a very low risk for A1c levels outside the healthy range. Continue monitoring your health and making healthy lifestyle choices."),
                "low": AppLocalization.string("app.current.Your_screening_suggests_a_low_risk_for_A1c_levels_outside_the_healthy_range_Continue_monit", defaultValue: "Your screening suggests a low risk for A1c levels outside the healthy range. Continue monitoring your health and making healthy lifestyle choices."),
                "moderate": AppLocalization.string("app.current.Your_screening_suggests_a_medium_risk_for_A1c_levels_outside_the_healthy_range_Your_risk_a", defaultValue: "Your screening suggests a medium risk for A1c levels outside the healthy range. Your risk assessment should be monitored over time, consider periodic HbA1c monitoring."),
                "high": AppLocalization.string("app.current.Your_screening_suggests_an_elevated_risk_for_A1c_levels_outside_the_healthy_range_This_may", defaultValue: "Your screening suggests an elevated risk for A1c levels outside the healthy range. This may be associated with pre-diabetes or diabetes, and follow-up with a doctor is recommended."),
                "very_high": AppLocalization.string("app.current.Your_screening_suggests_a_greatly_elevated_risk_for_A1c_levels_outside_the_healthy_range_T", defaultValue: "Your screening suggests a greatly elevated risk for A1c levels outside the healthy range. This may be associated with pre-diabetes or diabetes, and follow-up with a doctor is recommended.")
            ],
            "HDLTC_RISK_PROB": [
                "very_low": AppLocalization.string("app.current.Your_screening_suggests_a_very_low_risk_for_Cholesterol_levels_outside_the_healthy_range_C", defaultValue: "Your screening suggests a very low risk for Cholesterol levels outside the healthy range. Continue monitoring your health and making healthy lifestyle choices."),
                "low": AppLocalization.string("app.current.Your_screening_suggests_a_low_risk_for_Cholesterol_levels_outside_the_healthy_range_Contin", defaultValue: "Your screening suggests a low risk for Cholesterol levels outside the healthy range. Continue monitoring your health and making healthy lifestyle choices."),
                "moderate": AppLocalization.string("app.current.Your_screening_suggests_a_medium_risk_for_Cholesterol_levels_outside_the_healthy_range_You", defaultValue: "Your screening suggests a medium risk for Cholesterol levels outside the healthy range. Your risk assessment should be monitored over time, consider periodic cholesterol monitoring."),
                "high": AppLocalization.string("app.current.Your_screening_suggests_an_elevated_risk_for_Cholesterol_levels_outside_the_healthy_range_", defaultValue: "Your screening suggests an elevated risk for Cholesterol levels outside the healthy range, follow-up with a doctor is recommended."),
                "very_high": AppLocalization.string("app.current.Your_screening_suggests_a_greatly_elevated_risk_for_Cholesterol_levels_outside_the_healthy", defaultValue: "Your screening suggests a greatly elevated risk for Cholesterol levels outside the healthy range, follow-up with a doctor is recommended.")
            ],
            "TG_RISK_PROB": [
                "very_low": AppLocalization.string("app.current.Your_screening_suggests_a_very_low_risk_for_Triglyceride_levels_outside_the_healthy_range_", defaultValue: "Your screening suggests a very low risk for Triglyceride levels outside the healthy range. Continue monitoring your health and making healthy lifestyle choices."),
                "low": AppLocalization.string("app.current.Your_screening_suggests_a_low_risk_for_Triglyceride_levels_outside_the_healthy_range_Conti", defaultValue: "Your screening suggests a low risk for Triglyceride levels outside the healthy range. Continue monitoring your health and making healthy lifestyle choices."),
                "moderate": AppLocalization.string("app.current.Your_screening_suggests_a_medium_risk_for_Triglyceride_levels_outside_the_healthy_range_Yo", defaultValue: "Your screening suggests a medium risk for Triglyceride levels outside the healthy range. Your risk assessment should be monitored over time, consider periodic cholesterol monitoring."),
                "high": AppLocalization.string("app.current.Your_screening_suggests_an_elevated_risk_for_Triglyceride_levels_outside_the_healthy_range", defaultValue: "Your screening suggests an elevated risk for Triglyceride levels outside the healthy range, follow-up with a doctor is recommended."),
                "very_high": AppLocalization.string("app.current.Your_screening_suggests_a_greatly_elevated_risk_for_Triglyceride_levels_outside_the_health", defaultValue: "Your screening suggests a greatly elevated risk for Triglyceride levels outside the healthy range, follow-up with a doctor is recommended.")
            ]
        ] }

        static func displayTitle(for key: String) -> String {
            switch key {
            case "BP_CVD": return AppLocalization.string("app.current.Adverse_Cardiovascular_Event_Risk", defaultValue: "Adverse Cardiovascular Event Risk")
            case "HR_BPM": return AppLocalization.string("app.ResultScreenStrings.Metrics.Heart_Rate_3", defaultValue: "Heart Rate")
            case "HBA1C_RISK_PROB": return AppLocalization.string("app.current.Diabetes_Prediabetes_Risk_HbA1c", defaultValue: "Diabetes/Prediabetes Risk (HbA1c)")
            case "BP_SYSTOLIC": return AppLocalization.string("app.ResultScreenStrings.Metrics.Systolic_Blood_Pressure_2", defaultValue: "Systolic Blood Pressure")
            case "BP_DIASTOLIC": return AppLocalization.string("app.ResultScreenStrings.Metrics.Diastolic_Blood_Pressure_2", defaultValue: "Diastolic Blood Pressure")
            case "HDLTC_RISK_PROB": return AppLocalization.string("app.current.Risk_of_High_Cholesterol", defaultValue: "Risk of High Cholesterol")
            case "TG_RISK_PROB": return AppLocalization.string("app.current.Risk_of_High_Triglycerides", defaultValue: "Risk of High Triglycerides")
            default: return key.replacingOccurrences(of: "_", with: " ")
            }
        }

        static func gridTitle(for key: String) -> String {
            switch key {
            case "BP_CVD": return AppLocalization.string("app.ResultScreenStrings.Metrics.Cardiovascular_Risk", defaultValue: "Cardiovascular Risk")
            case "HBA1C_RISK_PROB": return AppLocalization.string("app.ResultScreenStrings.Metrics.Hemoglobin_A1C_Risk", defaultValue: "Hemoglobin A1C Risk")
            case "HR_BPM": return AppLocalization.string("app.ResultScreenStrings.Metrics.Heart_Rate_3", defaultValue: "Heart Rate")
            default: return displayTitle(for: key)
            }
        }

        static func description(for key: String) -> String {
            switch key {
            case "BP_CVD": return AppLocalization.string("app.current.This_is_our_estimation_of_how_likely_you_are_to_experience_a_heart_attack_or_stroke_within", defaultValue: "This is our estimation of how likely you are to experience a heart attack or stroke within the next 10 years. This is based on signals from your face scan.")
            case "BP_SYSTOLIC": return AppLocalization.string("app.current.This_is_the_pressure_your_heart_creates_when_it_pumps_blood_out_Too_high_over_time_and_it_", defaultValue: "This is the pressure your heart creates when it pumps blood out. Too high over time and it puts extra strain on your blood vessels. A normal reading is usually around 90–120 mmHg.")
            case "BP_DIASTOLIC": return AppLocalization.string("app.current.This_is_the_pressure_in_your_blood_vessels_when_your_heart_is_resting_between_beats_A_norm", defaultValue: "This is the pressure in your blood vessels when your heart is resting between beats. A normal reading is usually around 60–80 mmHg.")
            case "HBA1C_RISK_PROB": return AppLocalization.string("app.current.This_is_our_estimation_of_your_long_term_blood_sugar_patterns_over_the_past_three_months_b", defaultValue: "This is our estimation of your long term blood sugar patterns over the past three months based on signals from your face scan. High blood sugar over time is linked to pre-diabetes and type 2 diabetes.")
            case "HDLTC_RISK_PROB": return AppLocalization.string("app.current.This_is_our_estimation_of_how_likely_you_are_to_have_high_cholesterol_levels_based_on_sign", defaultValue: "This is our estimation of how likely you are to have high cholesterol levels based on signals from your face scan. Too much cholesterol in your blood can clog your blood vessels over time.")
            case "TG_RISK_PROB": return AppLocalization.string("app.current.This_is_our_estimation_of_how_likely_you_are_to_have_high_triglyceride_levels_based_on_sig", defaultValue: "This is our estimation of how likely you are to have high triglyceride levels based on signals from your face scan. Triglycerides are the most common type of fat in your body. Having too much of them can increase your risk of heart disease and stroke.")
            case "HR_BPM": return AppLocalization.string("app.current.This_is_how_many_times_your_heart_beats_per_minute_during_your_scan_Most_healthy_adults_ar", defaultValue: "This is how many times your heart beats per minute during your scan. Most healthy adults are between 60 and 100 beats per minute (BPM) when resting. If this is too high or too low consistently, it is something to discuss with your doctor.")
            default: return ""
            }
        }
    }
}


enum ScreenSaverStrings {
    static var landscapeTitle: String { AppLocalization.string("app.ScreenSaverStrings.Welcome_to_the_Hibiscus_Health_Kiosk", defaultValue: "Welcome to the Hibiscus Health Kiosk!") }
    static var landscapeSubtitle: String { AppLocalization.string("app.current.30_second_face_scan_that_identifies_health_risk_before_during_and_between_visits", defaultValue: "30-second face scan that identifies health risk before, during, and between visits.") }
    static var landscapeActionButton: String { AppLocalization.string("app.ScreenSaverStrings.Start_Face_Scan", defaultValue: "Start Face Scan") }
    static var landscapeCompanyLogo: String { AppLocalization.string("app.current.PUT_YOUR_LOGO_HERE", defaultValue: "PUT YOUR\nLOGO HERE") }
    static var loading: String { AppLocalization.string("app.HomeScreenStrings.ReadSection.Loading", defaultValue: "Loading...") }
    static var title: String { AppLocalization.string("app.current.Welcome_to_the_Hibiscus_Wellness_Kiosk", defaultValue: "Welcome to the Hibiscus Wellness Kiosk!") }
    static var subtitle: String { AppLocalization.string("app.current.Take_a_few_minutes_to_check_in_on_your_health", defaultValue: "Take a few minutes to check in on your health.") }
    static var actionButton: String { AppLocalization.string("app.current.Start_Your_Health_Journey", defaultValue: "Start Your Health Journey") }
    static var qrPrompt: String { AppLocalization.string("app.current.Scan_to_try_it_on_your_smartphone", defaultValue: "Scan to try it on your smartphone!") }
}


enum SharedViewStrings {
    enum Toolbar {
        static var companyLogoPlaceholder: String { AppLocalization.string("app.SharedViewStrings.Toolbar.PUT_YOUR_COMPANY_LOGO_HERE", defaultValue: "PUT YOUR COMPANY\nLOGO HERE") }
        static var resultPartnerLogoPlaceholder: String { AppLocalization.string("app.current.Partner_logo_goes_here", defaultValue: "Partner logo\ngoes here") }
    }

    enum WebView {
        static var faceScanDemoTitle: String { AppLocalization.string("app.SharedViewStrings.WebView.Face_Scan_Demo", defaultValue: "Face Scan Demo") }
        static var doneButtonTitle: String { AppLocalization.string("app.SharedViewStrings.WebView.Done", defaultValue: "Done") }
    }
}
