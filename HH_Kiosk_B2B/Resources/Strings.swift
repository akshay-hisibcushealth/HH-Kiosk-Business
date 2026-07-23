import Foundation

enum HomeScreenStrings {
    static var responseReceivedToast: String { AppLocalization.string("app.HomeScreenStrings.Response_Received", defaultValue: "Response Received") }

    enum Weather {
        static var loading: String { AppLocalization.string("app.HomeScreenStrings.Weather.Loading_Weather", defaultValue: "Loading Weather...") }
        static var errorTitle: String { AppLocalization.string("app.HomeScreenStrings.Weather.Error", defaultValue: "Error:") }
        static var fetchingLocation: String { AppLocalization.string("app.HomeScreenStrings.Weather.Fetching_location", defaultValue: "Fetching location...") }
        static var welcomePrefix: String { AppLocalization.string("app.HomeScreenStrings.Weather.Welcome_to_the", defaultValue: "Welcome to the") }
        static var companyName: String { AppLocalization.string("app.HomeScreenStrings.Weather.ABC_Company", defaultValue: "[ABC Company]") }
        static var kioskSuffix: String { AppLocalization.string("app.HomeScreenStrings.Weather.Kiosk", defaultValue: "Kiosk") }
        static func highLow(high: Int, low: Int) -> String {
            AppLocalization.format("app.HomeScreenStrings.Weather.highLow", defaultValue: "H:%d°F  L:%d°F", high, low)
        }
    }

    enum Promo {
        static var title: String { AppLocalization.string("app.HomeScreenStrings.Promo.Curious_About_Your_Health", defaultValue: "Curious About Your Health?") }
        static var subtitle: String { AppLocalization.string("app.HomeScreenStrings.Promo.Start_with_a_30_seconds_Face_Scan", defaultValue: "Start with a 30 seconds Face Scan") }
        static var demoButtonTitle: String { AppLocalization.string("app.HomeScreenStrings.Promo.Watch_Quick_Demo", defaultValue: "Watch Quick Demo") }
        static var tryFaceScan: String { AppLocalization.string("app.HomeScreenStrings.Promo.Try_Face_Scan", defaultValue: "Try Face Scan") }
        static let demoURL = "https://www.youtube.com/watch?v=2K4os2Rt81Q"
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
            (AppLocalization.string("app.HomeScreenStrings.Schedule.Quarterly_Town_Hall_Meeting", defaultValue: "Quarterly Town Hall Meeting"), AppLocalization.string("app.HomeScreenStrings.Schedule.To_discuss_about_the_upcoming_project_organization_of_units", defaultValue: "To discuss about the upcoming project & organization of units")),
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
    static var privacyProtectedPrefix: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Your_privacy_is_protected", defaultValue: "Your privacy is protected.") }
    static var privacyMessage: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.We_value_your_privacy_Your_information_will_NOT_be_shared_ex", defaultValue: "We value your privacy. Your information will NOT be shared externally.") }
    static var watchQuickDemo: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Watch_Demo", defaultValue: "Watch Demo") }
    static var proceedToScan: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Proceed_to_Scan", defaultValue: "Proceed to Scan") }
    #if DEBUG
    static var debugProceedToResults: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Skip_to_Results", defaultValue: "Skip to Results") }
    #endif
    static var alertDismiss: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.OK", defaultValue: "OK") }

    enum Validation {
        static var missingEmail: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Please_enter_your_email", defaultValue: "Please enter your email.") }
        static var invalidEmail: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Please_enter_a_valid_email", defaultValue: "Please enter a valid email.") }
        static var missingHeight: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Please_select_your_height", defaultValue: "Please select your height.") }
        static var missingWeight: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Weight_cannot_be_empty", defaultValue: "Weight cannot be empty.") }
        static var invalidWeight: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Weight_cannot_be_less_than_75_lbs", defaultValue: "Weight cannot be less than 75 lbs.") }
        static var missingAge: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Please_enter_your_age", defaultValue: "Please enter your age.") }
        static var invalidAge: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Age_must_be_between_13_and_120_years", defaultValue: "Age must be between 13 and 120 years.") }
        static var missingGender: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Validation.Please_select_your_gender", defaultValue: "Please select your gender.") }
    }

