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
        guard let mgr = dbMgr else { return "" }
            
        let date = mgr.getLastTimePerformed(workoutName: workoutName)
        if(date != nil) {
            let df = DateFormatter()
            df.dateFormat = "MM-dd-YYYY"
            let str = df.string(from: date!)
            return str
        }
        else {
            return "Not yet performed"
        }
    }
}
