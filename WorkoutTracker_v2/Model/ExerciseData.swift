//
//  ExerciseData.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/2/23.
//

import Foundation

struct ExerciseData : Identifiable {
    var id   : Int
    var set  : String
    var reps : TextBindingManager
    var wgt  : TextBindingManager
}
