import SwiftUI

struct YogaView: View {
    let emotion: String
    let description: String
    
    @State private var yogaInstructions: String = "Loading instructions..."
    @State private var yogaSteps: [String] = []
    @State private var yogaImages: [URL] = []
    @State private var isLoading = true
    @State private var currentPage = 0
    
    let openAIService = OpenAIService()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.25, green: 0.0, blue: 0.5),  // deep purple
                    Color(red: 0.1, green: 0.2, blue: 0.8)     // vibrant blue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                Text("Yoga for \(emotion)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                if isLoading {
                    ProgressView("Preparing your session...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .padding()
                } else {
                    // Image carousel at the top
                    if !yogaImages.isEmpty {
                        TabView(selection: $currentPage) {
                            ForEach(Array(yogaImages.enumerated()), id: \.offset) { index, url in
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.main.bounds.width * 0.85, height: 250)
                                            .clipped()
                                            .cornerRadius(15)
                                            .shadow(radius: 8)
                                    } else if phase.error != nil {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: UIScreen.main.bounds.width * 0.85, height: 250)
                                            .foregroundColor(.gray)
                                    } else {
                                        ProgressView()
                                            .frame(width: UIScreen.main.bounds.width * 0.85, height: 250)
                                    }
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(height: 250)
                    }
                    
                    // Instructions card
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Step-by-Step Instructions")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            if !yogaSteps.isEmpty {
                                ForEach(Array(yogaSteps.enumerated()), id: \.offset) { index, step in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("\(index + 1).")
                                            .font(.headline)
                                            .foregroundColor(.yellow)
                                        Text(step)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding(.vertical, 4)
                                }
                            } else {
                                Text(yogaInstructions)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.35))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
            .padding()
        }
        // Rely on the parent NavigationStack for the back button.
        .navigationTitle("Yoga Session")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadYogaContent()
        }
    }
    
    // MARK: - Content Loading
    
    func loadYogaContent() {
        isLoading = true
        
        let prompt = """
        I am feeling \(emotion) mood. Suggest one yoga pose to help improve this mood. Provide a detailed description including benefits and clear, step-by-step bullet instructions.Also try making texts more good looking and add emojis to the text to grab user atraction.
        """
        
        openAIService.fetchInput(for: prompt, token: 300) { response in
            DispatchQueue.main.async {
                if let response = response {
                    let steps = response.components(separatedBy: "\n")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    if steps.count > 1 {
                        yogaSteps = steps
                    } else {
                        yogaInstructions = response
                    }
                } else {
                    yogaInstructions = "Failed to load instructions."
                }
                loadYogaImages()
            }
        }
    }
    
    func loadYogaImages() {
        let imagePrompt = """
        Generate 4 high-quality images showing step-by-step instructions for performing a yoga pose that helps with a \(emotion) mood. Each image should clearly depict one step in an appealing style.
        """
        
        openAIService.fetchImages(for: imagePrompt, count: 4) { imageURLs in
            DispatchQueue.main.async {
                yogaImages = imageURLs
                isLoading = false
            }
        }
    }
}
