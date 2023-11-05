//
//  EditWorkoutViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/3/23.
//

import Foundation
final class EditWorkoutViewModel: ObservableObject {
    private var oldWorkoutName : String?
    
    func setup(workoutName : String) {
        self.oldWorkoutName = workoutName
    }
    
    func saveWorkout(workout : Workout) {
        guard let oldName = oldWorkoutName else { return }
        
//        mgr.saveWorkout(workoutName: workout.name, notes: "", restTimeSec: workout.restTimeSec)
        DbManager.shared.updateWorkoutName(oldWorkoutName: oldName, newWorkoutName: workout.name)
    }
}
