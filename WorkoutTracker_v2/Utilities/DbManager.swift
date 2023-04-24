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
    var dbPath : String?
    var isDbOpen = false
    
    init(db_path : String) {
        openDatabase(db_path: db_path)
        enableForeignKeys()
    }
    
    func openDatabase(db_path : String) {
        do {
            self.dbPath = db_path
            let manager = FileManager.default

            let documentsURL = try manager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false).appendingPathComponent(db_path)

            var rc = sqlite3_open_v2(documentsURL.path, &db, SQLITE_OPEN_READWRITE, nil)
            if rc == SQLITE_CANTOPEN {
                let bundleURL = Bundle.main.url(forResource: "databases/WorkoutTracker", withExtension: "sqlite")!
                
                do {
                    try manager.removeItem(at: documentsURL)
                } catch {
                    print("DB does not exist, cannot remove.: " + documentsURL.absoluteString)
                }
                
                try manager.copyItem(at: bundleURL, to: documentsURL)
                rc = sqlite3_open_v2(documentsURL.path, &db, SQLITE_OPEN_READWRITE, nil)
            }
            
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
    
    func installNewDb() {
        // close the existing db connection
        sqlite3_close_v2(db)
        db = nil

        let manager = FileManager.default
        let bundleURL = Bundle.main.url(forResource: "databases/WorkoutTracker", withExtension: "sqlite")!
        do {
            let documentsURL = try manager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false).appendingPathComponent("WorkoutTracker.sqlite")

            do {
                try manager.removeItem(at: documentsURL)
            } catch {
                print("DB does not exist, cannot remove.: " + documentsURL.absoluteString)
            }
            
            try manager.copyItem(at: bundleURL, to: documentsURL)
            openDatabase(db_path: self.dbPath!) // assuming dbPath has been set before calling this func
        } catch {
            print("Could not find db URL")
        }
    }
    
    func enableForeignKeys() {
        if isDbOpen {
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, "PRAGMA foreign_keys", -1, &statement, nil) != SQLITE_OK {
                let err = String(cString: sqlite3_errmsg(db))
                print("error building statement: \(err)")
            }
            if sqlite3_step(statement) != SQLITE_ROW {
                print("expected a row")
            }
            let foreignKeysEnabled = sqlite3_column_int(statement, 0) != 0
            sqlite3_finalize(statement)
            print("enabled: \(foreignKeysEnabled)")
        }
    }
    
    func getWorkouts() -> [Workout] {
        var workouts : [Workout] = []
        if isDbOpen {
            var queryString = "SELECT * from WorkoutDetails"
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
                let restTimeSec = UInt(sqlite3_column_int(stmt, 5)) / (1000000)  // convert USec to Sec
     
                //adding values to list
                let exercise = Exercise(id: exerciseId, name: exerciseName, sets: Int(numSets), minReps: Int(minReps), maxReps: Int(maxReps), weight: 0.0)
                let workoutIndex = workouts.firstIndex(where: {workout in workout.name == workoutName})
                if (workoutIndex != nil) {
                    workouts[workoutIndex!].exercises.append(exercise)
                }
                else {
                    workouts.append(Workout(id: workoutId, name: workoutName, exercises: [exercise], restTimeSec: restTimeSec))
                    workoutId += 1
                }
                exerciseId += 1
            }
            
            queryString = "SELECT * FROM Workout"
            
            //preparing the query
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return workouts
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW){
                let workoutName = String(cString: sqlite3_column_text(stmt, 0))
                // Add workouts that don't have any exercises yet (from the Workout table)
                if !workouts.contains(where: { $0.name == workoutName }) {
                    workouts.append(Workout(id: workoutId, name: workoutName, exercises: [], restTimeSec: 60))
                    workoutId += 1
                }
            }
            
            do { sqlite3_finalize(stmt) }

        }
        
        return workouts
    }
    
    func saveWorkout(workoutName : String,
                     notes: String,
                     restTimeSec : UInt) {
        if isDbOpen {
            // Make sure there is workout entry for today's date
            var queryStr = "SELECT workoutName FROM WorkoutHistory WHERE workoutName = '" + workoutName + "' AND date = date('now', 'localtime')"
            var stmt: OpaquePointer?

            //preparing the query
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return
            }
            
            if(sqlite3_step(stmt) == SQLITE_ROW) {
                updateWorkoutRestTime(workoutName: workoutName,
                                      restTimeSec: restTimeSec)
                queryStr = "UPDATE WorkoutHistory SET notes = '" + notes +
                           "' WHERE workoutName = '" + workoutName + "' AND date = date('now', 'localtime')"
            }
            else {
                queryStr = "INSERT INTO WorkoutHistory ( workoutName, notes, date ) VALUES ( '" +
                                workoutName + "', \'" + notes + "\'" + ", date('now', 'localtime') )"
            }
            
            print("Saving workout to database: \(workoutName)")
//            queryStr = "INSERT INTO WorkoutHistory ( workoutName, notes, date ) VALUES ( '" +
//                            workoutName + "', \'" + notes + "\'" + ", date('now', 'localtime') )"
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
    
    func updateWorkoutRestTime(workoutName: String,
                               restTimeSec : UInt) {
        var queryStr = "UPDATE WorkoutDetails SET restTimeUSec = " + String(restTimeSec * 1000000) +
        " WHERE workoutName = '" + workoutName + "'"
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
    }
    
    func saveExercise(workoutName : String,
                      exerciseName : String,
                      set : Int,
                      reps : Int,
                      weight : Float,
                      notes: String) {
        if isDbOpen {
            // Make sure there is workout entry for today's date
            var queryStr = "SELECT workoutName FROM WorkoutHistory WHERE workoutName = '" + workoutName + "' AND date = date('now', 'localtime')"
            var stmt: OpaquePointer?

            //preparing the query
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return
            }
            
            if(sqlite3_step(stmt) == SQLITE_ROW) {
                // Check if exercise exists already for this date and set
                let result = getLastTimePerformed(workoutName: workoutName, exerciseName: exerciseName, setNum: set)
                
                let (currDay, currMonth, currYear) = getDayMonthYear(date: Date())
                
                if(result != nil && getDayMonthYear(date: result!.date) == (currDay, currMonth, currYear)) {
                    queryStr = "UPDATE ExerciseHistory set reps = " + String(reps) + ", weight = " + String(weight) + " WHERE workoutName = '" + workoutName + "' AND exerciseName = '" + exerciseName + "' AND setNum = " + String(set) + " AND notes = '" +
                        notes + "' AND date = date('now', 'localtime')"
                }
                else {
                    queryStr = "INSERT INTO ExerciseHistory ( workoutName, exerciseName, setNum, reps, weight, notes, date ) VALUES ( '" + workoutName + "', '" + exerciseName + "', " + String(set) + ", " + String(reps) + ", " + String(weight) + ", '" + notes  + "' , date('now', 'localtime'))"
                }
                    
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
    
    func unsaveExercise(workoutName : String,
                        exerciseName : String,
                        set : Int) {
        if isDbOpen {
            let queryStr = "DELETE FROM ExerciseHistory WHERE workoutName = '" + workoutName + "' AND " +
                           "exerciseName = '" + exerciseName + "' AND " +
                           "setNum = " + String(set) + " AND " +
                           "date = date('now', 'localtime')"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK {
                print("ERROR preparing statement: " + queryStr)
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                print("ERROR could not execute: " + queryStr)
                return
            }
            
            print("Unsaved exercise!")
        }
    }
    
    func getLastTimePerformed( workoutName : String?,
                               exerciseName: String,
                               setNum: Int) -> (reps : Int, weight: Float, notes: String, date : Date)? {
        if isDbOpen {
            var queryStr = "SELECT reps, weight, ExerciseHistory.notes, ExerciseHistory.date FROM WorkoutHistory LEFT JOIN ExerciseHistory ON WorkoutHistory.workoutName = ExerciseHistory.workoutName WHERE exerciseName = '" + exerciseName + "' AND setNum = " + String(setNum)
            if workoutName != nil {
                queryStr += " AND ExerciseHistory.workoutName = '" + workoutName! + "'"
            }
            queryStr += " ORDER BY ExerciseHistory.date DESC limit 1"
            
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return nil
            }
            
            if(sqlite3_step(stmt) == SQLITE_ROW) {
                let reps = Int(sqlite3_column_int(stmt, 0))
                let weight = Float(sqlite3_column_double(stmt, 1))
                let notes = String(cString: sqlite3_column_text(stmt, 2))
                let dateStr = String(cString: sqlite3_column_text(stmt, 3))
                
                let df = DateFormatter()
                df.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                df.dateFormat = "yyyy-MM-dd"
                let date = df.date(from: dateStr)!
                return (reps, weight, notes, date)
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
                guard let date = df.date(from: dateStr) else { return nil }
                return date
            }
            
            sqlite3_finalize(stmt)
        }
        
        return nil
    }
    
    func getExercises() -> [String] {
        var exercises : [String] = []
        
        if(isDbOpen) {
            let queryStr = "SELECT * FROM Exercise ORDER BY name ASC"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                while(sqlite3_step(stmt) == SQLITE_ROW) {
                    let exerciseName = String(cString: sqlite3_column_text(stmt, 0))
                    exercises.append(exerciseName)
                }
                
                sqlite3_finalize(stmt)
            }
        }
        
        return exercises
    }
    
    func getDayMonthYear(date: Date) -> (String, String, String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        
        print(year, month, day)
        return (day, month, year)
    }
    
    func getPrevWeight(exerciseName : String,
                       set : Int) -> Float? {
        var weight : Float?
        if(isDbOpen) {
            let queryStr = "SELECT weight FROM ExerciseHistory WHERE exerciseName = '" +
                            exerciseName + "' AND setNum = " + String(set) + " ORDER BY date DESC LIMIT 1"
            
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                if (sqlite3_step(stmt) == SQLITE_ROW) {
                    weight = Float(sqlite3_column_double(stmt, 0))
                }
                
                sqlite3_finalize(stmt)
            }
        }
        
        return weight
    }
    
    func addExerciseToWorkout(workout: Workout, exercise: Exercise) {
        if(isDbOpen) {
            let queryStr = "INSERT INTO WorkoutDetails (workoutName, exerciseName, numSets, minReps, maxReps) VALUES ('" +
                workout.name + "', '" + exercise.name + "', '" + String(exercise.sets) + "', '" + String(exercise.minReps) +
                "', '" + String(exercise.maxReps) + "')"
            
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("ERROR could not execute: " + queryStr)
                    return
                }
                
                print("Added exercise: " + exercise.name + " to workout: " + workout.name)
                
                sqlite3_finalize(stmt)
            }
        }
    }
    
    func removeExerciseFromWorkout(workout: Workout, exercise: Exercise) {
        if(isDbOpen) {
            let queryStr = "DELETE FROM WorkoutDetails WHERE workoutName = '" + workout.name + "' AND exerciseName = '" +
                           exercise.name + "'"
            
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("ERROR could not execute: " + queryStr)
                    return
                }
                
                print("Removed exercise: " + exercise.name + " from workout: " + workout.name)
                
                sqlite3_finalize(stmt)
            }
        }
    }
    
    func getPrevDate(workoutName : String,
                     exerciseName : String,
                     set : Int) -> Date? {
        let val = getLastTimePerformed(workoutName: workoutName,
                                       exerciseName: exerciseName,
                                       setNum: set)
        if val != nil {
            return val!.date
        }
        else {
            return nil
        }
    }
    
    func addNewExercise(name : String) {
        if(isDbOpen) {
            let queryStr = "INSERT INTO Exercise (name) VALUES ('" + name + "')"
            
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("ERROR could not execute: " + queryStr)
                    return
                }
                
                print("Added new exercise!")
                
                sqlite3_finalize(stmt)
            }
        }
    }
    
    func addNewWorkout(name : String) {
        if(isDbOpen) {
            var queryStr = "INSERT INTO Workout (name) VALUES ('" + name + "')"
            
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("ERROR could not execute: " + queryStr)
                    return
                }
                
                print("Added new workout!")
                
                queryStr = "INSERT INTO Workout (name) VALUES ('" + name + "')"
                
                sqlite3_finalize(stmt)
            }
        }
    }
    
    func updateWorkoutName(oldWorkoutName : String,
                           newWorkoutName : String) {
        if(isDbOpen) {
            var queryStr = "UPDATE Workout SET name ='" + newWorkoutName + "' WHERE name = '" + oldWorkoutName + "'"
            
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("ERROR could not execute: " + queryStr)
                }
                else {
                    print("Updated workout!")
                    
                    sqlite3_finalize(stmt)
                }
            }
            
            queryStr = "UPDATE WorkoutDetails SET workoutName ='" + newWorkoutName + "' WHERE workoutName = '" + oldWorkoutName + "'"

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("ERROR could not execute: " + queryStr)
                }
                else {
                    print("Updated workout details!")
                    
                    sqlite3_finalize(stmt)
                }
            }
        }
    }
    
    func removeWorkout(workoutName: String) {
        if (isDbOpen) {
            var queryStr = "DELETE FROM WorkoutDetails WHERE workoutName = '" + workoutName + "'"
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("ERROR could not execute: " + queryStr)
                    return
                }
                
                print("Removed workout from WorkoutDetails table")
                
                sqlite3_finalize(stmt)
            }
            
            // Remove from Workout table
            
            queryStr = "DELETE FROM Workout WHERE name = '" + workoutName + "'"
            
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("ERROR could not execute: " + queryStr)
                    return
                }
                
                print("Removed workout from Workout table")
                
                sqlite3_finalize(stmt)
            }
        }
    }
    
    func getSwiftDateFromSqliteDate(dateStr : String) -> Date {
        var df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        df.dateFormat = "yyyy-MM-dd"
        let date = df.date(from: dateStr)!
        return date
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        return Calendar.current.isDate(date1, equalTo: date2, toGranularity: .day)
    }
    
    func getLastDaysPerformed(days: Int) -> [WorkoutHistory] {
        var workouts : [WorkoutHistory] = []
        var id = 0
        for day in stride(from: days-1, to: -1, by: -1) {
            let temp = Date.now
            let date = Date.now.addingTimeInterval(TimeInterval(-86400 * day))
            workouts.append(WorkoutHistory(id: id, workout: nil, date: date))
            id+=1
        }
        if isDbOpen {
            let queryStr = "SELECT workoutName, date FROM WorkoutHistory WHERE date BETWEEN date('now', 'localtime', '-" + String(days) + " day') AND date('now', 'localtime')"
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return workouts
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW) {
                let dateStr = String(cString: sqlite3_column_text(stmt, 1))
                let date = getSwiftDateFromSqliteDate(dateStr: dateStr)

                for idx in workouts.indices {
                    if isSameDay(date1: workouts[idx].date, date2: date) {
                        workouts[idx].workout = Workout(id: workouts[idx].id,
                                                        name: String(cString: sqlite3_column_text(stmt, 0)),
                                                        exercises: [], restTimeSec: 0) // TODO exercises, restTimeSec
                    }
                }
            }
            
            sqlite3_finalize(stmt)
        }
        
        return workouts
    }
    
    func exportDb() -> String? {
        if isDbOpen {
            let fileMgr = FileManager.default
            guard let lcDbPath = self.dbPath else { return nil }
            
            do {
                let documentsURL = try fileMgr.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false).appendingPathComponent(lcDbPath)
                let backupURL = try fileMgr.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false).appendingPathComponent(lcDbPath + ".bak")
                
                if fileMgr.fileExists(atPath: backupURL.absoluteString) {
                    try fileMgr.removeItem(at: backupURL)
                }
                
                try fileMgr.copyItem(at: documentsURL, to: backupURL)
                print("Backed up Database success! Location: " + backupURL.absoluteString)
                return backupURL.absoluteString
            } catch {
                print(error.localizedDescription )
                return nil
            }
        }
        
        return nil
    }
    
    func getAllHistoricalWorkoutNames() -> [String] {
        var workouts : [String] = []
        
        if(isDbOpen) {
            let queryStr = "SELECT DISTINCT workoutName FROM WorkoutHistory ORDER BY name ASC"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                while(sqlite3_step(stmt) == SQLITE_ROW) {
                    let workoutName = String(cString: sqlite3_column_text(stmt, 0))
                    workouts.append(workoutName)
                }
                
                sqlite3_finalize(stmt)
            }
        }
        
        return workouts
    }
    
    func getExercisesForHistoricalWorkout(workoutName : String) -> [Exercise] {
        return []
    }
    
    func getHistoricalExerciseData(exerciseName : String) -> [ExerciseHistoryData] {
        var exercises : [ExerciseHistoryData] = []
        if(isDbOpen) {
            let queryStr = "SELECT workoutName, exerciseName, setNum, reps, weight, notes, date FROM ExerciseHistory WHERE exerciseName = '" + exerciseName + "' ORDER by date DESC"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
            }
            else {
                while(sqlite3_step(stmt) == SQLITE_ROW) {
                    let workoutName  = String(cString: sqlite3_column_text(stmt, 0))
                    let exerciseName = String(cString: sqlite3_column_text(stmt, 1))
                    let setNum       = Int(sqlite3_column_int(stmt, 2))
                    let reps         = Int(sqlite3_column_int(stmt, 3))
                    let weight       = Float(sqlite3_column_double(stmt, 4))
                    let notes        = String(cString: sqlite3_column_text(stmt, 5))
                    let dateStr      = String(cString: sqlite3_column_text(stmt, 6))
                    
                    let date = getSwiftDateFromSqliteDate(dateStr: dateStr)
                    
                    if exercises.contains(where: { $0.workoutName == workoutName &&
                                                   $0.exerciseName == exerciseName &&
                                                   isSameDay(date1: $0.date, date2: date) }) {
                        let idx = exercises.firstIndex(where: { $0.workoutName == workoutName &&
                                                                $0.exerciseName == exerciseName &&
                                                                isSameDay(date1: $0.date, date2: date) })
                        exercises[idx!].reps.append(reps)
                        exercises[idx!].weights.append(weight)
                    }
                    else {
                        let data = ExerciseHistoryData(id: exercises.count == 0 ? 0 : exercises[exercises.count - 1].id + 1,
                                                       workoutName: workoutName,
                                                       exerciseName: exerciseName,
                                                       date: date,
                                                       weights: Array([weight]),
                                                       reps: Array([reps]),
                                                       notes: notes)
                        exercises.append(data)
                    }

                }
                
                sqlite3_finalize(stmt)
            }
        }
        
        return exercises
    }
    
    func executeQuery(queryStr : String) -> Bool {
        if isDbOpen {
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return false
            }
            else {
                if sqlite3_step(stmt) != SQLITE_DONE {
                    print("ERROR could not execute: " + queryStr)
                    return false
                }
                else {
                    
                    print("Update db!")
                    
                    sqlite3_finalize(stmt)
                }
            }
            
            return true
        }
        
        return false
    }
    
    func UpdateWeightCol() {
        if executeQuery(queryStr: "DROP TABLE IF EXISTS tmp_ExerciseHistory") &&
           executeQuery(queryStr: """
                                   CREATE TABLE tmp_ExerciseHistory ( workoutName STRING NOT NULL, \
                                                                      exerciseName STRING NOT NULL,\
                                                                      setNum INTEGER NOT NULL,\
                                                                      reps INTEGER NOT NULL,\
                                                                      weight REAL NOT NULL,\
                                                                      notes STRING,\
                                                                      date STRING NOT NULL,\
                                                                      PRIMARY KEY (workoutName, exerciseName, setNum, date),\
                                                                      FOREIGN KEY (workoutName) REFERENCES Workout (name)\
                                                                      FOREIGN KEY (exerciseName) REFERENCES Exercise (name) )
                                  """) &&
           executeQuery(queryStr: "INSERT INTO tmp_ExerciseHistory (workoutName, exerciseName, setNum, reps, weight, notes, date) SELECT * FROM ExerciseHistory") &&
           executeQuery(queryStr: "DROP TABLE IF EXISTS ExerciseHistory") &&
           executeQuery(queryStr: """
                                   CREATE TABLE ExerciseHistory ( workoutName STRING NOT NULL,
                                                                  exerciseName STRING NOT NULL,
                                                                  setNum INTEGER NOT NULL,
                                                                  reps INTEGER NOT NULL,
                                                                  weight REAL NOT NULL,
                                                                  notes STRING,
                                                                  date STRING NOT NULL,
                                                                  PRIMARY KEY (workoutName, exerciseName, setNum, date),
                                                                  FOREIGN KEY (workoutName) REFERENCES Workout (name)
                                                                  FOREIGN KEY (exerciseName) REFERENCES Exercise (name) )
                                  """) &&
           executeQuery(queryStr: "INSERT INTO ExerciseHistory (workoutName, exerciseName, setNum, reps, weight, notes, date) SELECT * from tmp_ExerciseHistory") &&
           executeQuery(queryStr: "DROP TABLE IF EXISTS tmp_ExerciseHistory")
        {
             print ("Successfully Updated weight col!")
        }
        else {
            print("Failed to update weight col!")
        }
    }
    
    func AddRestTime() {
        if executeQuery(queryStr: "ALTER TABLE WorkoutDetails ADD COLUMN restTimeUSec INTEGER DEFAULT 60000000 NOT NULL") {
            print ("Successfully added rest time col!")
        }
        else {
            print ("Failed to add rest time col!")
        }
    }
    
    func AddRestTimerTable() {
        if executeQuery(queryStr: "CREATE TABLE IF NOT EXISTS RestTimer (restTimerStart STRING PRIMARY KEY)") {
            print ("Successfully added rest timer table!")
        }
        else {
            print ("Failed to add rest timer table!")
        }
    }

    
    func updateDb() {
        if isDbOpen {
            AddRestTime()
            
            UpdateWeightCol()
            
            AddRestTimerTable()
        }
    }
    
    func dumpDatabase() {
        if isDbOpen {
            print("dumping database...")
            
            let manager = FileManager.default
            var documentsURL : URL
            
            do {
                documentsURL = try manager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false).appendingPathComponent("WorkoutTracker-dump").appendingPathExtension("sql")
            } catch {
                print("Failed to dump database: Could not find documents dir")
                return
            }

            var statement: OpaquePointer?
            var queryStr = ".output " + documentsURL.path()
            if sqlite3_prepare_v2(db, queryStr, -1, &statement, nil) != SQLITE_OK {
                let err = String(cString: sqlite3_errmsg(db))
                print("error building statement: \(err)")
                return
            }
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to execute output statment")
                return
            }
            
            queryStr = ".dump"
            if sqlite3_prepare_v2(db, queryStr, -1, &statement, nil) != SQLITE_OK {
                let err = String(cString: sqlite3_errmsg(db))
                print("error building statement: \(err)")
                return
            }
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to dump database")
                return
            }
            
            sqlite3_finalize(statement)
            print("Dumped database!")
        }
    }
    
    func getLastSavedRestTimerStartTime() -> Date? {
        if isDbOpen {
            var queryStr = "SELECT count(*) from RestTimer"
            var stmt: OpaquePointer?
            
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return nil
            }
            
            if(sqlite3_step(stmt) == SQLITE_ROW) {
                let count = Int(sqlite3_column_int(stmt, 0))
                
                if count != 1 {
                    return nil
                }
            }
            
            queryStr = "SELECT restTimerStart from RestTimer"

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return nil
            }
            
            if(sqlite3_step(stmt) == SQLITE_ROW) {
                let val = sqlite3_column_text(stmt, 0)
                
                if val == nil { return nil }
                
                let dateStr = String(cString: val!)
                
                let df = DateFormatter()
                df.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                df.timeZone = TimeZone.current
                df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                df.calendar = Calendar.current
                let date = df.date(from: dateStr)!
                return date
            }
            
            sqlite3_finalize(stmt)
        }
        
        return nil
    }
    
    func insertCurrentRestTimerStartTime(restTimeOffset : UInt) -> Date? {
        if isDbOpen {
            var queryStr = "SELECT * FROM RestTimer"
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return nil
            }
            
            if(sqlite3_step(stmt) != SQLITE_ROW) {
                queryStr = "INSERT INTO RestTimer (restTimerStart) VALUES (datetime('now', 'localtime', " + " '+ " + String(restTimeOffset) + " seconds'))"
            }
            else {
                queryStr = "UPDATE RestTimer SET restTimerStart = datetime('now', 'localtime', '+" + String(restTimeOffset) + " seconds')"
            }
            
            if sqlite3_prepare_v2(db, queryStr, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing: \(errmsg)")
                return nil
            }
            
            if(sqlite3_step(stmt) != SQLITE_DONE) {
                print("Error running query: " + queryStr)
                return nil
            }
            
            sqlite3_finalize(stmt)
            
            return getLastSavedRestTimerStartTime()
        }
        
        return nil
    }
}
