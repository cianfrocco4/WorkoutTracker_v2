//
//  WorkoutTracker_v2App.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/18/23.
//

import SwiftUI
import Foundation
import UserNotifications

@main
struct WorkoutTracker_v2App: App {
    // Key for last version in NSUserDefaults
    static let versionKey = "LastAppVersion"
    // Key for last build in NSUserDefaults
    static let buildKey   = "LastBuildVersion"
        
    @State private var useSystemBackgroundColor : Bool = true
    @State private var colorSelection : ColorScheme = .dark
    
    var body: some Scene {
        WindowGroup {
            WorkoutTrackerTabView(useSystemBackgroundColor: $useSystemBackgroundColor,
                                  colorSelection: $colorSelection)
                .onAppear() {
                    let currentVersion = UIApplication.appVersion
                    let currentBuildNum = UIApplication.appBuildNumber
                    
                    let defaults = UserDefaults.standard
                    
                    guard let lastAppVersion  = defaults.string(forKey: WorkoutTracker_v2App.versionKey) else {
                        updateDatabase()
                        requestNotifications()
                        defaults.set(currentVersion, forKey: WorkoutTracker_v2App.versionKey)
                        return
                    }
                    
                    guard let lastAppBuildNum = defaults.string(forKey: WorkoutTracker_v2App.buildKey) else {
                        updateDatabase()
                        requestNotifications()
                        defaults.set(currentBuildNum, forKey: WorkoutTracker_v2App.buildKey)
                        return
                    }
                    
                    if lastAppVersion != currentVersion || lastAppBuildNum != currentBuildNum {
                        updateDatabase()
                        requestNotifications()
                    }

                    defaults.set(currentVersion, forKey: WorkoutTracker_v2App.versionKey)
                    defaults.set(currentBuildNum, forKey: WorkoutTracker_v2App.buildKey)
                    
                    let useSystemBackgroundSetting  = defaults.bool(forKey: SettingsView.useSystemBackgroundKey)
                    let useDarkMode = defaults.bool(forKey: SettingsView.useDarkMode)
                    
                    DispatchQueue.main.async {
                        useSystemBackgroundColor = useSystemBackgroundSetting
                        colorSelection = useDarkMode ? .dark : .light
                    }
                }
                .preferredColorScheme(useSystemBackgroundColor ? nil : colorSelection)
        }
    }
    
    func updateDatabase() {
        print("Updating database...")
        
        DbManager.shared.updateDb()
    }
    
    func requestNotifications() {
        // Notifications
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { _ /* success */, _ /* error */ in
                }
            }
        }
    }
}
