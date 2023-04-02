//
//  ExerciseListViewModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/12/23.
//

import Foundation
final class ExerciseListViewModel: ObservableObject {
    var dbMgr : DbManager?
    @Published var exercises : [String] = []
    
    func setup(_ dbMgr : DbManager) {
        self.dbMgr = dbMgr
        self.exercises = self.dbMgr!.getExercises()
    }
    
    func addNewExercise(name : String) {
        guard let mgr = dbMgr else { return }

        mgr.addNewExercise(name: name)
        exercises = mgr.getExercises()
    }
}
