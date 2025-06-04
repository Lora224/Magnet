import SwiftUI
import SwiftData

struct CounterView: View {
    @Environment(\.modelContext) private var context
    @Query private var counters: [Counter]
    
    var body: some View {
        VStack(spacing: 20) {
            if let counter = counters.first {
                Text("Value: \(counter.value)")
                    .font(.largeTitle)
                
                Button("Add +1") {
                    counter.value += 1
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            print("🟡 View appeared, counters count = \(counters.count)")
            
            if counters.isEmpty {
                let new = Counter(value: 0)
                context.insert(new)
                try? context.save()
                print("🟢 Created new counter.")
            } else {
                print("✅ Counter exists: \(counters.first?.value ?? -1)")
            }
        }

    }
}

#Preview {
    CounterView()
        .modelContainer(for: Counter.self)
}
