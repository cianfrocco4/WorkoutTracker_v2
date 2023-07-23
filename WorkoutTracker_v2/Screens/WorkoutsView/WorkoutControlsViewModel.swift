//
//  WorkoutControlsViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 7/3/23.
//

import Foundation

final class WorkoutControlsViewModel : ObservableObject {
    @Published var workoutStartTime : Date = Date()
    
    var dbMgr : DbManager?
    
    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
    }
    
    func setRestTimerOn(isOn : Bool) {
        guard let mgr = dbMgr else { return }
        
        mgr.setRestTimerEnabled(isOn: isOn)
    }
    
    func saveWorkout(workout : Workout) {
        guard let mgr = dbMgr else { return }
        
        mgr.saveWorkout(workoutName: workout.name, notes: "", restTimeSec: workout.restTimeSec)
    }
    
    func getSelectedWorkout() -> (String, Date, Bool)? {
        guard let mgr = dbMgr else { return nil }

        return mgr.getSelectedWorkout(forDate: Date())
    }
}
