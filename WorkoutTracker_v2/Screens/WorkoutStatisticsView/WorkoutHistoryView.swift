//
//  WorkoutHistoryChartView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 3/25/23.
//

import SwiftUI

struct WorkoutHistoryView: View {
    @StateObject private var viewModel = WorkoutHistoryViewModel()
    
    @Binding var workouts : [WorkoutHistory]
    
    @EnvironmentObject var dbMgr : DbManager
        
    var body: some View {
        if viewModel.isShowingWorkoutHistoryDetails {
            Button {
                viewModel.isShowingWorkoutHistoryDetails = false
            } label:{
                if viewModel.selectedWkoutHistory != nil {
                    WorkoutHistoryDetailsView(wkoutHistory: viewModel.selectedWkoutHistory!,
                                              isShowingWorkoutHistoryDetails: $viewModel.isShowingWorkoutHistoryDetails)
                }
                else {
                    Text("Coming soon!")
                }
            }
        }
        else {
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach (0..<self.workouts.count) { idx in
                            DateNameCheckView(date: workouts[idx].date,
                                              isShowingWorkoutHistoryDetails: $viewModel.isShowingWorkoutHistoryDetails,
                                              workout: $workouts[idx].workout,
                                              selectedWkoutHistory: $viewModel.selectedWkoutHistory)
                            .padding(.trailing, -5)
                            .id(idx)
                        }
                    }
                    .onAppear() {
                        viewModel.setup(dbMgr)
                    }
                }
                .frame(height: 80)
                .onAppear() {
                    proxy.scrollTo(self.workouts.count - 1) // scroll to far right on appear
                }
            }
        }
    }
}

struct WorkoutHistoryView_Previews: PreviewProvider {
    static let dbMgr = DbManager(db_path: "WorkoutTracker.sqlite")

    static var previews: some View {
        WorkoutHistoryView(workouts: .constant([MockData.workoutHistory1, MockData.workoutHistory2, MockData.workoutHistory3]))
            .environmentObject(dbMgr)
    }
}

struct DateNameCheckView: View {
    @State var date : Date
    @Binding var isShowingWorkoutHistoryDetails : Bool
    @Binding var workout : Workout?
    @Binding var selectedWkoutHistory : Workout?
    
    static let shortDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()
    
    static func getDateStr(date: Date, df : DateFormatter) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }
        else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }
        else {
            return DateNameCheckView.shortDateFormat.string(from: date)
        }
    }
    
    let df = DateFormatter()

    var body: some View {
        Button {
            if workout != nil {
                isShowingWorkoutHistoryDetails = true
                selectedWkoutHistory = workout
            }
        } label: {
            VStack {
                Text(DateNameCheckView.getDateStr(date: date,
                                                  df: DateNameCheckView.shortDateFormat))
                .font(.footnote)
                .fontWeight(.semibold)
                .padding(.bottom, 3)
                
                Image(systemName: workout == nil ? "x.square.fill" : "checkmark.square.fill")
                    .imageScale(.medium)
                    .foregroundColor(workout == nil ? .red : .green)
                
                Text(workout?.name ?? "N/A")
                    .foregroundColor(workout == nil ? .red : .green)
                    .font(.footnote)
                    .padding(.top, 5)
            }
            .frame(width: 75, height: 75)
            .foregroundColor(.primary)
            .background(Color(uiColor: UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .onAppear() {
                df.dateStyle = .short
            }
        }
    }
}
