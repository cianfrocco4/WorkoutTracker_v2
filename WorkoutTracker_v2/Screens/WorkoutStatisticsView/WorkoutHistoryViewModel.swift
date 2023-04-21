//
//  WorkoutHistoryViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/25/23.
//

import Foundation

final class WorkoutHistoryViewModel: ObservableObject {
//    @Published var workouts : [WorkoutHistory] = []//[MockData.workoutHistory1, MockData.workoutHistory2, MockData.workoutHistory3]
    @Published var isShowingWorkoutHistoryDetails = false
    @Published var selectedWkoutHistory : Workout?
    
    var dbMgr : DbManager?

    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
        
//        guard let mgr = self.dbMgr else { return }
//        self.workouts = mgr.getLastDaysPerformed(days: 5)
    }
}
