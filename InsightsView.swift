import SwiftUI
import Charts
struct InsightsView: View {
    @StateObject var vm = MoodDataStore()
    @State private var selectedTimeFrame: TimeFrame = .daily
    @State private var selectedMood: MoodEntry?
    @Namespace private var namespace
    @State private var chartAnimationProgress: CGFloat = 0
    
    enum TimeFrame: String, CaseIterable {
        case daily, weekly, monthly
    }
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Improved timeframe selector with labels
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Viewing Mode")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Picker("Time Frame", selection: $selectedTimeFrame) {
                            ForEach(TimeFrame.allCases, id: \.self) { frame in
                                Text(frame.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .onChange(of: selectedTimeFrame) { _ in
                            chartAnimationProgress = 0
                            withAnimation(.easeInOut(duration: 0.8)) {
                                chartAnimationProgress = 1
                            }
                        }
                    }
                    
                    // Chart section with clear labels
                    VStack(alignment: .leading) {
                        Text("Mood Progression")
                            .font(.headline)
                            .padding(.horizontal)
                        if filteredMoods.isEmpty {
                                   EmptyStateView()
                        } else {
                            moodChart
                                .frame(height: 320)
                                .padding(.horizontal)
                                .overlay(alignment: .topTrailing) {
                                    InteractionHint()
                                        .padding(.trailing, 20)
                                }
                        }
                        
                        MoodScaleLegend()
                            .padding(.horizontal)
                    }
                    
                    // Enhanced insights section
                    moodInsightsSection
                    DataCompletenessView(daysRecorded: vm.moodDaysCount)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Mood Evolution")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .background {
//                if vm.moods.isEmpty {
//                    EmptyStateView()
//                }
            }
        }
        .onAppear {
//            let newEntry = MoodEntry(
//                emoji: "😄",
//                moodValue: 4,
//                date: Date(), // Use current time
//                notes: ""
//            )
//            let newEntry2 = MoodEntry(
//                emoji: "😭",
//                moodValue: 0,
//                date: Date(), // Use current time
//                notes: ""
//            )
//            let newEntry3 = MoodEntry(
//                emoji: "😐",
//                moodValue: 2,
//                date: Date(), // Use current time
//                notes: ""
//            )
//            vm.moods.append(newEntry2)
//            vm.moods.append(newEntry3)
            chartAnimationProgress = 0
            withAnimation(.easeInOut(duration: 0.8)) {
                chartAnimationProgress = 1
            }
        }

    }
    
    // Add this computed property
    private var xAxisDateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeFrame {
        case .daily:
            let start = calendar.startOfDay(for: now)
            return start...now
        case .weekly:
            let start = calendar.date(byAdding: .day, value: -6, to: now)!
            return start...now
        case .monthly:
            let start = calendar.date(byAdding: .month, value: -1, to: now)!
            return start...now
        }
    }
    
    // MARK: - Chart Helper Properties
    private var timeUnit: Calendar.Component {
        switch selectedTimeFrame {
        case .daily:
            return .hour
        case .weekly:
            return .day
        case .monthly:
            // For a monthly view, using day gives finer granularity.
            return .day
        }
    }

    /// Determines the stride count (number of units between axis labels) to avoid label crowding.
    private var xAxisStrideCount: Int {
        switch selectedTimeFrame {
        case .daily:
            return 1           // label every hour
        case .weekly:
            return 1           // label every day
        case .monthly:
            return 2           // label every 2 days (adjust as needed)
        }
    }

    /// Formats the date labels on the x-axis.
    private var dateFormat: Date.FormatStyle {
        switch selectedTimeFrame {
        case .daily:
            return .dateTime.hour(.defaultDigits(amPM: .abbreviated))
        case .weekly:
            return .dateTime.weekday(.abbreviated)
        case .monthly:
            return .dateTime.day().month(.abbreviated)
        }
    }
    
    private var filteredMoods: [MoodEntry] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedTimeFrame {
        case .daily:
            return vm.moods.filter { calendar.isDate($0.date, inSameDayAs: now) }

        case .weekly:
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return [] }
            return vm.moods.filter { $0.date >= weekAgo }
            
        case .monthly:
            guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else { return [] }
            return vm.moods.filter { $0.date >= monthAgo }
        }
    }
    // MARK: - Updated Chart Code

    private var moodChart: some View {
        Chart {
            ForEach(filteredMoods) { mood in
                // Extract local values to simplify the modifiers.
                let isSelected = (selectedMood?.id == mood.id)
                let currentOpacity: Double = (selectedMood == nil) ? 1.0 : (isSelected ? 1.0 : 0.3)
                let currentLineWidth: CGFloat = isSelected ? 3 : 2
                let currentColor: Color = selectedMood?.color ?? mood.color
                
                // Draw the line using a stroke style.
                LineMark(
                    x: .value("Time", mood.date, unit: timeUnit),
                    y: .value("Mood", mood.moodValue)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(currentColor)
                .opacity(currentOpacity)
                .lineStyle(StrokeStyle(lineWidth: currentLineWidth))
                
                // Draw the point.
                PointMark(
                    x: .value("Time", mood.date, unit: timeUnit),
                    y: .value("Mood", mood.moodValue)
                )
                .symbol {
                    MoodBubble(mood: mood, isSelected: isSelected)
                }
            }
        }
        .chartXScale(domain: xAxisDateRange) // Add this line
        .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { axisValue in
                    AxisGridLine()
                    AxisValueLabel(anchor: .bottom) { // Ensures proper positioning
                        if let date = axisValue.as(Date.self) {
                            VStack(spacing: 0) { // Tightly stacked day & month
                                Text(date, format: .dateTime.day()) // Day number
                                    .font(.system(size: 9)) // Smaller font
                                    .fontWeight(.bold)
                                Text(date, format: .dateTime.month(.abbreviated)) // Month name
                                    .font(.system(size: 7)) // Even smaller font
                                    .foregroundColor(.gray)
                            }
                            .rotationEffect(.degrees(-30)) // Rotates text for better spacing
                            .frame(minWidth: 18, maxWidth: 25) // Prevents overlap
                        } else {
                            EmptyView()
                        }
                    }
                }
            }


        .chartYAxis {
            AxisMarks(position: .leading) { axisValue in
                AxisGridLine()
                AxisValueLabel {
                    if let moodValue = axisValue.as(Int.self) {
                        VStack(spacing: 2) {
                            Text(EmojiProvider.emojis[moodValue])
                                .font(.title3)
                            Text(EmojiProvider.labels[moodValue])
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        // Return an empty view if the conversion fails.
                        Text("")
                    }
                }
            }
        }
        .chartYScale(domain: 0...4)
        .chartGesture { proxy in
            DragGesture()
                .onChanged { value in
                    let location = value.location
                    // Use the proxy to determine the corresponding date.
                    if let date = proxy.value(atX: location.x, as: Date.self),
                       let mood = findClosestMood(to: date) {
                        withAnimation(.spring) {
                            self.selectedMood = mood
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut) {
                        selectedMood = nil
                    }
                }
        }
        .opacity(chartAnimationProgress)
    }


    private func findClosestMood(to date: Date) -> MoodEntry? {
        vm.moods.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
    }
    
    @ViewBuilder
    private func moodDetailPopup(_ mood: MoodEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(mood.emoji)
                    .font(.system(size: 40))
                Text(EmojiProvider.labels[mood.moodValue])
                    .font(.title3.bold())
                    .foregroundColor(mood.color)
            }
            
            Text(mood.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if !mood.notes.isEmpty {
                Text("Notes: \(mood.notes)")
                    .font(.caption)
                    .frame(maxWidth: 200)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        .transition(.scale.combined(with: .opacity))
        .accessibilityElement(children: .combine)
    }
    
    private var moodInsightsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Key Insights")
                .font(.title3.bold())
                .padding(.horizontal)
            
            HStack(spacing: 15) {
                InsightCard(
                    title: "Most Frequent Mood",
                    value: vm.mostFrequentMood,
                    secondaryText: "\(vm.mostFrequentMoodCount) times",
                    color: .blue
                )
                
                InsightCard(
                    title: "Average Mood",
                    value: vm.averageMoodEmoji,
                    secondaryText: String(format: "%.1f", vm.averageMoodValue),
                    color: .green
                )
            }
            .padding(.horizontal)
        }
    }
    
}

