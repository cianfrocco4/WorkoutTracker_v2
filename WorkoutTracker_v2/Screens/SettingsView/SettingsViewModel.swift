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
    var dbMgr : DbManager?
    
    @Published var exportLoc : String?
    @Published var isNotificationsOn : Bool = false
    
    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
    }
    
    func exportDb() {
        guard let mgr = self.dbMgr else { return }
        exportLoc = mgr.exportDb()
    }
    
    func installDb() {
        guard let mgr = self.dbMgr else { return }
        mgr.installNewDb()
    }
    
    func updateDb() {
        guard let mgr = self.dbMgr else { return }
        mgr.updateDb()
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
        guard let mgr = self.dbMgr else { return }
    }
    
    func updateBackgroundColorSetting(val : ColorScheme) {
        guard let mgr = self.dbMgr else { return }
    }
}
