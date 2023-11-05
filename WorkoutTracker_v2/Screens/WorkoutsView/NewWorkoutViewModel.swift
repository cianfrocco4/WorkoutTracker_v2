//
//  NewWorkoutViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/19/23.
//

import Foundation
final class NewWorkoutViewModel: ObservableObject {
    @Published var newWorkoutName = ""
    @Published var newWorkout = Workout(id: 0, name: "", exercises: [], restTimeSec: 60)
    @Published var exercises : [Exercise] = []
    
    func addNewWorkout() {
        DbManager.shared.addNewWorkout(newWorkout : newWorkout)
    }
    
    func loadDeletedWorkout() {
        if DbManager.shared.getAllHistoricalWorkoutNames().contains(newWorkout.name) {
            exercises = DbManager.shared.getExercisesForHistoricalWorkout(workoutName: newWorkout.name)
        }
    }
}
