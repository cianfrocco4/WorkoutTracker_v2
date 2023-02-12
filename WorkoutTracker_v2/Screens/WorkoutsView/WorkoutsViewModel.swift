//
//  WorkoutsViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/26/23.
//

import Foundation
final class WorkoutsViewModel: ObservableObject {
    var dbMgr : DbManager?

    @Published var workouts : [Workout] = []
    @Published var isWorkoutSelected = false
    @Published var selectedWorkout : Workout?
    
    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
        self.workouts = dbMgr.getWorkouts()
    }
    
    func getLastTimePerformed(workoutName : String) -> String {
        let date = dbMgr!.getLastTimePerformed(workoutName: workoutName)
        if(date != nil) {
            var df = DateFormatter()
            df.dateFormat = "dd-MM-YYYY"
            let str = df.string(from: date!)
            return str
        }
        else {
            return "Not yet performed"
        }
    }
}
