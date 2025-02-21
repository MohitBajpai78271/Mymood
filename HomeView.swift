import SwiftUI
import CoreHaptics
import CoreMotion

struct HomeView: View {
    @State private var lastSessionSummary = "Your heart rate was 72 bpm, and you achieved 3 minutes of calm."
    @State private var isSessionActive = false
    @State private var scaleEffect: CGFloat = 1.0
    @State private var engine: CHHapticEngine?
    @State private var motionManager = CMMotionManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedBackground()
                
                VStack(spacing: 40) {
                    Text("MoodMate")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .shadow(radius: 15)
                        .padding(.top, 40)
                        .onAppear(perform: prepareHaptics)
                        
                    HStack(spacing: 20) {
                        NavigationLink(destination: EmotionDetectionView()) {
                            FlashCard(
                                title: "Emotion Detection",
                                description: "Understand your emotions through live detection.",
                                iconName: "face.smiling.fill",
                                gradientColors: [Color.orange, Color.pink]
                            )
                        }
                        
                        NavigationLink(destination: InsightsView()) {
                            FlashCard(
                                title: "Mood Trends",
                                description: "Track your mood progress and trends.",
                                iconName: "chart.bar.fill",
                                gradientColors: [Color.purple, Color.blue]
                            )
                        }
                    }
                    .onAppear(perform: startDeviceMotion)
                    
                    NavigationLink(destination: StorytellingView()) {
                        Text("Begin Emotion Modulation")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .cornerRadius(30)
                            .shadow(radius: 20)
                            .scaleEffect(scaleEffect)
                    }
                    .padding(.horizontal)
                    .simultaneousGesture(
                        LongPressGesture().onEnded { _ in
                            triggerHapticFeedback()
                        }
                    )
                    
                    VStack(spacing: 12) {
                        Text("Last Session Summary")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.85))
                        
                        Text(lastSessionSummary)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("About the App")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.5)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .cornerRadius(25)
                        .shadow(radius: 8)
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
        }
    }
    
    func prepareHaptics() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics not supported: \(error.localizedDescription)")
        }
    }
    
    func triggerHapticFeedback() {
        let pattern = try? CHHapticPattern(events: [
            CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
        ], parameters: [])
        
        do {
            let player = try engine?.makePlayer(with: pattern!)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error.localizedDescription)")
        }
    }
    
    func startDeviceMotion() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1/60
            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
                guard let motion = motion else { return }
                
                let pitch = motion.attitude.pitch
                self.scaleEffect = 1 + CGFloat(pitch) * 0.1
            }
        }
    }
}

struct AnimatedBackground: View {
    @State private var animate = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)]),
            startPoint: animate ? .top : .bottom,
            endPoint: animate ? .bottom : .top
        )
        .ignoresSafeArea()
        .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true))
        .onAppear {
            animate.toggle()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
struct FlashCard: View {
    var title: String
    var description: String
    var iconName: String
    var gradientColors: [Color]
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                    .shadow(color: gradientColors[1].opacity(0.7), radius: 10, x: 0, y: 8)
                
                Image(systemName: iconName)
                    .font(.system(size: 48))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 10) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(BlurView(style: .systemThinMaterialDark))
        .cornerRadius(20)
        .shadow(radius: 12)
    }
}


// MARK: - Blur View Component
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        return UIVisualEffectView(effect: blurEffect)
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Optional logo image at the top.
                HStack {
                    Spacer()
                    Image("ImageIcon") // Replace with your app's logo asset name.
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                    Spacer()
                }
                .padding(.top, 20)
                
                SectionCard {
                    SectionTitle("Welcome to MoodMate!")
                    SectionText("MoodMate isn’t just an app – it’s your personal emotional health companion, crafted to empower you on your journey towards balance and well-being. We analyze your thoughts, text entries, and facial expressions to accurately capture your mood and transform it into expressive emojis that reflect exactly how you feel.")
                }
                
                SectionCard {
                    SectionTitle("How It Works")
                    SectionText("Our cutting-edge emotion detection technology delves into the nuances of your written reflections and subtle facial cues. Whether you're sharing the details of your day or simply jotting down a fleeting thought, MoodMate deciphers your emotional landscape in real time and represents it in a visually engaging manner.")
                }
                
                SectionCard {
                    SectionTitle("Personalized Support at Your Fingertips")
                    SectionText("Feeling overwhelmed or in need of a boost? Tap the 'Help Me' button to receive AI-powered suggestions tailored to your current mood. Enjoy handpicked mood-relaxing YouTube videos and soothing music links that offer you a personalized sanctuary whenever you need it.")
                }
                
                SectionCard {
                    SectionTitle("Guided Yoga Routines for Your Mood")
                    SectionText("Take control of your well-being with our 'Best Yoga' feature. Get a customized yoga routine designed specifically for your emotional state. Follow clear, step-by-step instructions with vivid images that guide you through each pose, helping you alleviate stress and restore balance.")
                }
                
                SectionCard {
                    SectionTitle("Track Your Emotional Journey")
                    SectionText("MoodMate goes beyond immediate support by offering detailed mood trend analytics. Visualize your emotional journey daily, weekly, and monthly with interactive charts that highlight recurring moods and provide insights into your overall emotional balance.")
                }
                
                SectionCard {
                    SectionTitle("Why Choose MoodMate?")
                    SectionText("Built with innovation and empathy, MoodMate seamlessly blends state-of-the-art AI with a user-friendly interface to deliver timely, personalized care. Every feature is meticulously crafted to help you thrive, turning emotional awareness into a powerful tool for self-improvement.")
                }
                
                SectionCard {
                    SectionTitle("The Future of Emotional Wellness")
                    SectionText("At MoodMate, we believe understanding your emotions is the first step toward a more fulfilling life. Our ongoing commitment to innovation ensures that MoodMate continually evolves, incorporating the latest in emotional analytics to provide you with unparalleled support. Join us and redefine your emotional journey.")
                }
                
                SectionCard {
                    SectionTitle("Get Started Today")
                    SectionText("Embark on your path to emotional balance with MoodMate. Explore your moods, receive personalized guidance, and unlock the tools to elevate your well-being. Welcome to a new era of self-care – welcome to MoodMate!")
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(
            // A beautiful gradient background for a modern feel.
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

// MARK: - Reusable Section Components

struct SectionCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content
        }
        .padding()
        .background(Color.white.opacity(0.85))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct SectionTitle: View {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.black)
    }
}

struct SectionText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.body)
            .foregroundColor(.black)
            .multilineTextAlignment(.leading)
    }
}

