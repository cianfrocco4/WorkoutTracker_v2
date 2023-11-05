//
//  Exercise.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/2/23.
//

import Foundation

final class Exercise: Decodable, Identifiable, ObservableObject {
    var id      : Int
    var name    : String
    var sets    : Int
    var minReps : Int
    var maxReps : Int
    var weight  : Float
    
    init(id: Int, name: String, sets: Int, minReps: Int, maxReps: Int, weight: Float) {
        self.id = id
        self.name = name
        self.sets = sets
        self.minReps = minReps
        self.maxReps = maxReps
        self.weight = weight
    }
}

extension MockData {
    static let sampleExercises = [
        Exercise(id: 0, name: "Pull ups", sets: 3, minReps: 8, maxReps: 10, weight: 30),
        Exercise(id: 1, name: "Barbell Curls", sets: 3, minReps: 10, maxReps: 12, weight: 50),
        Exercise(id: 2, name: "Lat Pulldowns", sets: 3, minReps: 10, maxReps: 12, weight: 120)
    ]
}
