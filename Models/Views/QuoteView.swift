//
//  ContentView.swift
//  Quote_Generator
//
//  Created by Jahaan Suthar on 7/8/26.
//
import SwiftData
import SwiftUI

struct QuoteView: View {
    @State private var quote = "tap the button to get inspired."
    
    let quotes = [
        "Success is not final. Failure is not fatal.",
        "Dream big. Start small.",
        "Stay hungry. Stay foolish.",
        "Discipline beats motivation.",
        "Believe in yourself.",
        "Every day brings new choices. — Martha Beck",
    "The secret of your success is determined by your daily agenda.” — John C. Maxwell",
        "Every day is a new opportunity.  You can build on yesterday's success or put its failures behind and start over again. — Bob Feller",
        "In every day, there are 1,440 minutes.  That means we have 1,440 daily opportunities to make a positive impact. — Les Brown"
  
    ]
    var body: some View {
        ZStack{
            LinearGradient(
                colors: [.blue.opacity(0.3), .yellow],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            
            VStack(spacing : 20) {
                Image(systemName: "book.fill")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                Text("This app is a Quote generator")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom ,200)
                
                Text ("Daily Quote")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(quote)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(height: 140)
                    .background(.yellow.opacity(1))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                
                Button("New Quote"){
                    quote = quotes.randomElement()!
                    
                }
                . tint(.green)
                .buttonStyle(.borderedProminent)
                
                NavigationLink {

                    AdminView()

                } label: {

                    Label("View Database", systemImage: "externaldrive")

                }
                .padding(.top, 20)
            }
            
            .padding()
        }
    }
}

#Preview {
    QuoteView()
}
