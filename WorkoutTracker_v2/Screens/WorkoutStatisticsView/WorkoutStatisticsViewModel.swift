//
//  WorkoutStatisticsViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/31/23.
//

import Foundation
final class WorkoutsStatisticsViewModel: ObservableObject {
    var dbMgr : DbManager?
    
    @Published var exerciseHistories : [ExerciseHistoryData] = []
    @Published var selectedExerciseName : String = ""
    @Published var allExerciseNames : [String] = []
    
    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
        getAllExerciseNames()
    }
    
    func refreshHistories() {
        guard let mgr = dbMgr else { return }
        
        exerciseHistories = mgr.getHistoricalExerciseData(exerciseName: selectedExerciseName)
    }
    
    func getAllExerciseNames() {
        guard let mgr = dbMgr else { return }
        
        allExerciseNames = mgr.getExercises()
    }
}
