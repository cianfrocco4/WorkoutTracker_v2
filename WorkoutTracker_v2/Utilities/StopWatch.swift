//
//  StopWatch.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 4/17/23.
//

import Foundation
import Combine


class Stopwatch: ObservableObject {
    /// String to show in UI
    @Published private(set) var message = "Not running"

    /// Is the timer running?
    @Published private(set) var isRunning = false
    
    @Published private(set) var elapsed : Double = 0
    
    private var timerLength : UInt

    /// Time that we're counting from
    private var startTime: Date?
    { didSet { saveStartTime() } }

    /// The timer
    private var timer: AnyCancellable?

    init(timerLength : UInt) {
        self.timerLength = timerLength
        startTime = fetchStartTime()

        if startTime != nil {
            start()
        }
    }
}

// MARK: - Public Interface

extension Stopwatch {
    func start() {
        timer?.cancel()               // cancel timer if any

        if startTime == nil {
            startTime = Date()
        }

        message = ""

        timer = Timer
            .publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard
                    let self = self,
                    let startTime = self.startTime
                else { return }

                let now = Date()
                self.elapsed = now.timeIntervalSince(startTime)

                guard UInt(self.elapsed) < self.timerLength else {
                    self.stop()
                    return
                }

                self.message = String(format: "%0.1f", self.elapsed)
            }

        isRunning = true
    }

    func stop() {
        timer?.cancel()
        timer = nil
        startTime = nil
        isRunning = false
        message = "Not running"
    }
}

// MARK: - Private implementation

private extension Stopwatch {
    func saveStartTime() {
        if let startTime = startTime {
            UserDefaults.standard.set(startTime, forKey: "startTime")
        } else {
            UserDefaults.standard.removeObject(forKey: "startTime")
        }
    }

    func fetchStartTime() -> Date? {
        UserDefaults.standard.object(forKey: "startTime") as? Date
    }
}
