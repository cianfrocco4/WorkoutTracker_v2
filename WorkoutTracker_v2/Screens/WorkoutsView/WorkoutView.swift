//
//  WorkoutView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/22/23.
//

import SwiftUI
import UserNotifications

struct WorkoutView: View {
    @EnvironmentObject private var dbMgr : DbManager
    @EnvironmentObject private var selectedWkout : Workout
    
    @StateObject private var viewModel = WorkoutViewModel()
    
    @Binding var isWorkoutSelected : Bool
    
    @State private var restTime : UInt = 60
    @State private var restTimerRunning = false
    @State private var restTimeRemaining : UInt = 60
    @State private var workoutTime : Double = 0
    @State private var workoutTimerRunning : Bool = false
    @State private var isShowingAddNewExer : Bool = false
    @State private var isShowingSwapExer : Bool = false
    @State private var isRestTimerOn : Bool = false
    
    var body: some View {
        VStack {
            WorkoutControlsView(isWorkoutSelected: $isWorkoutSelected,
                                restTimerRunning: $restTimerRunning,
                                workoutTime: $workoutTime,
                                workoutTimerRunning: $workoutTimerRunning,
                                isRestTimerOn: $isRestTimerOn)
            .blur(radius: isShowingAddNewExer || isShowingSwapExer ? 20 : 0)
            .disabled(isShowingAddNewExer || isShowingSwapExer)
            
            ExercisesView(exercises: selectedWkout.exercises,
                          restTime : restTime,
                          restTimeRemaining: $restTimeRemaining,
                          restTimeRunning: $restTimerRunning,
                          isShowingAddNewExer: $isShowingAddNewExer,
                          isShowingSwapExer: $isShowingSwapExer,
                          isRestTimerOn: isRestTimerOn,
                          isWorkoutTimerRunning: workoutTimerRunning)
        }
        .padding(.top)
        .onAppear() {
            self.viewModel.setup(self.dbMgr)
            
            let startTime = dbMgr.getLastSavedRestTimerStartTime()
            
            // Check if rest timer is running
            if(startTime != nil) {
                let timeRemaining = Int(startTime!.timeIntervalSince(Date.now))
                
                if timeRemaining > 0 {
                    restTimerRunning = true
                }
            }
            
            restTime = selectedWkout.restTimeSec
            isRestTimerOn = dbMgr.getRestTimerEnabled() ?? false
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static let wkout = MockData.sampleWorkout1
    static var previews: some View {
        WorkoutView(isWorkoutSelected: .constant(true))
            .environmentObject(dbMgr)
            .environmentObject(wkout)
    }
}
