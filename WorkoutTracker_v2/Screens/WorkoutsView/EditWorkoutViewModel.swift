//
//  EditWorkoutViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/3/23.
//

import Foundation
final class EditWorkoutViewModel: ObservableObject {
    var dbMgr : DbManager?
    
    private var oldWorkoutName : String?
    
    func setup(_ dbMgr : DbManager,
               workoutName : String) {
        self.dbMgr = dbMgr
        self.oldWorkoutName = workoutName
    }
    
    func saveWorkout(workout : Workout) {
        guard let mgr = dbMgr else { return }
        guard let oldName = oldWorkoutName else { return }
        
//        mgr.saveWorkout(workoutName: workout.name, notes: "", restTimeSec: workout.restTimeSec)
        mgr.updateWorkoutName(oldWorkoutName: oldName, newWorkoutName: workout.name)
    }
}
