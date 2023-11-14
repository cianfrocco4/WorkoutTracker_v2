//
//  WorkoutModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 11/5/23.
//

import Foundation

class WorkoutModel : ObservableObject {
    @Published var workouts : [Workout]
    @Published var historicalWorkouts : [WorkoutHistory]
    @Published var selectedWorkoutName : String?
    /** Name of the workout that is currently running. */
    @Published var runningWorkoutName : String?
    /** State datetime of the running workout. */
    @Published var runningWorkoutStartDate : Date?
    /** Time the workout has been running. */
    @Published var runningWorkoutTimeSec : Double
    
    init(
        workouts : [Workout],
        historicalWorkouts : [WorkoutHistory],
        selectedWorkoutName : String?,
        runningWorkoutName : String?,
        runningWorkoutTimeSec : Double,
        runningWorkoutStartDate : Date?)
    {
        self.workouts = workouts
        self.historicalWorkouts = historicalWorkouts
        self.selectedWorkoutName = selectedWorkoutName
        self.runningWorkoutName = runningWorkoutName
        self.runningWorkoutTimeSec = runningWorkoutTimeSec
        self.runningWorkoutStartDate = runningWorkoutStartDate
    }
    
    func setWorkouts(workouts : [Workout]) -> Void {
        self.workouts = workouts
    }
    
    func refreshWorkoutsFromDb() -> Void {
        setWorkouts(workouts: DbManager.shared.getWorkouts())
    }
    
    func isWorkoutSelected() -> Bool {
        return selectedWorkoutName != nil
    }
    
    func setSelectedWorkout(workoutName : String?) {
        // should we check that the workoutName is a valid one???
        selectedWorkoutName = workoutName
    }
    
    func removeWorkout(workoutName : String) -> Void {
        if(workouts.contains(
            where: { wkout in
                return wkout.name == workoutName
            }))
        {
            DbManager.shared.removeWorkout(workoutName: workoutName)
            refreshWorkoutsFromDb()
        }
    }
    
    func addNewWorkout(workout : Workout) -> Void {
        DbManager.shared.addNewWorkout(newWorkout: workout)
        refreshWorkoutsFromDb()
    }
    
    func toggleWorkoutRunning() -> Void {
        runningWorkoutTimeSec = 0
        runningWorkoutStartDate = Date()
        runningWorkoutName =
            runningWorkoutName == nil ?
                selectedWorkoutName :
                nil
    }
    
    func isWorkoutRunning() -> Bool {
        return runningWorkoutName != nil
    }
}