    enum Form {
        static var emailLabel: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Email", defaultValue: "Email") }
        static var emailPlaceholder: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Enter_email", defaultValue: "Enter email") }
        static var emailInlineError: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Enter_a_valid_email_address", defaultValue: "Enter a valid email address") }
        static var ageLabel: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Age", defaultValue: "Age") }
        static var agePlaceholder: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.How_old_are_you", defaultValue: "How old are you?") }
        static var heightLabel: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Height", defaultValue: "Height") }
        static var heightPlaceholder: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Feet_Inches", defaultValue: "Feet / Inches") }
        static var heightSheetTitle: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Select_Height", defaultValue: "Select Height") }
        static var feetUnit: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.ft", defaultValue: "ft") }
        static var inchesUnit: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.in", defaultValue: "in") }
        static var confirmButton: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.CONFIRM", defaultValue: "CONFIRM") }
        static var doneButton: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Done", defaultValue: "Done") }
        static var weightLabel: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Weight", defaultValue: "Weight") }
        static var weightPlaceholder: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Lbs", defaultValue: "Lbs") }
        static var genderLabel: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Sex_at_birth", defaultValue: "Sex (at birth)") }
        static var male: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Male", defaultValue: "Male") }
        static var female: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Female", defaultValue: "Female") }
        static var genderOptions: [String] { [AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Male", defaultValue: "Male"), AppLocalization.string("app.PhysicalAttributesScreenStrings.Form.Female", defaultValue: "Female")] }
    }

    enum EditMenu {
        static var cut: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Cut", defaultValue: "Cut") }
        static var copy: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Copy", defaultValue: "Copy") }
        static var paste: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Paste", defaultValue: "Paste") }
        static var select: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Select", defaultValue: "Select") }
        static var selectAll: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Select_All", defaultValue: "Select All") }
        static var delete: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Delete", defaultValue: "Delete") }
        static var autoFill: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.AutoFill", defaultValue: "AutoFill") }
        static var replace: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Replace", defaultValue: "Replace…") }
        static var lookUp: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Look_Up", defaultValue: "Look Up") }
        static var translate: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Translate", defaultValue: "Translate") }
        static var scanText: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Scan_Text", defaultValue: "Scan Text") }
        static var writingTools: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Writing_Tools", defaultValue: "Writing Tools") }
        static var email: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.EditMenu.Email", defaultValue: "Email") }
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

    enum Debug {
        static var fillDummyData: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Debug.Fill_Dummy_Data", defaultValue: "Fill Dummy Data") }
        static var submitScanAPI: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Debug.Submit_Debug_Scan_API", defaultValue: "Submit Debug Scan API") }
        static var scanAPISubmitted: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Debug.Debug_scan_API_submitted_successfully", defaultValue: "Debug scan API submitted successfully.") }
        static var scanAPIFailed: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Debug.Failed_to_submit_debug_scan_API", defaultValue: "Failed to submit debug scan API.") }
        static var unableToOpenResults: String { AppLocalization.string("app.PhysicalAttributesScreenStrings.Debug.Unable_to_open_results_screen", defaultValue: "Unable to open results screen.") }
    }
}


enum ReadPdfScreenStrings {
    static var loading: String { AppLocalization.string("app.ReadPdfScreenStrings.Loading_PDF", defaultValue: "Loading PDF...") }
    static var failedToLoad: String { AppLocalization.string("app.ReadPdfScreenStrings.Failed_to_load_PDF", defaultValue: "Failed to load PDF") }
}


enum ResultScreenStrings {
    static let pdfFileName = "Hibiscus_Health_Report"
    static var title: String { AppLocalization.string("app.ResultScreenStrings.Great_job_taking_a_proactive_step_for_your_health", defaultValue: "Great job taking a proactive step for your health!") }
    static var heroTitle: String { AppLocalization.string("app.ResultScreenStrings.Great_job_taking_a_proactive_step_for_your_health_2", defaultValue: "Great job taking a proactive step\nfor your health!") }
    static var heroDescription: String { AppLocalization.string("app.ResultScreenStrings.Below_is_a_summary_of_your_key_biomarkers_based_on_your_30_s", defaultValue: "Below is a summary of your key biomarkers based on your 30-second scan.") }
    static var titleBlockDescription: String { AppLocalization.string("app.ResultScreenStrings.This_report_is_intended_to_improve_your_awareness_of_general", defaultValue: "This report is intended to improve your awareness of general wellness. It is not a substitute for the clinical judgment of a health care professional.  These results provide a non-diagnostic screening to help you understand your current wellness trends.") }
    static var infoFooter: String { AppLocalization.string("app.ResultScreenStrings.Hibiscus_Health_is_intended_to_improve_your_awareness_of_gen", defaultValue: "Hibiscus Health is intended to improve your awareness of general wellness. Hibiscus Health does not diagnose, treat, mitigate or prevent any disease, symptom, disorder or abnormal physical state. Consult with a healthcare professional or emergency services if you believe you may have a medical issue.") }
    static var privacyMessage: String { AppLocalization.string("app.ResultScreenStrings.The_results_from_this_face_scan_are_not_intended_to_diagnose", defaultValue: "The results from this face scan are not intended to diagnose, treat, or replace professional medical advice. For any health concerns, please consult a healthcare provider.") }

    enum Actions {
        static var emailResults: String { AppLocalization.string("app.ResultScreenStrings.Actions.Email_Results", defaultValue: "Email Results") }
        static var back: String { AppLocalization.string("app.ResultScreenStrings.Actions.Back", defaultValue: "Back") }
        static var viewNextSteps: String { AppLocalization.string("app.ResultScreenStrings.Actions.View_Next_Steps", defaultValue: "View Next Steps") }
    }

    enum Status {
        static var measurementFailed: String { AppLocalization.string("app.ResultScreenStrings.Status.Measurement_failed", defaultValue: "Measurement failed") }
        static var unableToLoadResults: String { AppLocalization.string("app.ResultScreenStrings.Status.Unable_to_load_results_Please_try_again", defaultValue: "Unable to load results. Please try again.") }
        static var exit: String { AppLocalization.string("app.ResultScreenStrings.Status.Exit", defaultValue: "Exit") }
        static func loading(currentChunk: Int, totalChunks: Int) -> String {
            AppLocalization.format("app.ResultScreenStrings.Status.loading", defaultValue: "Loading (%d of %d)", currentChunk + 1, totalChunks)
        }
    }

    enum Print {
        static var errorTitle: String { AppLocalization.string("app.ResultScreenStrings.Print.Error", defaultValue: "Error") }
        static var ok: String { AppLocalization.string("app.ResultScreenStrings.Print.OK", defaultValue: "OK") }
        static var renderFailed: String { AppLocalization.string("app.ResultScreenStrings.Print.Failed_to_render_results_for_printing", defaultValue: "Failed to render results for printing.") }
        static var generatePDFFailed: String { AppLocalization.string("app.ResultScreenStrings.Print.Failed_to_generate_PDF_for_printing", defaultValue: "Failed to generate PDF for printing.") }
        static var jobName: String { AppLocalization.string("app.ResultScreenStrings.Print.Health_Report", defaultValue: "Health Report") }
        static let exportFileName = "HealthReport"
        static let fileName = "HealthReport_Print.pdf"
    }

    enum EmailPopup {
        static var title: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.Send_result_to_your_mail", defaultValue: "Email me my results") }
        static var subtitle: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.We_ll_send_a_secure_link", defaultValue: "We’ll send a secure link. Your 4-digit PIN\nunlocks the results, only you can open them") }
        static var emailAddress: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.Email_address", defaultValue: "Email address") }
        static var emailPlaceholder: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.Email", defaultValue: "Email") }
        static var pinTitle: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.Create_a_4_digit_secret_key", defaultValue: "Create a 4-digit PIN (used to open your report)") }
        static let pinPlaceholder = "* * * *"
        static var pinHelp: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.This_will_be_used_to_view_your_result", defaultValue: "This will be used to view your result") }
        static var sendMail: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.Send_mail", defaultValue: "Send my results") }
        static var emailFailure: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.Failed_to_send_email_Please_try_again", defaultValue: "Failed to send email. Please try again.") }
        static var secureAndPrivate: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.Secure_and_Private", defaultValue: "Secure and Private") }
        static var checkInboxTitle: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.Check_your_inbox", defaultValue: "Check your inbox!") }
        static var emailSentMessage: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.Your_result_has_been_sent_to_your_email_Tell_a_colleague_abo", defaultValue: "Your result has been sent to your email!\nTell a colleague about our Kiosk!") }
        static var done: String { AppLocalization.string("app.ResultScreenStrings.EmailPopup.Done", defaultValue: "Done") }
    }

    enum PostSession {
        static var continueTitle: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Continue", defaultValue: "Continue") }
        static var allDoneTitle: String { AppLocalization.string("app.ResultScreenStrings.PostSession.All_done_Thank_you_for_visiting_our_kiosk", defaultValue: "All done.\nThank you for visiting our kiosk!") }
        static var npsEyebrow: String { AppLocalization.string("app.ResultScreenStrings.PostSession.ONE_QUICK_QUESTION", defaultValue: "ONE QUICK QUESTION") }
        static var npsQuestion: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Would_you_recommend_this_experience_to_others", defaultValue: "Would you recommend this experience to others?") }
        static var notLikely: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Not_at_all_likely", defaultValue: "Not at all likely") }
        static var extremelyLikely: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Extremely_likely", defaultValue: "Extremely likely") }
        static var skip: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Skip", defaultValue: "Skip") }
        static var submitAndReturnHome: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Submit_and_return_home", defaultValue: "Submit and return home") }
        static var submitFailure: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Failed_to_submit_response_Please_try_again", defaultValue: "Failed to submit response. Please try again.") }

        enum Survey {
            static var healthCheckTitle: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Thank_you_for_taking_the_time_to_complete_this_important_sca", defaultValue: "Thank you for taking the time to complete this important scan") }
            static var healthCheckQuestion: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.When_did_you_last_have_your_blood_pressure_heart_or_blood_su", defaultValue: "When did you last have your blood pressure, heart, or blood sugar checked by a health professional?") }
            static var withinSixMonths: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Within_6_months", defaultValue: "Within 6 months") }
            static var sixToTwelveMonthsAgo: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.6_to_12_months_ago", defaultValue: "6 to 12 months ago") }
            static var moreThanAYearAgo: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.More_than_a_year_ago", defaultValue: "More than a year ago") }
            static var neverOrNotSure: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Never_or_not_sure", defaultValue: "Never, or not sure") }

            static var anythingNewTitle: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Anything_new", defaultValue: "Anything new?") }
            static var anythingNewQuestion: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Did_your_scan_tell_you_anything_new_about_your_health", defaultValue: "Did your scan tell you anything new about your health?") }
            static var yesSurprisedMe: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Yes_it_surprised_me", defaultValue: "Yes, it surprised me") }
            static var somewhatNew: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Somewhat_new_to_me", defaultValue: "Somewhat new to me") }
            static var noExpected: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.No_about_what_I_expected", defaultValue: "No, about what I expected") }

            static var nextStepQuestion: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.What_will_you_do_based_on_your_results_select_all_that_apply", defaultValue: "What will you do based on your results? (select all that apply)") }
            static var schedulePrimaryCareExam: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Schedule_an_exam_with_my_primary_care_provider", defaultValue: "Schedule an exam with my primary care provider and share these results") }
            static var doctorVisitBooked: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Already_have_a_doctor_s_visit_booked", defaultValue: "Already have a doctor's visit booked") }
            static var mentionDentist: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Mention_it_to_my_dentist_today", defaultValue: "Mention it to my dentist today") }
            static var dietitianSupport: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Get_support_from_a_Registered_Dietitian", defaultValue: "Get support from a Registered Dietitian") }
            static var continueTracking: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Continue_tracking_my_health_biomarkers", defaultValue: "Continue tracking my health biomarkers over time with Hibiscus Health’s scans") }

            static var stayInTouchTitle: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Stay_in_touch", defaultValue: "Stay in touch") }
            static var stayInTouchQuestion: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Can_we_check_in_with_you_in_a_few_weeks_to_see_how_you_are_d", defaultValue: "Can we check in with you in a few weeks to see how you are doing?") }
            static var yes: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.Yes", defaultValue: "Yes") }
            static var no: String { AppLocalization.string("app.ResultScreenStrings.PostSession.Survey.No", defaultValue: "No") }
        }
        
    }

    enum Metrics {
        static var interpretations: [String: [String: String]] { [
            "BP_CVD": [
                "very_low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_a_very_low_likelihood_of_a_heart_att", defaultValue: "Your screening suggests a very low likelihood of a heart attack or stroke in the next 10 years."),
                "low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_a_low_likelihood_of_a_heart_attack_o", defaultValue: "Your screening suggests a low likelihood of a heart attack or stroke in the next 10 years."),
                "moderate_low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_a_moderate_low_likelihood_of_a_heart", defaultValue: "Your screening suggests a moderate-low likelihood of a heart attack or stroke in the next 10 years."),
                "moderate": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_a_moderate_likelihood_of_a_heart_att", defaultValue: "Your screening suggests a moderate likelihood of a heart attack or stroke in the next 10 years."),
                "high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_a_higher_likelihood_of_a_heart_attac", defaultValue: "Your screening suggests a higher likelihood of a heart attack or stroke in the next 10 years.")
            ],
            "BP_SYSTOLIC": [
                "healthy": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_systolic_blood_pressure_is_with", defaultValue: "Your screening suggests your systolic blood pressure is within a healthy range."),
                "low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_systolic_blood_pressure_may_be", defaultValue: "Your screening suggests your systolic blood pressure may be lower than the healthy range."),
                "slightly_high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_systolic_blood_pressure_may_be_2", defaultValue: "Your screening suggests your systolic blood pressure may be slightly above the healthy range."),
                "high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_systolic_blood_pressure_may_be_3", defaultValue: "Your screening suggests your systolic blood pressure may be significantly elevated.")
            ],
            "BP_DIASTOLIC": [
                "healthy": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_diastolic_blood_pressure_is_wit", defaultValue: "Your screening suggests your diastolic blood pressure is within a healthy range."),
                "low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_diastolic_blood_pressure_may_be", defaultValue: "Your screening suggests your diastolic blood pressure may be lower than the healthy range."),
                "slightly_low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_diastolic_blood_pressure_may_be_2", defaultValue: "Your screening suggests your diastolic blood pressure may be slightly lower the healthy range."),
                "slightly_high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_diastolic_blood_pressure_may_be_3", defaultValue: "Your screening suggests your diastolic blood pressure may be slightly above the healthy range."),
                "high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_diastolic_blood_pressure_may_be_4", defaultValue: "Your screening suggests your diastolic blood pressure may be significantly elevated.")
            ],
            "HR_BPM": [
                "low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_heart_rate_is_below_a_normal_re", defaultValue: "Your screening suggests your heart rate is below a normal resting range."),
                "normal": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_heart_rate_is_within_a_normal_r", defaultValue: "Your screening suggests your heart rate is within a normal resting range."),
                "high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_heart_rate_is_higher_than_the_t", defaultValue: "Your screening suggests your heart rate is higher than the typical resting range.")
            ],
            "HBA1C_RISK_PROB": [
                "very_low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_HbA1c_markers_are_within_a_heal", defaultValue: "Your screening suggests your HbA1c markers are within a healthy, stable range."),
                "low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_HbA1c_is_likely_below_the_thres", defaultValue: "Your screening suggests your HbA1c is likely below the threshold for concern."),
                "moderate": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_slightly_elevated_glycemic_markers_c", defaultValue: "Your screening suggests your HbA1c (blood sugar level) markers are slightly elevated compared to the ideal range."),
                "high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_that_your_blood_sugar_levels_are_cur", defaultValue: "Your screening suggests that your blood sugar levels are currently above the standard healthy range."),
                "very_high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_blood_sugar_markers_that_are_notably", defaultValue: "Your screening suggests blood sugar markers that are notably above the standard healthy range.")
            ],
            "HDLTC_RISK_PROB": [
                "very_low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_a_very_low_probability_of_elevated_c", defaultValue: "Your screening suggests a very low probability of elevated cholesterol levels."),
                "low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_cholesterol_markers_are_within", defaultValue: "Your screening suggests your cholesterol markers are within a standard, low-risk profile."),
                "moderate": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_cholesterol_markers_are_current", defaultValue: "Your screening suggests your cholesterol levels are within a moderate risk range."),
                "high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_cholesterol_levels_are_currently_abo", defaultValue: "Your screening suggests cholesterol levels are currently above the recommended healthy threshold."),
                "very_high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_indicators_consistent_with_a_high_co", defaultValue: "Your screening suggests indicators consistent with a high concentration of cholesterol in the blood.")
            ],
            "TG_RISK_PROB": [
                "very_low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_a_very_low_probability_of_elevated_t", defaultValue: "Your screening suggests a very low probability of elevated triglyceride levels."),
                "low": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_triglyceride_markers_are_within", defaultValue: "Your screening suggests your triglyceride markers are within a standard, low-risk profile."),
                "moderate": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_your_triglyceride_markers_are_curren", defaultValue: "Your screening suggests your triglyceride levels are within a moderate risk range."),
                "high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_triglyceride_levels_are_currently_ab", defaultValue: "Your screening suggests triglyceride levels are currently above the recommended healthy threshold."),
                "very_high": AppLocalization.string("app.ResultScreenStrings.Metrics.Your_screening_suggests_indicators_consistent_with_a_high_co_2", defaultValue: "Your screening suggests indicators consistent with a high concentration of triglyceride in the blood.")
            ]
        ] }

        static func displayTitle(for key: String) -> String {
            switch key {
            case "BP_CVD": return AppLocalization.string("app.ResultScreenStrings.Metrics.Cardiovascular_Disease_Risk_2", defaultValue: "Adverse Cardiovascular Event Risk")
            case "HR_BPM": return AppLocalization.string("app.ResultScreenStrings.Metrics.Heart_Rate_2", defaultValue: "Heart Rate")
            case "HBA1C_RISK_PROB": return AppLocalization.string("app.ResultScreenStrings.Metrics.HbA1c_Risk_2", defaultValue: "Diabetes/Prediabetes Risk (HbA1c)")
            case "BP_SYSTOLIC": return AppLocalization.string("app.ResultScreenStrings.Metrics.Systolic_Blood_Pressure_2", defaultValue: "Systolic Blood Pressure")
            case "BP_DIASTOLIC": return AppLocalization.string("app.ResultScreenStrings.Metrics.Diastolic_Blood_Pressure_2", defaultValue: "Diastolic Blood Pressure")
            case "HDLTC_RISK_PROB": return AppLocalization.string("app.ResultScreenStrings.Metrics.High_Risk_of_Cholesterol_2", defaultValue: "Risk of High Cholesterol")
            case "TG_RISK_PROB": return AppLocalization.string("app.ResultScreenStrings.Metrics.High_Risk_of_Triglycerides_2", defaultValue: "Risk of High Triglycerides")
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
            case "BP_CVD": return AppLocalization.string("app.ResultScreenStrings.Metrics.Think_of_this_as_your_heart_s_10_year_weather_forecast_It_es", defaultValue: "This is our estimation of how likely you are to experience a heart attack or stroke within the next 10 years. This is based on signals from your face scan.")
            case "BP_SYSTOLIC": return AppLocalization.string("app.ResultScreenStrings.Metrics.This_is_the_pressure_your_heart_creates_when_it_pumps_blood", defaultValue: "This is the pressure your heart creates when it pumps blood out. Too high over time and it puts extra strain on your blood vessels. A normal reading is usually around 90–120 mmHg.")
            case "BP_DIASTOLIC": return AppLocalization.string("app.ResultScreenStrings.Metrics.This_is_the_pressure_in_your_arteries_when_your_heart_is_res", defaultValue: "This is the pressure in your blood vessels when your heart is resting between beats. A normal reading is usually around 60–80 mmHg.")
            case "HBA1C_RISK_PROB": return AppLocalization.string("app.ResultScreenStrings.Metrics.This_gives_you_a_sense_of_your_long_term_blood_sugar_pattern", defaultValue: "This is our estimation of your long term blood sugar patterns over the past three months based on signals from your face scan. High blood sugar over time is linked to pre-diabetes and type 2 diabetes.")
            case "HDLTC_RISK_PROB": return AppLocalization.string("app.ResultScreenStrings.Metrics.Too_much_cholesterol_in_your_blood_can_quietly_clog_your_art", defaultValue: "This is our estimation of how likely you are to have high cholesterol levels based on signals from your face scan. Too much cholesterol in your blood can clog your blood vessels over time.")
            case "TG_RISK_PROB": return AppLocalization.string("app.ResultScreenStrings.Metrics.Triglycerides_are_a_type_of_fat_your_body_stores_for_energy", defaultValue: "This is our estimation of how likely you are to have high triglyceride levels based on signals from your face scan. Triglycerides are the most common type of fat in your body. Having too much of them can increase your risk of heart disease and stroke.")
            case "HR_BPM": return AppLocalization.string("app.ResultScreenStrings.Metrics.How_many_times_your_heart_beats_in_a_minute_Most_healthy_adu", defaultValue: "This is how many times your heart beats per minute during your scan. Most healthy adults are between 60 and 100 beats per minute (BPM) when resting. If this is too high or too low consistently, it is something to discuss with your doctor.")
            default: return ""
            }
        }
    }
}


