//
//  WorkoutModel.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 11/5/23.
//

import Foundation

/**
 * The model for all current and historical workouts.
 */
class WorkoutModel : ObservableObject {
    /** The list of current workouts. */
    @Published var workouts : [Workout]
    /** The list of historiical workouts. */
    @Published var historicalWorkouts : [WorkoutHistory]
    /** The selected workout name, or nil if there isn't one. */
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
    
    /**
     * Set the workouts.
     *
     * @param workouts: the new workouts.
     * @return None.
     */
    func setWorkouts(workouts : [Workout]) -> Void {
        self.workouts = workouts
    }
    
    /**
     * Refresh the workout from the database.
     *
     * @return None.
     */
    func refreshWorkoutsFromDb() -> Void {
        setWorkouts(workouts: DbManager.shared.getWorkouts())
    }
    
    /**
     * @return true if a workout is selected, false otherwise.
     */
    func isWorkoutSelected() -> Bool {
        return selectedWorkoutName != nil
    }
    
    /**
     * Set the selected workout.
     *
     *@param workoutName the  workout name to set as selected or nil if none selected.
     *@return None.
     */
    func setSelectedWorkout(workoutName : String?) -> Void {
        // should we check that the workoutName is a valid one???
        selectedWorkoutName = workoutName
    }
    
    /**
     * @return the selected workout or nil if there isn't one.
     */
    func getSelectedWorkout() -> Workout? {
        guard let name = selectedWorkoutName else { return nil }
        guard let wkout = workouts.first(where: { w in return w.name == name}) else {
            return nil }
        return wkout
    }
    
    /**
     * Remove a workout from both the workout list and database.
     *
     *@param workoutName the name of the workout to remove.
     *@return None.
     */
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
    
    func removeExercise(
        workoutName : String,
        exerciseName : String) {
            guard let wkout = workouts.first(where: { w in return w.name == workoutName}) else {
                print("Can't remove exercise, workout doesn't exist: \(workoutName)")
                return
            }
            
            guard let exer = wkout.exercises.first(where: { e in return e.name == exerciseName }) else {
                print("Can't remove exercise (\(exerciseName)) from workout workout (\(exerciseName))")
                return
            }
            
            DbManager.shared.removeExerciseFromWorkout(workout: wkout, exercise: exer)
            refreshWorkoutsFromDb()
        }
    
    /**
     * Add a new workout.
     *
     *@param workout the new workout. This workout *must* have a unique name.
     *@return None.
     */
    func addNewWorkout(workout : Workout) -> Void {
        DbManager.shared.addNewWorkout(newWorkout: workout)
        refreshWorkoutsFromDb()
    }
    
    /**
     * Toggle workout running flag and time.
     *
     *@return None.
     */
    func toggleWorkoutRunning() -> Void {
        runningWorkoutTimeSec = 0
        runningWorkoutStartDate = Date()
        runningWorkoutName =
            runningWorkoutName == nil ?
                selectedWorkoutName :
                nil
    }
    
    /**
     * @return true if a workout is currently running, false otherwise.
     */
    func isWorkoutRunning() -> Bool {
        return runningWorkoutName != nil
    }
}
