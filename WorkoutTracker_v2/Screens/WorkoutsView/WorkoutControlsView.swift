//
//  WorkoutControlsView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 7/3/23.
//

import SwiftUI

struct WorkoutControlsView: View {
    @EnvironmentObject private var workoutModel : WorkoutModel
    
    @StateObject private var viewModel = WorkoutControlsViewModel()
        
    @Binding var selectedWkout : Workout
    @Binding var restTimerRunning : Bool
    @Binding var isRestTimerOn : Bool
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Button {
                        workoutModel.toggleWorkoutRunning()
                        viewModel.workoutStartTime = Date()
                        DbManager.shared.setSelectedWorkout(
                            workoutName: workoutModel.isWorkoutRunning() ?
                                self.selectedWkout.name :
                                "",
                            isTimerOn: workoutModel.isWorkoutRunning())
                    } label: {
                        Text(workoutModel.isWorkoutRunning() ? "Stop Workout" : "Start Workout")
                            .foregroundColor(.primary)
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 150)
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 10).fill( workoutModel.isWorkoutRunning() ?  Color.red.opacity(0.5) : Color.green.opacity(0.5)))
                    .keyboardType(.numberPad)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    
                    IncrementingTimerView()
                    
                    Spacer()
                }
            }
            .padding(.leading)
            
            HStack {
                Text("Rest time:")
                    .font(.title3)
                TextField("RestTime", value: $selectedWkout.restTimeSec, format: .number)
                    .onChange(of: selectedWkout.restTimeSec) {
                        print("Rest time changed to: " + String($0))
//                        restTime = $0
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
            let selectedWkoutOpt = viewModel.getSelectedWorkout()
            if(selectedWkoutOpt != nil) {
                viewModel.workoutStartTime = selectedWkoutOpt!.1
            }
        }
    }
}

struct WorkoutControlsView_Previews: PreviewProvider {
    static let wkout = MockData.sampleWorkout1

    static var previews: some View {
        WorkoutControlsView(selectedWkout: .constant(MockData.sampleWorkout1),
                            restTimerRunning: .constant(true),
                            isRestTimerOn: .constant(true))
        .environmentObject(wkout)
    }
}
