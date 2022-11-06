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
    
    @State private var wakeUp = defaultWakeUpTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    static var defaultWakeUpTime: Date {
        var component = DateComponents()
        component.hour = 7
        return Calendar.current.date(from: component) ?? Date.now
    }
    
    //Alert
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Recommended Sleep Time") {
                    Text((calculateBedtime(wakeUpTime: wakeUp) ?? Date.now).formatted(date: .omitted, time: .shortened))
                        .font(.largeTitle)
                        .capsuling()
                        .centering()
                }
        
                Section("When do you want to wake up?") {
                    DatePicker("please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .centering()
                }
                
                Section("Desired amount of sleep") {
                    HStack {
                        Text("\(sleepAmount.formatted())")
                            .capsuling()
                        Spacer()
                        Stepper("Desired amount of sleep Stepper", value: $sleepAmount, in: 4...12, step: 0.25)
                            .labelsHidden()
                    }
                    .padding([.top, .bottom], 2)
                }
                
                Section("Daily coffee in take") {
                    HStack {
                        Text(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups")
                            .capsuling()
                        Spacer()
                        Picker("coffee amount stepper", selection: $coffeeAmount) {
                            ForEach(Array(1...20), id: \.self) {
                                Text(String($0))
                            }
                        }
                    }
                    .padding([.top, .bottom], 2)
                }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Ok") {}
            } message: {
                Text(alertMessage)
            }
            
            .navigationTitle("BetterRest")
        }
    }
    
    func calculateBedtime(wakeUpTime: Date) -> Date? {
        do {
            //for 1 in 1000 folk need some configuration
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (components.hour ?? 0) * 3600
            let minute = (components.minute ?? 0) * 60
            let wake = Double(hour + minute)
            
            let prediction = try model.prediction(wake: wake, estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            //actaualSleep은 커피양, 기상시간, 수면희망시간을 고려해 실제로 잠을 청한 시간을 의미한다.
            //wakeUp은 기상시간으로 해당 시에서 actualSleep을 뺌으로써 취침시간을 알 수 있다.
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime
        } catch {
            // something went wrong!
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
            return nil
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct CapsuleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(3)
            .padding([.leading, .trailing], 10)
            .background(Color(hex: 0xdfe6e9))
            .clipShape(Capsule())
    }
}

struct CenteringContent: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}

extension View {
    func capsuling() -> some View {
        self.modifier(CapsuleText())
    }
    
    func centering() -> some View {
        self.modifier(CenteringContent())
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
