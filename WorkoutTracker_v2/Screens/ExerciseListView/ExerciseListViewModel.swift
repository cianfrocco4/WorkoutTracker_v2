//
//  ExerciseListViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/12/23.
//

import Foundation
final class ExerciseListViewModel: ObservableObject {
    @Published var exercises : [String] = []
    
    func setup() {
        self.exercises = DbManager.shared.getExercises()
    }
    
    func addNewExercise(name : String) {
        DbManager.shared.addNewExercise(name: name)
        exercises = DbManager.shared.getExercises()
    }
}