enum ScreenSaverStrings {
    static var title: String { AppLocalization.string("app.ScreenSaverStrings.Welcome_to_the_Hibiscus_Health_Kiosk", defaultValue: "Welcome to the Hibiscus Health Kiosk!") }
    static var subtitle: String { AppLocalization.string("app.ScreenSaverStrings.30_second_face_scan_that_identifies_health_risk_before_durin", defaultValue: "30-second face scan that identifies health risk\nbefore, during, and between visits.") }
    static var actionButton: String { AppLocalization.string("app.ScreenSaverStrings.Start_Face_Scan", defaultValue: "Start Face Scan") }
}


enum AnuraMeasurementStrings {
    static var missingLicenseConfiguration: String { AppLocalization.string("app.AnuraMeasurementStrings.You_must_provide_a_license_key_and_study_ID_to_use_this_app", defaultValue: "You must provide a license key and study ID to use this app") }

    enum Alert {
        static var tokenErrorTitle: String { AppLocalization.string("app.AnuraMeasurementStrings.Alert.Token_Error", defaultValue: "Token Error") }
        static var tokenErrorMessage: String { AppLocalization.string("app.AnuraMeasurementStrings.Alert.There_was_an_error_in_verifying_your_DeepAffex_token_Please", defaultValue: "There was an error in verifying your DeepAffex token. Please check the error log or contact support.") }
        static var licenseErrorTitle: String { AppLocalization.string("app.AnuraMeasurementStrings.Alert.License_Error", defaultValue: "License Error") }
        static var licenseErrorMessage: String { AppLocalization.string("app.AnuraMeasurementStrings.Alert.There_was_an_error_registering_your_DeepAffex_license_key_Pl", defaultValue: "There was an error registering your DeepAffex license key. Please check the error log or contact support.") }
        static var sdkConfigurationErrorTitle: String { AppLocalization.string("app.AnuraMeasurementStrings.Alert.SDK_Configuration_File_Error", defaultValue: "SDK Configuration File Error") }
        static var sdkConfigurationErrorMessage: String { AppLocalization.string("app.AnuraMeasurementStrings.Alert.There_was_an_error_retreiving_the_SDK_configuration_file_Ple", defaultValue: "There was an error retreiving the SDK configuration file. Please check the error log or contact support.") }
        static var cameraPermissionTitle: String { AppLocalization.string("app.AnuraMeasurementStrings.Alert.No_Camera_Permission", defaultValue: "No Camera Permission") }
        static var cameraPermissionMessage: String { AppLocalization.string("app.AnuraMeasurementStrings.Alert.Please_grant_the_app_access_to_the_camera_before_starting_a", defaultValue: "Please grant the app access to the camera before starting a measurement") }
    }

