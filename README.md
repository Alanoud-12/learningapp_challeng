SwiftUI Learning Tracker App

A simple iOS application built with SwiftUI to help users set learning goals, track their daily progress, and maintain streaks using a freeze feature.

Description

This app provides a focused interface for habit formation related to learning. Users start by setting a specific learning goal (e.g., "Learn Swift") and selecting a duration (Week, Month, Year). The main screen then allows users to log their activity for the current day as either "Learned" or "Freezed". The app visually tracks the streak, remaining freezes, and provides a calendar view to see historical progress.

Features

Onboarding: Set an initial learning goal topic and duration (Week/Month/Year).

Daily Logging: Mark the selected day as "Learned" or use a "Freeze" to skip without breaking the streak.

Streak Tracking: Visual display of days learned.

Freeze System: Limited number of freezes available based on goal duration (2/week, 8/month, 96/year).

Weekly Calendar View: Navigate week-by-week and see the status of each day.

Full Calendar View: Navigate month-by-month to see the complete history.

Goal Completion: View acknowledges when the target number of learned days is reached.

Change Goal: Option to update the learning goal topic and/or duration (resets streak).

Liquid Glass UI: Modern interface aesthetic using background materials and blur effects.

Data Persistence: Uses @AppStorage (UserDefaults) to save the user's goal, streak history, and freezes used.

Technologies Used

SwiftUI: For building the user interface declaratively.

Combine: For managing state changes reactively within ViewModels (@Published, sink, assign).

Swift: The core programming language.

Architecture

The application is built using the Model-View-ViewModel (MVVM) design pattern to ensure a clear separation of concerns:

Model (Models/Models.swift): Defines the data structures (Goal, AppData) and enums (LearningDuration, DayStatus).

View (Views/ folder): Contains all SwiftUI views (OnboardingView, ActivityView, FullCalendarView, etc.), responsible only for displaying data and forwarding user actions.

ViewModel (ViewModels/ folder): Contains the application state (ActivityViewModel) and presentation logic (OnboardingViewModel), handling user actions, data manipulation, and persistence.

Extensions (Extensions/ folder): Holds reusable helper code for Color, View, Date, and Int.

