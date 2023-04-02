//
//  WorkoutHistoryView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/24/23.
//

import SwiftUI
import Charts

struct WorkoutStatisticsView: View {
    @EnvironmentObject var dbMgr : DbManager
    
    @StateObject private var viewModel = WorkoutsStatisticsViewModel()
        
    func getAvgWeight(exerciseHistory : ExerciseHistoryData) -> Float {
        var sum : Float = 0.0
        for wgt in exerciseHistory.weights {
            sum += wgt
        }
        
        return sum / Float(exerciseHistory.weights.count)
    }
        
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Exercise Name:")
                    Picker(selection: $viewModel.selectedExerciseName,
                           label: Text("Exercise Name")) {
                        ForEach(viewModel.allExerciseNames, id: \.self) { exer in
                            Text(exer)
                        }
                    }
                           .onChange(of: viewModel.selectedExerciseName, perform: { _ in
                               viewModel.refreshHistories()
                           })
                           .pickerStyle(.menu)
                }
                .padding(.top)
                
                Chart {
                    ForEach(viewModel.exerciseHistories) { exerciseHistory in
                        BarMark(x: .value("Date", exerciseHistory.date),
                                 y: .value("Weight", self.getAvgWeight(exerciseHistory: exerciseHistory)))
                    }
                }
                .frame(height: 150)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Statistics 📈")
            .onAppear {
              self.viewModel.setup(self.dbMgr)
            }
        }
    }
}

struct WorkoutStatisticsView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")
    static var previews: some View {
        WorkoutStatisticsView()
            .environmentObject(dbMgr)
    }
}
