//
//  SettingsViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/25/23.
//

import Foundation
final class SettingsViewModel: ObservableObject {
    var dbMgr : DbManager?
    
    @Published var exportLoc : String?
    
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
}
