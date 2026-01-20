# Budget Management Feature Implementation Plan

## Phase 1: Database and Data Model
This phase focuses on extending the data layer to support budget management.

- [ ] Task: Define new database schema for budgets
    - [ ] Write tests for budget schema creation and migration
    - [ ] Implement database schema changes for budgets (e.g., `budgets` table with `category_id`, `amount`, `periodicity`)
- [ ] Task: Create Budget data model
    - [ ] Write tests for Budget model serialization/deserialization
    - [ ] Implement Budget Dart class in `lib/models/`
- [ ] Task: Implement basic CRUD operations for Budgets in `TransactionDb`
    - [ ] Write tests for `createBudget`, `readBudget`, `updateBudget`, `deleteBudget`
    - [ ] Implement `createBudget`, `readBudget`, `updateBudget`, `deleteBudget` methods in `lib/data/transaction_db.dart`
- [ ] Task: Conductor - User Manual Verification 'Database and Data Model' (Protocol in workflow.md)

## Phase 2: Core Logic and Service Integration
This phase focuses on implementing the business logic for budget tracking and integrating with existing services.

- [ ] Task: Implement `BudgetService` to calculate spending against budgets
    - [ ] Write tests for `BudgetService` (e.g., `getSpendingForCategory`, `getBudgetUtilization`)
    - [ ] Implement `BudgetService` class in `lib/services/` to interact with `TransactionDb` and `StatsService`
- [ ] Task: Integrate `BudgetService` with `StatsService`
    - [ ] Write tests for `StatsService` budget integration
    - [ ] Modify `StatsService` to use `BudgetService` for budget-related statistics
- [ ] Task: Conductor - User Manual Verification 'Core Logic and Service Integration' (Protocol in workflow.md)

## Phase 3: User Interface (UI) Development
This phase focuses on creating the user-facing components for budget management.

- [ ] Task: Design and implement Budget creation/editing screen
    - [ ] Write widget tests for Budget creation/editing screen
    - [ ] Implement UI for setting budget amounts per category
- [ ] Task: Display Budget information on Dashboard or dedicated Budget page
    - [ ] Write widget tests for budget display
    - [ ] Implement UI to show spending vs. budget with visual progress bars
- [ ] Task: Implement basic budget threshold notifications
    - [ ] Write integration tests for budget notifications
    - [ ] Implement logic to trigger notifications at 80% and 100% budget utilization
- [ ] Task: Conductor - User Manual Verification 'User Interface (UI) Development' (Protocol in workflow.md)
