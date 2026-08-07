# Sanad Customer Mobile Walkthrough

Use this checklist for customer mobile QA after the debug build is installed on a device or emulator and the API base URL points to the Sanad UAT backend.

## Setup

| Item | Expected Result |
| --- | --- |
| App name | The installed app label shows Sanad |
| API URL | App points to the selected Sanad UAT API |
| Customer account | Customer can sign in with the provided UAT customer credentials |

## Customer Flow

| Step | Expected Result |
| --- | --- |
| Open customer dashboard | Dashboard loads without Kangoo branding |
| Open My Sanad | Sanad customer screen opens from profile navigation |
| Load Sanad foundation | App receives lifecycle, terminology, privacy, and AI metadata |
| View request list | Customer sees only their own Sanad requests |
| Open request detail | Request status, stage, payment, documents, Buzz, and chat context are visible where available |
| Review partner privacy | Direct provider/employee profile navigation is not exposed to the customer |
| Review service detail | Service detail keeps Sanad coordination wording and does not expose direct partner contact controls |
| Review request communication | Customer can use Sanad-controlled request chat/support flow |
| Review payment/invoice context | Customer sees only their own payment/invoice context |
| Review legacy terminology | Visible screens do not show Kangoo, Handyman, Provider marketplace, or Post Job terminology |

## Sign-Off

| Area | Result | Notes |
| --- | --- | --- |
| Customer login | Pending |  |
| Customer request visibility | Pending |  |
| Document/payment/chat visibility | Pending |  |
| Partner privacy | Pending |  |
| Final customer mobile acceptance | Pending |  |
