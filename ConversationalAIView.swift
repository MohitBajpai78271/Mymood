import SwiftUI

struct ConversationalAIView: View {
    let emotion: String
    let description: String // Pre-filled input prompt for AI
    @State private var aiResponse: String = "Let me help you with some suggestions!" // Placeholder AI response
    @State private var isLoading = true // Simulate loading AI response
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Detected Emotion")
                .font(.headline)
            
            Text(emotion)
                .font(.system(size: 60))
                .padding(.bottom, 10)
            
            Text("AI Suggestions")
                .font(.title3)
                .bold()
            
            if isLoading {
                ProgressView("Analyzing your mood...")
                    .padding()
            } else {
                ScrollView {
                    Text(aiResponse)
                        .font(.body)
                        .padding()
                    
                    Button(action: {
                        // Example: Open a YouTube link
                        if let url = URL(string: "https://www.youtube.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.rectangle")
                                .foregroundColor(.white)
                            Text("Watch a Calming Video")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Example: Open a Spotify link
                        if let url = URL(string: "https://www.spotify.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundColor(.white)
                            Text("Listen to Relaxing Music")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            loadAIResponse()
        }
    }
    
    func loadAIResponse() {
        // Simulate AI response delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            aiResponse = """
            I'm sorry you're feeling this way. Try these steps:
            - Take a 10-minute walk.
            - Try deep breathing exercises.
            - Watch this: [Relaxing Video].
            """
            isLoading = false
        }
    }
}