    enum Banner {
        static var initialPrompt: String { AppLocalization.string("app.AnuraMeasurementStrings.Banner.Center_Your_Face", defaultValue: "Center Your Face") }
        static var holdStill: String { AppLocalization.string("app.AnuraMeasurementStrings.Banner.Hold_Still", defaultValue: "Hold Still") }
        static var moveCloser: String { AppLocalization.string("app.AnuraMeasurementStrings.Banner.Move_Closer", defaultValue: "Move Closer") }
        static var moveFurther: String { AppLocalization.string("app.AnuraMeasurementStrings.Banner.Move_Further", defaultValue: "Move Further") }
        static var faceCamera: String { AppLocalization.string("app.AnuraMeasurementStrings.Banner.Look_Directly_at_the_Camera", defaultValue: "Look Directly at the Camera") }
        static var timeline: [(offset: TimeInterval, message: String)] { [
            (0, AppLocalization.string("app.AnuraMeasurementStrings.Banner.Breathe_Naturally_and_Stay_Still", defaultValue: "Breathe Naturally and Stay Still")),
            (5, AppLocalization.string("app.AnuraMeasurementStrings.Banner.Reading_Your_Pulse_from_Facial_Blood_Flow", defaultValue: "Reading Your Pulse from Facial Blood Flow")),
            (10, AppLocalization.string("app.AnuraMeasurementStrings.Banner.Detecting_Cardiovascular_Patterns", defaultValue: "Detecting Cardiovascular Patterns...")),
            (16, AppLocalization.string("app.AnuraMeasurementStrings.Banner.Halfway_Eyes_on_the_Camera", defaultValue: "Halfway - Eyes on the Camera")),
            (21, AppLocalization.string("app.AnuraMeasurementStrings.Banner.Capturing_Your_Final_Readings", defaultValue: "Capturing Your Final Readings...")),
            (25, AppLocalization.string("app.AnuraMeasurementStrings.Banner.Almost_There_Don_t_Move", defaultValue: "Almost There, Don't Move")),
            (28, AppLocalization.string("app.AnuraMeasurementStrings.Banner.Last_Few_Seconds", defaultValue: "Last Few Seconds..."))
        ] }
    }
}


enum SharedViewStrings {
    enum Toolbar {
        static var companyLogoPlaceholder: String { AppLocalization.string("app.SharedViewStrings.Toolbar.PUT_YOUR_COMPANY_LOGO_HERE", defaultValue: "PUT YOUR\nLOGO HERE") }
    }

    enum WebView {
        static var faceScanDemoTitle: String { AppLocalization.string("app.SharedViewStrings.WebView.Face_Scan_Demo", defaultValue: "Face Scan Demo") }
        static var doneButtonTitle: String { AppLocalization.string("app.SharedViewStrings.WebView.Done", defaultValue: "Done") }
    }
}
