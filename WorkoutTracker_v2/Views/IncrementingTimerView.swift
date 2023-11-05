//
//  IncrementingTimerView.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 6/4/23.
//

import SwiftUI

func formatMmSsMl(counter: Double) -> String {
    let minutes = Int((counter/(1000*60)).truncatingRemainder(dividingBy: 60))
    let seconds = Int((counter/1000).truncatingRemainder(dividingBy: 60))
    let milliseconds = Int((counter).truncatingRemainder(dividingBy: 1000))
    return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
}

struct IncrementingTimerView: View {
    var isTimerRunning : Bool
    @Binding var timeMs : Double
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var startTime : Date
    @State var interval = TimeInterval()
    
    @State var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
        
    var body: some View {
        VStack {
            Text(formatter.string(from: interval) ?? "")
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 10).fill( Color(UIColor.secondarySystemBackground)))
                .onReceive(timer) { _ in
                    if self.isTimerRunning {
                        interval = Date().timeIntervalSince(startTime)
                    }
                }
        }
    }
}

struct IncrementingTimerView_Previews: PreviewProvider {
    static var previews: some View {
        IncrementingTimerView(isTimerRunning: true,
                              timeMs: .constant(0),
                              startTime: Date())
    }
}
