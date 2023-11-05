//
//  WorkoutStatisticsViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/31/23.
//

import Foundation
final class WorkoutsStatisticsViewModel: ObservableObject {
    @Published var exerciseHistories : [ExerciseHistoryData] = []
    @Published var selectedExerciseName : String = ""
    @Published var allExerciseNames : [String] = []
    
    func setup() {
        getAllExerciseNames()
    }
    
    func refreshHistories() {
        exerciseHistories = DbManager.shared.getHistoricalExerciseData(exerciseName: selectedExerciseName)
    }
    
    func getAllExerciseNames() {
        allExerciseNames = DbManager.shared.getExercises()
    }
}
