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
    
    @State private var workoutTime : UInt = 0
    @State private var workoutTimerRunning : Bool = false
    @State private var isShowingAddNewExer : Bool = false
    @State private var isShowingSwapExer : Bool = false
        
    var body: some View {
        NavigationView {
            VStack {
                // TODO - disabling for now
//                HStack {
//                    Button {
//                        workoutTimerRunning = !workoutTimerRunning
//                    } label: {
//                        Text(workoutTimerRunning ? "Stop Workout" : "Start Workout")
//                    }
//                    .multilineTextAlignment(.center)
//                    .frame(maxWidth: 100)
//                    .padding(6)
//                    .background(RoundedRectangle(cornerRadius: 10).fill( workoutTimerRunning ?  Color.red.opacity(0.5) : Color.green.opacity(0.5)))
//                    .keyboardType(.numberPad)
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//                }
//                .padding(.leading, 20)
//                .padding([.top, .bottom])
                
                VStack {
                    
                    VStack {
                        HStack {
                            Text("Rest time:")
                            TextField("RestTime", value: $restTime, format: .number)
                                .onChange(of: restTime) {
                                    print("Rest time changed to: " + String($0))
                                    restTime = $0
                                    selectedWkout.restTimeSec = $0
                                    viewModel.saveWorkout(workout: selectedWkout)
                                }
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 40)
                                .padding(3)
                                .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.secondarySystemBackground)))
                                .keyboardType(.numberPad)
                                .font(.footnote)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.leading, 20)
                        
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .opacity(0.4)
                            
                            TimerView(timerRunning: $restTimerRunning,
                                      startTimeRemaining: selectedWkout.restTimeSec)
                            
                            Rectangle()
                                .frame(height: 1)
                                .opacity(0.4)
                            
                        }
                    }
                    .blur(radius: isShowingAddNewExer || isShowingSwapExer ? 20 : 0)
                    .disabled(isShowingAddNewExer || isShowingSwapExer)
                    
                    ExercisesView(exercises: selectedWkout.exercises,
                                  restTime : restTime,
                                  restTimeRemaining: $restTimeRemaining,
                                  restTimeRunning: $restTimerRunning,
                                  isShowingAddNewExer: $isShowingAddNewExer,
                                  isShowingSwapExer: $isShowingSwapExer)
                }
            }
            .navigationTitle(selectedWkout.name)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                isWorkoutSelected = false
            } label: {
                XDismissButton()
            }
            .blur(radius: isShowingAddNewExer || isShowingSwapExer ? 20 : 0)
            .disabled(isShowingAddNewExer || isShowingSwapExer)
        }
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

struct TimerView : View {
    @EnvironmentObject private var dbMgr : DbManager

    @Binding var timerRunning : Bool
    @State var startTimeRemaining : UInt
    @State private var timeRemaining : Int = 0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State var startTime : Date?
    
    var body: some View {
        VStack {
            Button {
                // Stop the timer if pressed
                timerRunning = false
                timeRemaining = 0
            } label: {
                Text("\(timeRemaining)")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 40)
                    .padding(3)
                    .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.secondarySystemBackground)))
                    .keyboardType(.numberPad)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .onReceive(timer) { _ in
                        if timerRunning {
                            guard let startTime = dbMgr.getLastSavedRestTimerStartTime() else { return }
                            timeRemaining = Int(startTime.timeIntervalSince(Date.now))
                            
                            if timeRemaining <= 0 {
                                timeRemaining = 0
                                timerRunning = false
                            }
                        }
                    }
            }
        }
        .onAppear() {
            if !timerRunning {
                timeRemaining = Int(startTimeRemaining)
            }
        }
    }
}