// MARK: - New Components
struct MoodBubble: View {
    let mood: MoodEntry
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(mood.color.opacity(0.2))
                .frame(width: isSelected ? 35 : 25)
            
            Circle()
                .fill(mood.color)
                .frame(width: isSelected ? 25 : 15)
            
            Text(mood.emoji)
                .font(.system(size: isSelected ? 16 : 12))
                .scaleEffect(isSelected ? 1.2 : 1)
        }
        .animation(.spring, value: isSelected)
    }
}

struct MoodScaleLegend: View {
    var body: some View {
        HStack {
            ForEach(0..<EmojiProvider.emojis.count, id: \.self) { index in
                HStack(spacing: 4) {
                    Text(EmojiProvider.emojis[index])
                    Text(EmojiProvider.labels[index])
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(4)
                .background(index == 2 ? Color.gray.opacity(0.1) : .clear)
                .cornerRadius(4)
            }
        }
        .padding(.top, 8)
    }
}

struct InteractionHint: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "hand.draw")
                .symbolEffect(.bounce, value: isAnimating)
            Text("Drag to inspect")
                .font(.caption)
        }
        .foregroundColor(.secondary)
        .onAppear {
            isAnimating = true
        }
    }
}

struct DataCompletenessView: View {
    let daysRecorded: Int
    
