//
//  WorkoutsViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/26/23.
//

import Foundation
import SwiftUI

final class WorkoutsViewModel: ObservableObject {
    @Published var workouts : [Workout] = []
    @Published var workoutHistory : [WorkoutHistory] = []
    @Published var isWorkoutSelected = false
    @Published var selectedWorkout : Workout?
    @Published var isShowingEditWorkout = false
    @Published var editWorkoutIdx : Int?
        
    var selectedWorkoutBinding: Binding<Workout> {
        Binding {
            self.selectedWorkout ?? MockData.sampleWorkout1 // TODO figure out best default value
        } set: {
            self.selectedWorkout = $0
        }
    }
    
    func setup() {
//        refreshWorkouts()
    }
    
    func getLastTimePerformed(workoutName : String) -> String {
        let date = DbManager.shared.getLastTimePerformed(workoutName: workoutName)
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
    
//    func refreshWorkouts() {
//        self.workouts = DbManager.shared.getWorkouts()
//        self.workoutHistory = getWorkoutHistory(days: 30)
//        
//        let selectedWkoutOpt = DbManager.shared.getSelectedWorkout(forDate: Date())
//        if(selectedWkoutOpt != nil) {
//            for (idx, wkout) in workouts.enumerated()
//            {
//                workouts[idx].active = wkout.name == selectedWkoutOpt!.0
//            }
//        }
//    }
    
//    func removeWorkout(workoutName : String) {
//        let idx = workouts.firstIndex(where: { $0.name == workoutName } )
//        
//        if (idx != nil) {
//            workouts.remove(at: idx!)
//            DbManager.shared.removeWorkout(workoutName: workoutName)
//        }
//    }
    
    func getWorkoutHistory(days: Int) -> [WorkoutHistory] {
        let workoutHistory = DbManager.shared.getLastDaysPerformed(days: days)
        return workoutHistory
    }
    
    func setEditWorkout(workoutName : String) {
        self.isShowingEditWorkout = true
        self.editWorkoutIdx = workouts.firstIndex(where: { $0.name == workoutName } )
    }
}
