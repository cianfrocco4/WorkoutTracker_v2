//
//  WorkoutViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/3/23.
//

import Foundation
final class WorkoutViewModel: ObservableObject {
    
    @Published var workoutTime : Double = 0
    
    func saveWorkout(workout : Workout) {
        DbManager.shared.saveWorkout(workoutName: workout.name, notes: "", restTimeSec: workout.restTimeSec)
    }
    
    func setRestTimerOn(isOn : Bool) {
        DbManager.shared.setRestTimerEnabled(isOn: isOn)
    }
    
    func getSelectedWorkout() -> (String, Date, Bool)? {
        return DbManager.shared.getSelectedWorkout(forDate: Date())
    }
}
