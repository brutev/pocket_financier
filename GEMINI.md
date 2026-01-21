# Pocket Financier Analysis

## 1. THE CORE USE CASE
This is a **Fintech** application focused on personal finance management. Its primary function is to automatically track a user's income and expenses by parsing transaction data from banking SMS messages directly on their device.

## 2. USER NEEDS
Based on the app's structure, the primary user journeys are:
- **Automated Transaction Logging:** The user grants SMS permissions, and the app automatically reads, parses, and categorizes their financial transactions without manual entry.
- **Financial Overview & Analysis:** The user navigates to a dashboard to view charts and analytics of their spending habits, such as expenses by category and monthly trends.
- **Transaction History Review:** The user browses a detailed list of all their past transactions for review and verification.
- **AI-Powered Financial Coaching:** The user interacts with an AI coach to receive personalized advice and insights based on their spending patterns.

## 3. TECHNICAL CONSTRAINTS
- **Must Work Offline:** The core functionality (SMS parsing and transaction logging) is designed to work entirely offline. All data is processed and stored locally on the device.
- **High Security & Privacy:** No financial data is sent to external servers. The app relies on a local SQLite database, ensuring the user's information remains private.
- **Target Platform (Primary):** The reliance on `flutter_sms_inbox` heavily implies that the primary target platform is **Android**, as iOS does not permit programmatic access to user SMS messages for third-party apps.

## 4. ARCHITECTURAL FLOW
The application follows a clear, layered architectural flow for data movement, primarily from the local device to the UI, not a remote API.

1.  **Data Ingestion:** The `SmsService` listens for and reads new SMS messages from the user's inbox with their permission.
2.  **Parsing & Extraction:** The `SmsExtractorService` (specifically `BankingSmsParser`) receives the raw SMS content. It uses a series of regular expressions and logic to identify bank senders, extract key details (amount, merchant, date, type), and constructs a `Transaction` data model.
3.  **Local Persistence:** The parsed `Transaction` object is passed to the `TransactionDb` service, which then saves it into a local SQLite database on the device.
4.  **Data Aggregation & Calculation:** The `StatsService` queries the SQLite database to perform calculations, aggregate data for charts (e.g., spending by category), and compute analytics.
5.  **UI Presentation:** The UI screens (`TransactionsPage`, `DashboardPage`) query the `TransactionDb` and `StatsService` to get the data required for display. `fl_chart` is used to render this data into visual charts on the `DashboardPage`.
6.  **AI Insights (Optional):** The `GemmaService` (AI Coach) likely accesses the transaction data from the local database to analyze spending patterns and generate the financial advice that is displayed on the `CoachPage`.
