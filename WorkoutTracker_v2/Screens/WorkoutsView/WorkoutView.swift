//
//  WorkoutView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 1/22/23.
//

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject private var dbMgr : DbManager
    @EnvironmentObject private var selectedWkout : Workout
    
    @StateObject private var viewModel = WorkoutViewModel()

    @Binding var isWorkoutSelected : Bool
    
    @State private var restTime : UInt = 60
    @State private var restTimeRemaining : UInt = 60  // default to 60 seconds
    @State private var restTimerRunning = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // TODO:
    //    1) Sync restTimerRemaining with selectedWorkout.restTimeSec upon a change to the text field
    //    2) Write to the database when selectedWorkout.restTimeSec is changed
    //    3) Add rest time field in "Add New Workout" view
    //    4) change color to indicate when rest timer reaches 0???
    
    var body: some View {
        NavigationView {
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

//                    TextField("RestTime", value: $restTimeRemaining, format: .number)
                    Text("\(restTimeRemaining)")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 40)
                        .padding(3)
                        .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.secondarySystemBackground)))
                        .keyboardType(.numberPad)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .onReceive(timer) { _ in
                            if restTimerRunning && restTimeRemaining > 0 {
                                restTimeRemaining -= 1
                            }
                        }
                    
                    Rectangle()
                        .frame(height: 1)
                        .opacity(0.4)

                }

                ExercisesView(exercises: selectedWkout.exercises,
                              restTime : restTime,
                              restTimeRemainingSec: $restTimeRemaining,
                              restTimeRunning: $restTimerRunning)
            }
            .navigationTitle(selectedWkout.name)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                isWorkoutSelected = false
            } label: {
                XDismissButton()
            }
        }
        .onAppear() {
            self.viewModel.setup(self.dbMgr)
            restTime = selectedWkout.restTimeSec
            restTimeRemaining = selectedWkout.restTimeSec
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
