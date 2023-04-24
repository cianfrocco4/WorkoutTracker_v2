//
//  NewWorkoutViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/19/23.
//

import Foundation
final class NewWorkoutViewModel: ObservableObject {
    var dbMgr : DbManager?
    
    @Published var newWorkoutName = ""
    @Published var newWorkout = Workout(id: 0, name: "", exercises: [], restTimeSec: 60)
    @Published var exercises : [Exercise] = []
    @Published var isShowingNewExer = false
    
    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
    }
    
    func addNewWorkout() {
        guard let mgr = dbMgr else { return }
            
        mgr.addNewWorkout(name : newWorkout.name)
    }
    
    func loadDeletedWorkout() {
        guard let mgr = dbMgr else { return }

        if mgr.getAllHistoricalWorkoutNames().contains(newWorkout.name) {
            exercises = mgr.getExercisesForHistoricalWorkout(workoutName: newWorkout.name)
        }
    }
}
