//
//  WorkoutControlsViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 7/3/23.
//

import Foundation

final class WorkoutControlsViewModel : ObservableObject {
    @Published var workoutStartTime : Date = Date()
    
    func setRestTimerOn(isOn : Bool) {
        DbManager.shared.setRestTimerEnabled(isOn: isOn)
    }
    
    func saveWorkout(workout : Workout) {
        DbManager.shared.saveWorkout(workoutName: workout.name, notes: "", restTimeSec: workout.restTimeSec)
    }
    
    func getSelectedWorkout() -> (String, Date, Bool)? {
        return DbManager.shared.getSelectedWorkout(forDate: Date())
    }
}
