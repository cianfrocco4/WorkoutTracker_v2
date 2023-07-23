//
//  WorkoutControlsView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 7/3/23.
//

import SwiftUI

struct WorkoutControlsView: View {
    @EnvironmentObject private var dbMgr : DbManager
    @EnvironmentObject private var selectedWkout : Workout
    
    @StateObject private var viewModel = WorkoutControlsViewModel()
    
    @State private var restTime : UInt = 60
    
    @Binding var isWorkoutSelected : Bool
    @Binding var restTimerRunning : Bool
    @Binding var workoutTime : Double
    @Binding var workoutTimerRunning : Bool
    @Binding var isRestTimerOn : Bool
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Button {
                        workoutTimerRunning = !workoutTimerRunning
                        viewModel.workoutStartTime = Date()
                        dbMgr.setSelectedWorkout(workoutName: workoutTimerRunning ? self.selectedWkout.name : "",
                                                 isTimerOn: workoutTimerRunning)
                    } label: {
                        Text(workoutTimerRunning ? "Stop Workout" : "Start Workout")
                            .foregroundColor(.primary)
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 150)
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 10).fill( workoutTimerRunning ?  Color.red.opacity(0.5) : Color.green.opacity(0.5)))
                    .keyboardType(.numberPad)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    
                    IncrementingTimerView(isTimerRunning: workoutTimerRunning,
                                          timeMs: $workoutTime,
                                          startTime: viewModel.workoutStartTime)
                    
                    Spacer()
                }
            }
            .padding(.leading)
            
            HStack {
                Text("Rest time:")
                    .font(.title3)
                TextField("RestTime", value: $restTime, format: .number)
                    .onChange(of: restTime) {
                        print("Rest time changed to: " + String($0))
                        restTime = $0
                        selectedWkout.restTimeSec = $0
                        viewModel.saveWorkout(workout: selectedWkout)
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 40)
                    .padding(.leading, 3)
                    .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.secondarySystemBackground)))
                    .keyboardType(.numberPad)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .disabled(!isRestTimerOn)
                    .tint(isRestTimerOn ? .gray : .primary)
                
                Toggle(isOn: $isRestTimerOn,
                       label: {
                    Text(isRestTimerOn ? "On" : "Off" )
                })
                .font(.subheadline)
                .toggleStyle(.button)
                .buttonStyle(.bordered)
                .tint(isRestTimerOn ? .green : .red)
                .onChange(of: isRestTimerOn) { val in
                    viewModel.setRestTimerOn(isOn: isRestTimerOn)
                }
                
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.bottom)
            
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .opacity(0.4)
                
                DecrementingTimerView(
                    timerRunning: $restTimerRunning,
                    startTimeRemaining: selectedWkout.restTimeSec,
                    isRestTimerOn: isRestTimerOn)
                
                Rectangle()
                    .frame(height: 1)
                    .opacity(0.4)
            }
        }
        .onAppear() {
            self.viewModel.setup(self.dbMgr)
            
            let selectedWkoutOpt = viewModel.getSelectedWorkout()
            if(selectedWkoutOpt != nil) {
                viewModel.workoutStartTime = selectedWkoutOpt!.1
                workoutTimerRunning = selectedWkoutOpt!.2
            }
        }
    }
}

struct WorkoutControlsView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static let wkout = MockData.sampleWorkout1

    static var previews: some View {
        WorkoutControlsView(isWorkoutSelected: .constant(true),
                            restTimerRunning: .constant(true),
                            workoutTime: .constant(0),
                            workoutTimerRunning: .constant(true),
                            isRestTimerOn: .constant(true))
        .environmentObject(dbMgr)
        .environmentObject(wkout)
    }
}