    var body: some View {
        HStack {
            ProgressView(value: min(Double(daysRecorded)/30, 1))
                .tint(.blue)
                .frame(height: 6)
            
            Text("\(daysRecorded)/30 days")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        NavigationStack{
        ContentUnavailableView {
            Label("No Mood Data", systemImage: "face.smiling")
        } description: {
            Text("Start tracking your mood to see insights and trends")
        } actions: {
            NavigationLink(destination: EmotionDetectionView()){
                Text("Add First Entry") 
            }
        }
                .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Enhanced Insight Card
struct InsightCard: View {
    let title: String
    let value: String
    let secondaryText: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(color)
                
                Spacer()
                
                Image(systemName: iconName)
                    .foregroundColor(color.opacity(0.5))
            }
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
            
            Text(secondaryText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var iconName: String {
        switch title {
        case "Most Frequent Mood": return "chart.bar.fill"
        case "Average Mood": return "chart.line.flattrend.xyaxis"
        default: return "info.circle"
        }
    }
}

// MARK: - Updated Data Models
class MoodDataStore: ObservableObject {
    @Published var moods: [MoodEntry] = []
    
    // Computed property: returns the emoji of the most frequent mood.
    var mostFrequentMood: String {
        guard !moods.isEmpty else { return "" }
        let counts = Dictionary(grouping: moods, by: { $0.moodValue })
        guard let mostFrequent = counts.max(by: { $0.value.count < $1.value.count }) else { return "" }
        return EmojiProvider.emojis[mostFrequent.key]
    }
    
    var averageMoodEmoji: String {
        let average = averageMoodValue
        let index = Int(average.rounded())
        let clampedIndex = min(max(index, 0), EmojiProvider.emojis.count - 1)
        return EmojiProvider.emojis[clampedIndex]
    }

    var mostFrequentMoodCount: Int {
        guard !moods.isEmpty else { return 0 }
        let counts = Dictionary(grouping: moods, by: { $0.moodValue })
        return counts.values.max(by: { $0.count < $1.count })?.count ?? 0
    }
    
    // Computed property: returns the average mood value.
    var averageMoodValue: Double {
        guard !moods.isEmpty else { return 0 }
        return Double(moods.reduce(0) { $0 + $1.moodValue }) / Double(moods.count)
    }
    var moodDaysCount: Int {
        let days = Set(moods.map { Calendar.current.startOfDay(for: $0.date) })
        return days.count
    }
    
    // More realistic sample data
    init() {
        let calendar = Calendar.current
        var date = calendar.startOfDay(for: Date())
        
        for _ in 0..<30 {
            let hours = Int.random(in: 0..<24)
            let newDate = calendar.date(byAdding: .hour, value: -hours, to: date)!
            let value = realisticMoodValue(for: newDate)
            
//            moods.append(MoodEntry(
//                emoji: EmojiProvider.emojis[value],
//                moodValue: value,
//                date: newDate,
//                notes: sampleNotes[value]
//            ))
            
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        }
    }
    
    private func realisticMoodValue(for date: Date) -> Int {
        let hour = Calendar.current.component(.hour, from: date)
        let base: Int
        
        switch hour {
        case 6...10: base = 3 // Morning highs
        case 11..<17: base = 2 // Afternoon slump
        case 17..<21: base = 3 // Evening recovery
        default: base = 1 // Late night lows
        }
        return min(max(base + Int.random(in: -1...1), 0), 4)
    }
}


struct EmojiProvider {
    static let emojis = ["😭", "😔", "😐", "🙂", "😄"]
    static let labels = ["Very Low", "Low", "Neutral", "High", "Very High"]
    static let noteTemplates = [
        "Feeling overwhelmed",
        "Not my best day",
        "Steady as she goes",
        "Positive vibes today",
        "On top of the world!"
    ]
}

// Sample data helpers
private let sampleNotes = [
    "Had a tough conversation with manager",
    "Slept poorly, feeling groggy",
    "Regular day, nothing special",
    "Finished project ahead of schedule!",
    "Got promoted! Celebrating with friends"
]
struct MoodEntry: Identifiable {
    let id = UUID()
    let emoji: String
    let moodValue: Int
    let date: Date
    let notes: String
    var color: Color {
        switch moodValue {
        case 0: return .red
        case 1: return .orange
        case 2: return .yellow
        case 3: return .mint
        case 4: return .green
        default: return .gray
        }
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}

