
# Cashify - Expense Tracker

A clean, modern iOS expense tracking app built with SwiftUI, focused on simplicity, insights, and smooth user experience.


### Overview
Cashify helps users manage their finances by tracking income and expenses, visualizing spending patterns, and maintaining financial awareness  all through a clean and intuitive interface.

### Features
##### Transaction Management
- Add income and expense transactions
- Delete transactions with confirmation
- Real-time balance calculation

##### Insights & Analytics
- Category-based expense breakdown
- Weekly & monthly spending analysis
- Interactive charts using SwiftUI Charts

##### Smart UI/UX
- Smooth animations and transitions
- Semi-circular animated spending visualization
- Context menus and gesture interactions
- Clean, minimal design

##### Authentication (Demo)
- Sign In / Sign Up flow
- Form validation (email, password, confirm password)
- Dynamic UI expansion with animations

### Architecture

This app follows a scalable and production-ready architecture:
 
 #### MVVM + CoreData + Service Layer

**Core/**
- Models
-  Utils
- Extensions

**Services/**
- PersistenceController

**Features/**
-  Transactions

    ── Models

    ── ViewModels
        
    ── Views
    
    ── Repository

- Home
    
    ── Balance

    ── Profile

    ── Auth

**App/**
- RootView
- MainTabView

### Key principles

- Separation of concerns
- Clean state management
- Dependency injection
- Reusable components
- Scalable folder structure

### Tech Stack
- **SwiftUI**
- **CoreData**
- **Combine**
- **Swift Charts**

### Highlights
- Smooth animations (including semi-circle chart)
- Modular architecture
- Clean and maintainable codebase
- Real-time UI updates
- Optimized for performance and readability

### TestFlight

**Download & Test the App:**  
`https://testflight.apple.com/join/XHGFr1Cp`

> Note: Any valid email and password (min 6 characters) will work.

### Installation

> Clone the repository

`git clone https://github.com/write2nupu/StaAssets.git`

> Open in Xcode : StaAssets.xcodeproj

> Run on Simulator or Physical Device

### What to Test
- Adding and deleting transactions
- Balance updates after each transaction
- Category-based insights and charts
- Date filtering (Day / Week / Month)
- Authentication validation
- Smooth UI animations



## Author

- Nupur Sharma :
[@write2nupu](https://www.github.com/write2nupu)
(iOS Developer)

> **This is a demo application built for evaluation purposes.
No real financial transactions are processed.**
