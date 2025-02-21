import SwiftUI

struct ChatView: View {
    @State private var messages: [Message] = []
    @State private var userMessage: String = ""
    @State private var isTyping: Bool = false
    
    var body: some View {
        VStack {
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    Text(message.content)
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(16)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                } else {
                                    Text(message.content)
                                        .padding()
                                        .foregroundColor(.primary)
                                        .background(Color.secondary.opacity(0.2))
                                        .cornerRadius(16)
                                        .frame(maxWidth: 250, alignment: .leading)
                                    Spacer()
                                }
                            }
                        }
                        if isTyping {
                            HStack {
                                Spacer()
                                Text("Bot is typing...")
                                    .italic()
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .id("chatScrollView")
                }
                .onChange(of: messages) {
                    if let lastMessage = messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }

            }
            
            // Text input field and send button
            HStack {
                TextField("Type a message...", text: $userMessage)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .foregroundColor(.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(userMessage.isEmpty)
            }
            .padding()
        }
        .navigationTitle("MoodMate AI")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray5)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    // Send message function
    private func sendMessage() {
        guard !userMessage.isEmpty else { return }
        
        let userMessageObject = Message(content: userMessage, isUser: true)
        messages.append(userMessageObject)
        userMessage = ""
        isTyping = true
        
        // Simulate bot response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let botMessage = Message(content: "I'm here to brighten your day! 😊", isUser: false)
            messages.append(botMessage)
            isTyping = false
        }
    }
}

struct Message: Identifiable,Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            ChatView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark) // Test in Dark Mode
        ContentView()
            .preferredColorScheme(.light) // Test in Light Mode
    }
}
