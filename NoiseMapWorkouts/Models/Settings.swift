//
//  Settings.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 19.05.23.
//

import Foundation

class Settings: ObservableObject {
    static let shared = Settings()
    
    private init() {
        // Default settings
        if !appLaunchedBefore {
            setDefaults()
            appLaunchedBefore = true
        }
    }
    
    func setDefaults() {
        cyclingEnabled = Constants.defaultCyclingEnabled
        runningEnabled = Constants.defaultRunningEnabled
        walkingEnabled = Constants.defaultWalkingEnabled
        hikingEnabled = Constants.defaultHikingEnabled
        displayLimit = Constants.defaultDisplayLimit
        upperLimitGreen = Constants.defaultUpperLimitGreen
        upperLimitYellow = Constants.defaultUpperLimitYellow
        showExportWarning = true
    }
    
    // return true if current settings are default settings
    func defaultSettingsSet() -> Bool {
        return cyclingEnabled == Constants.defaultCyclingEnabled
            && runningEnabled == Constants.defaultRunningEnabled
            && walkingEnabled == Constants.defaultWalkingEnabled
            && hikingEnabled == Constants.defaultHikingEnabled
            && displayLimit == Constants.defaultDisplayLimit
            && upperLimitGreen == Constants.defaultUpperLimitGreen
            && upperLimitYellow == Constants.defaultUpperLimitYellow
    }
    
    @Published var cyclingEnabled = UserDefaults.standard.bool(forKey: UserDefaultKeys.cyclingEnabled.rawValue) {
        didSet { UserDefaults.standard.set(cyclingEnabled, forKey: UserDefaultKeys.cyclingEnabled.rawValue)}
    }
    
    @Published var runningEnabled = UserDefaults.standard.bool(forKey: UserDefaultKeys.runningEnabled.rawValue) {
        didSet { UserDefaults.standard.set(runningEnabled, forKey: UserDefaultKeys.runningEnabled.rawValue)}
    }
    
    @Published var walkingEnabled = UserDefaults.standard.bool(forKey: UserDefaultKeys.walkingEnabled.rawValue) {
        didSet { UserDefaults.standard.set(walkingEnabled, forKey: UserDefaultKeys.walkingEnabled.rawValue)}
    }
    
    @Published var hikingEnabled = UserDefaults.standard.bool(forKey: UserDefaultKeys.hikingEnabled.rawValue) {
        didSet { UserDefaults.standard.set(hikingEnabled, forKey: UserDefaultKeys.hikingEnabled.rawValue)}
    }
    
    @Published var displayLimit = UserDefaults.standard.integer(forKey: UserDefaultKeys.displayLimit.rawValue) {
        didSet { UserDefaults.standard.set(displayLimit, forKey: UserDefaultKeys.displayLimit.rawValue)}
    }
    
    @Published var upperLimitGreen = UserDefaults.standard.integer(forKey: UserDefaultKeys.upperLimitGreen.rawValue) {
        didSet { UserDefaults.standard.set(upperLimitGreen, forKey: UserDefaultKeys.upperLimitGreen.rawValue)}
    }
    
    @Published var upperLimitYellow = UserDefaults.standard.integer(forKey: UserDefaultKeys.upperLimitYellow.rawValue) {
        didSet { UserDefaults.standard.set(upperLimitYellow, forKey: UserDefaultKeys.upperLimitYellow.rawValue)}
    }
    
    @Published var onboardingFinished = UserDefaults.standard.bool(forKey: UserDefaultKeys.onboardingFinished.rawValue) {
        didSet { UserDefaults.standard.set(onboardingFinished, forKey: UserDefaultKeys.onboardingFinished.rawValue)}
    }
    
    @Published var appLaunchedBefore = UserDefaults.standard.bool(forKey: UserDefaultKeys.appLaunchedBefore.rawValue) {
        didSet { UserDefaults.standard.set(appLaunchedBefore, forKey: UserDefaultKeys.appLaunchedBefore.rawValue)}
    }
    
    @Published var showExportWarning = UserDefaults.standard.bool(forKey: UserDefaultKeys.showExportWarning.rawValue) {
        didSet { UserDefaults.standard.set(showExportWarning, forKey: UserDefaultKeys.showExportWarning.rawValue)}
    }
    
    @Published var currentTab: Tab = Tab.home
}

enum UserDefaultKeys: String {
    case onboardingFinished
    case appLaunchedBefore
    case currentTab
    case cyclingEnabled
    case runningEnabled
    case walkingEnabled
    case hikingEnabled
    case displayLimit
    case upperLimitGreen
    case upperLimitYellow
    case showExportWarning
}

enum Tab {
    case home
    case map
    case about
}
