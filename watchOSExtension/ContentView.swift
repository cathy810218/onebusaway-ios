//
//  ContentView.swift
//  OBAKit watchOS Extension
//
//  Created by Aaron Brethorst on 8/15/21.
//

import SwiftUI
import OBAKitCore

struct StopRow: View {
    var stop: Stop

    var body: some View {
        Text(stop.name)
    }
}

struct ContentView: View {
    @ObservedObject var dataLoader = DataLoader()

    var body: some View {
        VStack {
            Text("Stops")
            List(self.dataLoader.stops) { stop in
                StopRow(stop: stop)
            }
        }.onAppear {
            self.dataLoader.fetch()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
