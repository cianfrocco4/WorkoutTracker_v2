//
//  WorkoutsViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/26/23.
//

import Foundation
import SwiftUI

final class WorkoutsViewModel: ObservableObject {
    var dbMgr : DbManager?

    @Published var workouts : [Workout] = []
    @Published var workoutHistory : [WorkoutHistory] = []
    @Published var isWorkoutSelected = false
    @Published var selectedWorkout : Workout?
    @Published var isShowingAddNewWorkout = false
    @Published var isShowingEditWorkout = false
    @Published var editWorkoutIdx : Int?
    
    var selectedWorkoutBinding: Binding<Workout> {
        Binding {
            self.selectedWorkout ?? MockData.sampleWorkout1 // TODO figure out best default value
        } set: {
            self.selectedWorkout = $0
        }
    }
    
    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
        refreshWorkouts()
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
    
    func addNewWorkoutClicked() {
        isShowingAddNewWorkout = !isShowingAddNewWorkout
    }
    
    func refreshWorkouts() {
        guard let mgr = dbMgr else { return }

        self.workouts = mgr.getWorkouts()
        self.workoutHistory = getWorkoutHistory(days: 30)
        
        let selectedWkoutOpt = mgr.getSelectedWorkout(forDate: Date())
        if(selectedWkoutOpt != nil) {
            for (idx, wkout) in workouts.enumerated()
            {
                workouts[idx].active = wkout.name == selectedWkoutOpt!.0
            }
        }
    }
    
    func removeWorkout(workoutName : String) {
        let idx = workouts.firstIndex(where: { $0.name == workoutName } )
        
        if (idx != nil) {
            workouts.remove(at: idx!)
            
            guard let mgr = dbMgr else { return }
            
            mgr.removeWorkout(workoutName: workoutName)
        }
    }
    
    func getWorkoutHistory(days: Int) -> [WorkoutHistory] {
        guard let mgr = self.dbMgr else { return [] }
        let workoutHistory = mgr.getLastDaysPerformed(days: days)
        return workoutHistory
    }
    
    func setEditWorkout(workoutName : String) {
        self.isShowingEditWorkout = true
        self.editWorkoutIdx = workouts.firstIndex(where: { $0.name == workoutName } )
    }
}
