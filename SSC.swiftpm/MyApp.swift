import SwiftUI

@main
struct MyApp: App {
    @State private var onboardingPresented = true

    var body: some Scene {
        WindowGroup {
            if #available(iOS 16.0, *) {
                ContentView()
                    .sheet(isPresented: $onboardingPresented) {
                        VStack(spacing: 16) {
                            Text("About Graph Theory").font(.largeTitle).bold()
                            
                            Grid() {
                                GridRow {
                                    Image(systemName: "viewfinder").font(.system(size: 60))
                                    Text("Welcome to Graph Theory App, where you can learn about graphs and their amazing properties by creating, manipulating, and analyzing them with various tools and algorithms.").frame(maxWidth: .infinity, alignment: .leading)
                                }.padding(10)
                                GridRow {
                                    Image(systemName: "eye").font(.system(size: 60))
                                    Text("As a visual learner myself, I have created this app to share my passion for graph theory with you, a simple but powerful mathematical structure that can help you understand the world better by allowing you to have fun by making your own graphs or visualizing data in different ways.").frame(maxWidth: .infinity, alignment: .leading)
                                }.padding(10)
                            }.padding(20)
                                
                             Text("Are you ready to start your graph theory adventure? Let’s go!")
                            // Spacer()

                            Button {
                                withAnimation {
                                    onboardingPresented = false
                                }
                            } label: {
                                Text("Lets start!")
                            }.buttonStyle(.borderedProminent).controlSize(.large)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
            } else {
                // Fallback on earlier versions
                Text("Only supported on iOS 16.0 and above.")
            }
        }
    }
}
