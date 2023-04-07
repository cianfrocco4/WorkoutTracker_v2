//
//  WorkoutViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/3/23.
//

import Foundation
final class WorkoutViewModel: ObservableObject {
    var dbMgr : DbManager?
    
    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
    }
    
    func saveWorkout(workout : Workout) {
        guard let mgr = dbMgr else { return }
        
        mgr.saveWorkout(workoutName: workout.name, notes: "", restTimeSec: workout.restTimeSec)
    }
}
