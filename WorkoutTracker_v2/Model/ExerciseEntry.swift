//
//  ExerciseEntry.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/2/23.
//

import Foundation

struct ExerciseEntry : Identifiable, Hashable {
    let set : Int
    let prevWgtLbs : Float?
    var wgtLbs : Float?
    var reps : Int
    var saved : Bool
    let id = UUID()
    
    var setString: String {
        String(set)
    }
    
    var prevWgtLbsString: String {
        String(prevWgtLbs!)
    }
    
    var wgtLbsString: String {
        String(wgtLbs!)
    }
}

extension MockData {
    static let e1 = ExerciseEntry(set: 1, prevWgtLbs: nil, reps: 8, saved: false)
    static let e2 = ExerciseEntry(set: 2, prevWgtLbs: nil, reps: 8, saved: false)
    static let e3 = ExerciseEntry(set: 3, prevWgtLbs: nil, reps: 8, saved: false)
    
    static let e4 = ExerciseEntry(set: 1, prevWgtLbs: 50, reps: 8, saved: false)
    static let e5 = ExerciseEntry(set: 2, prevWgtLbs: 50, reps: 8, saved: false)
    static let e6 = ExerciseEntry(set: 3, prevWgtLbs: 50, reps: 8, saved: false)


    static let sampleEntries = [e1, e2, e3]
}
