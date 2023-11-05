//
//  SettingsViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/25/23.
//

import Foundation
import UserNotifications
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var exportLoc : String?
    @Published var isNotificationsOn : Bool = false
    
    func exportDb() {
        exportLoc = DbManager.shared.exportDb()
    }
    
    func installDb() {
        DbManager.shared.installNewDb()
    }
    
    func updateDb() {
        DbManager.shared.updateDb()
    }
    
    func requestUserNotificationAuth() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.isNotificationsOn = true
            } else {
                self.isNotificationsOn = false
            }
        }
    }
    
    func updateUseSystemBackgroundSetting(val : Bool) {
    }
    
    func updateBackgroundColorSetting(val : ColorScheme) {
    }
}
