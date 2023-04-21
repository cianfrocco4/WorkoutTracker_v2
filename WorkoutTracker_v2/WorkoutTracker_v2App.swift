//
//  WorkoutTracker_v2App.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/18/23.
//

import SwiftUI
import Foundation

@main
struct WorkoutTracker_v2App: App {
    // Key for last version in NSUserDefaults
    static let versionKey = "LastAppVersion"
    // Key for last build in NSUserDefaults
    static let buildKey   = "LastBuildVersion"
    
    var body: some Scene {
        WindowGroup {
            WorkoutTrackerTabView()
                .onAppear() {
                    let currentVersion = UIApplication.appVersion
                    let currentBuildNum = UIApplication.appBuildNumber
                    
                    let defaults = UserDefaults.standard
                    
                    guard let lastAppVersion  = defaults.string(forKey: WorkoutTracker_v2App.versionKey) else {
                        updateDatabase()
                        defaults.set(currentVersion, forKey: WorkoutTracker_v2App.versionKey)
                        return
                    }
                    
                    guard let lastAppBuildNum = defaults.string(forKey: WorkoutTracker_v2App.buildKey) else {
                        updateDatabase()
                        defaults.set(currentBuildNum, forKey: WorkoutTracker_v2App.buildKey)
                        return
                    }
                    
                    if lastAppVersion != currentVersion || lastAppBuildNum != currentBuildNum {
                        updateDatabase()
                    }
                    
                    defaults.set(currentVersion, forKey: WorkoutTracker_v2App.versionKey)
                    defaults.set(currentBuildNum, forKey: WorkoutTracker_v2App.buildKey)
                }
        }
    }
    
    func updateDatabase() {
        print("Updating database...")
        
        let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
        dbMgr.updateDb()
    }
}
