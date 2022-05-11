//
//  OnboardingScreen.swift
//  ListenUp
//
//  Created by Tyler Dakin on 5/11/22.
//

import SwiftUI

struct OnboardingScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var tabSelection = 1
    
    var body: some View {
        VStack {
            TabView(selection: $tabSelection) {
                {
                    VStack {
                        Spacer()
                        Text("Welcome to JellyClub!")
                            .font(.title)
                        Text("Before you join, let's get you acquainted.")
                        Text("Consider it a form of initiation 😛")
                        Spacer()
                    }
                }()
                    .tabItem{}
                    .tag(1)
                Text("Just kidding! We haven't set this up yet...\n\nJust tap the button below to get started.")
                    .tabItem{}
                    .tag(2)
                // This needs to remain empty, it's our last view that triggers the onboarding's dismissal
                Text("")
                    .onAppear {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .tag(3)
            }
                .tabViewStyle(.page)
            Spacer()
            Button(action: {
                withAnimation {
                    tabSelection += 1
                }
            }) {
                Image(systemName: "arrow.right")
                    .resizable()
                    .aspectRatio(1.0,contentMode: .fit)
                    .frame(width: 75)
            }
        }
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen()
    }
}
