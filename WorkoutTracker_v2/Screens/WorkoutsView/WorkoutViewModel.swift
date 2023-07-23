//
//  WorkoutViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/3/23.
//

import Foundation
final class WorkoutViewModel: ObservableObject {
    
    @Published var workoutTime : Double = 0
    
    var dbMgr : DbManager?
    
    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
    }
    
    func saveWorkout(workout : Workout) {
        guard let mgr = dbMgr else { return }
        
        mgr.saveWorkout(workoutName: workout.name, notes: "", restTimeSec: workout.restTimeSec)
    }
    
    func setRestTimerOn(isOn : Bool) {
        guard let mgr = dbMgr else { return }

        mgr.setRestTimerEnabled(isOn: isOn)
    }
    
    func getSelectedWorkout() -> (String, Date, Bool)? {
        guard let mgr = dbMgr else { return nil }

        return mgr.getSelectedWorkout(forDate: Date())
    }
}
