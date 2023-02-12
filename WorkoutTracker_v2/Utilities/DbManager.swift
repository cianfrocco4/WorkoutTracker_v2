//
//  DbManager.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/26/23.
//

import Foundation
import SQLite3

class DbManager : ObservableObject {
    var db : OpaquePointer? = nil
    var isDbOpen = false
    
    init(db_path : String) {
        openDatabase(db_path: db_path)
    }
    
    func openDatabase(db_path : String) {
        do {
            let manager = FileManager.default

            let documentsURL = try manager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false).appendingPathComponent(db_path)

            var rc = sqlite3_open_v2(documentsURL.path, &db, SQLITE_OPEN_READWRITE, nil)
//            if rc == SQLITE_CANTOPEN {
                let bundleURL = Bundle.main.url(forResource: "databases/WorkoutTracker", withExtension: "sqlite")!
                try manager.removeItem(at: documentsURL)
                try manager.copyItem(at: bundleURL, to: documentsURL)
                rc = sqlite3_open_v2(documentsURL.path, &db, SQLITE_OPEN_READWRITE, nil)
//            }
            
            print("Db location: " + documentsURL.absoluteString)

            if rc != SQLITE_OK {
                print("Error: \(rc)")
            }
            else {
                print("Successfully opened db: \(db_path)")
                isDbOpen = true
            }
        } catch {
            print("Failed to open database")
            print(error)
        }
    }
    
    func getWorkouts() -> [Workout] {
        var workouts : [Workout] = []
        if isDbOpen {
            let queryString = "SELECT * from WorkoutDetails"
            var stmt: OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return workouts
            }
     
            //traversing through all the records
            var workoutId = 0
            var exerciseId = 0
            while(sqlite3_step(stmt) == SQLITE_ROW){
                let workoutName = String(cString: sqlite3_column_text(stmt, 0))
                let exerciseName = String(cString: sqlite3_column_text(stmt, 1))
                let numSets = sqlite3_column_int(stmt, 2)
                let minReps = sqlite3_column_int(stmt, 3)
                let maxReps = sqlite3_column_int(stmt, 4)
     
                //adding values to list
                let exercise = Exercise(id: exerciseId, name: exerciseName, sets: Int(numSets), minReps: Int(minReps), maxReps: Int(maxReps), weight: 0)
                let workoutIndex = workouts.firstIndex(where: {workout in workout.name == workoutName})
                if (workoutIndex != nil) {
                    workouts[workoutIndex!].exercises.append(exercise)
                }
                else {
                    workouts.append(Workout(id: workoutId, name: workoutName, exercises: [exercise]))
                    workoutId += 1
                }
                exerciseId += 1
            }
            
            do { sqlite3_finalize(stmt) }

        }
        
        return workouts
    }
    
    func saveWorkout(workoutName : String) {
        if isDbOpen {
            print("Saving workout to database: \(workoutName)")
            let queryStr = "INSERT INTO WorkoutHistory ( workoutName, notes, date ) VALUES ( '" +
                            workoutName + "', \'\'" + ", date('now', 'start of day') )"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK {
                print("ERROR preparing statement: " + queryStr)
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                print("ERROR could not execute: " + queryStr)
                return
            }
            
            sqlite3_finalize(stmt)
            
            print("Saved workout!")
        }
    }
    
    func saveExercise(workoutName : String,
                      exerciseName : String,
                      set : Int,
                      reps : Int,
                      weight : Float) {
        if isDbOpen {
            // Make sure there is workout entry for today's date
            var queryStr = "SELECT workoutName FROM WorkoutHistory WHERE workoutName = '" + workoutName + "' AND date = date('now', 'start of day')"
            var stmt: OpaquePointer?

            //preparing the query
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return
            }
            
            if(sqlite3_step(stmt) == SQLITE_ROW) {
                queryStr = "INSERT INTO ExerciseHistory ( workoutName, exerciseName, setNum, reps, weight, notes ) VALUES ( '" + workoutName + "', '" + exerciseName + "', " + String(set+1) + ", " + String(reps) + ", " + String(weight) + ", '')"

                if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK {
                    print("ERROR preparing statement: " + queryStr)
                    return
                }
                
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("ERROR could not execute: " + queryStr)
                    return
                }
                
                print("Saved exercise!")
            }
            else {
                print("ERROR getting workout id")
            }
            
            sqlite3_finalize(stmt)
        }
    }
    
    func getLastTimePerformed(exerciseName: String,
                              setNum: Int) -> (reps : Int, weight: Int)? {
        if isDbOpen {
            let queryStr = "SELECT reps, weight, ExerciseHistory.notes, date FROM WorkoutHistory LEFT JOIN ExerciseHistory ON WorkoutHistory.workoutName = ExerciseHistory.workoutName WHERE exerciseName = '" + exerciseName + "' AND setNum = " + String(setNum) + " ORDER BY date DESC limit 1"
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return nil
            }
            
            if(sqlite3_step(stmt) == SQLITE_ROW) {
                let reps = Int(sqlite3_column_int(stmt, 0))
                let weight = Int(sqlite3_column_int(stmt, 1))
                return (reps, weight)
            }
            
            sqlite3_finalize(stmt)
        }
        
        return nil
    }
    
    func getLastTimePerformed(workoutName: String) -> Date? {
        if isDbOpen {
            let queryStr = "SELECT date FROM WorkoutHistory WHERE workoutName = '" + workoutName + "' ORDER BY date DESC limit 1"
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return nil
            }
            
            if(sqlite3_step(stmt) == SQLITE_ROW) {
                let dateStr = String(cString: sqlite3_column_text(stmt, 0))
                var df = DateFormatter()
                df.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                df.dateFormat = "yyyy-MM-dd"
                let date = df.date(from: dateStr)!
                return date
            }
            
            sqlite3_finalize(stmt)
        }
        
        return nil
    }
}
