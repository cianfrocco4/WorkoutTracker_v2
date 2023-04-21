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
    @State private var restTimerRunning = false
    @State private var restTimeRemaining : UInt = 60
        
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

                    if restTimerRunning {
                        TimerView(restTimerRunning: $restTimerRunning,
                                  restTime: selectedWkout.restTimeSec)
                    }
                    else {
                        HStack {
                            Spacer()
                            Text("\(selectedWkout.restTimeSec)")
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 40)
                                .padding(3)
                                .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.secondarySystemBackground)))
                                .font(.footnote)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    
//                    TextField("RestTime", value: $restTimeRemaining, format: .number)
//                    Text("\(restTimeRemaining)")
//                        .multilineTextAlignment(.center)
//                        .frame(maxWidth: 40)
//                        .padding(3)
//                        .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.secondarySystemBackground)))
//                        .keyboardType(.numberPad)
//                        .font(.footnote)
//                        .fontWeight(.semibold)
//                        .onReceive(timer) { _ in
//                            if restTimerRunning && restTimeRemaining > 0 {
//                                restTimeRemaining -= 1
//                            }
//                        }
                    
                    Rectangle()
                        .frame(height: 1)
                        .opacity(0.4)

                }

                ExercisesView(exercises: selectedWkout.exercises,
                              restTime : restTime,
                              restTimeRemaining: $restTimeRemaining,
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

    @Binding var restTimerRunning : Bool
    @State var restTime : UInt
    @State private var restTimeRemaining : Int = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var startTime : Date?
    
    var body: some View {
        VStack {
            Button {
                // Stop the timer if pressed
                restTimerRunning = false
                restTimeRemaining = Int(restTime)
            } label: {
                Text("\(restTimeRemaining)")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 40)
                    .padding(3)
                    .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.secondarySystemBackground)))
                    .keyboardType(.numberPad)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .onReceive(timer) { _ in
                        if restTimerRunning {
                            guard let startTime = dbMgr.getLastSavedRestTimerStartTime() else { return }
                            restTimeRemaining = Int(startTime.timeIntervalSince(Date.now))
                            
                            if restTimeRemaining <= 0 {
                                restTimeRemaining = Int(restTime)
                                restTimerRunning = false
                            }
                        }
                    }
            }
        }
        .onAppear() {
            if !restTimerRunning {
                restTimeRemaining = Int(restTime)
            }
        }
    }
}
