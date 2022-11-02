//
//  ContentView.swift
//  BetterRest
//
//  Created by 최준영 on 2022/10/31.
//
/*
You don’t strictly need to add CoreML before
SwiftUI, but keeping your imports in alphabetical order
makes them easier to check later on.
*/
import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    
    //Alert
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                DatePicker("please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desired amount of sleep")
                    .font(.headline)
                Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                
                Text("Daily coffee intake")
                    .font(.headline)
                Stepper("\(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups" )",value: $coffeeAmount, in: 1...20)
                
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Ok"){}
            } message: {
                Text(alertMessage)
            }
            
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate") {
                    calculateBedtime()
                }
            }
        }
    }
    
    func calculateBedtime() {
        do {
            //for 1 in 1000 folk need some configuration
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 3600
            let minute = (components.minute ?? 0) * 60
            let wake = Double(hour + minute)
            
            let prediction = try model.prediction(wake: wake, estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            //actaualSleep은 커피양, 기상시간, 수면희망시간을 고려해 실제로 잠을 청한 시간을 의미한다.
            //wakeUp은 기상시간으로 해당 시에서 actualSleep을 뺌으로써 취침시간을 알 수 있다.
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            // something went wrong!
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
