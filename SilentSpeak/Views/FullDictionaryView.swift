import SwiftUI

struct FullDictionaryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: ASLDictionaryEntry.SignCategory? = nil
    @State private var selectedEntry: ASLDictionaryEntry?
    @State private var animateIn = false
    @State private var showEssentialOnly = true // Default to essential signs only
    
    var filteredEntries: [ASLDictionaryEntry] {
        var entries = showEssentialOnly ? FullASLDictionary.essentialSigns : FullASLDictionary.all
        if let cat = selectedCategory { entries = entries.filter { $0.category == cat } }
        if !searchText.isEmpty {
            entries = entries.filter {
                $0.word.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }
        return entries
    }
    
    var availableCategories: [ASLDictionaryEntry.SignCategory] {
        return showEssentialOnly ? FullASLDictionary.essentialCategories : ASLDictionaryEntry.SignCategory.allCases
    }
    
    var body: some View {
        ZStack {
            AnimatedGradientView(colors: [
                DS.Colors.backgroundPrimary,
                DS.Colors.backgroundSecondary,
                DS.Colors.accent.opacity(0.06)
            ])
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Category filter pills
                categoryPills
                    .padding(.top, 4)
                
                // Essential/All toggle
                HStack {
                    Button(action: {
                        HapticManager.shared.selection()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showEssentialOnly.toggle()
                            selectedCategory = nil // Reset category when switching
                            animateIn = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation { animateIn = true }
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: showEssentialOnly ? "star.fill" : "square.grid.3x3.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text(showEssentialOnly ? "Essential Signs" : "All Signs")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(showEssentialOnly ? .white : DS.Colors.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(showEssentialOnly ? AnyShapeStyle(DS.Colors.accentGradient) : AnyShapeStyle(DS.Colors.cardBackground.opacity(0.85)))
                                .shadow(color: showEssentialOnly ? DS.Colors.accent.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(BouncyPressStyle())
                    
                    Spacer()
                    
                    Text("\(filteredEntries.count) signs")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(DS.Colors.textTertiary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
                
                // Grid of signs
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { i, entry in
                            SignCard(entry: entry)
                                .onTapGesture {
                                    HapticManager.shared.lightImpact()
                                    selectedEntry = entry
                                }
                                .scaleEffect(animateIn ? 1 : 0.85)
                                .opacity(animateIn ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(i % 12) * 0.03), value: animateIn)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(item: $selectedEntry) { entry in
            SignDetailSheet(entry: entry)
        }
        .onAppear {
            withAnimation { animateIn = true }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ASL Dictionary")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(DS.Colors.accentGradient)
                    Text(showEssentialOnly ? "Essential signs for beginners" : "\(FullASLDictionary.all.count) signs with instructions")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DS.Colors.textTertiary)
                }
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(DS.Colors.cardBackground)
                        .frame(width: 42, height: 42)
                        .shadow(color: DS.Colors.accent.opacity(0.12), radius: 8, x: 0, y: 3)
                    Image(systemName: "hand.raised.fingers.spread.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(DS.Colors.accentGradient)
                }
            }
            .padding(.horizontal, 20)
            
            // Search
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DS.Colors.textTertiary)
                TextField("Search signs...", text: $searchText)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DS.Colors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(DS.Colors.cardBackground)
                    .shadow(color: DS.Colors.accent.opacity(0.08), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal, 16)
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Category Pills
    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryPill(nil, label: "All", icon: "square.grid.2x2")
                ForEach(availableCategories, id: \.self) { cat in
                    categoryPill(cat, label: cat.rawValue, icon: cat.icon)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func categoryPill(_ cat: ASLDictionaryEntry.SignCategory?, label: String, icon: String) -> some View {
        let isSelected = selectedCategory == cat
        return Button(action: {
            HapticManager.shared.selection()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = isSelected ? nil : cat
                animateIn = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation { animateIn = true }
                }
            }
        }) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(label)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : DS.Colors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isSelected ? AnyShapeStyle(DS.Colors.accentGradient) : AnyShapeStyle(DS.Colors.cardBackground.opacity(0.85)))
                    .shadow(color: isSelected ? DS.Colors.accent.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(BouncyPressStyle())
    }
}

// MARK: - Sign Card (Grid Item)
struct SignCard: View {
    let entry: ASLDictionaryEntry
    
    var body: some View {
        VStack(spacing: 0) {
            // Image area
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(DS.Colors.surfaceThin)
                    .frame(height: 120)
                
                signImage
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // Label
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.word)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
                    .lineLimit(1)
                
                Text(entry.category.rawValue)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(DS.Colors.accent)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(DS.Colors.cardBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
    
    @ViewBuilder
    private var signImage: some View {
        if let assetName = entry.imageAssetName, let image = ASLImageLoader.loadImage(for: assetName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if let urlStr = entry.lifeprintURL, let url = URL(string: urlStr) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().aspectRatio(contentMode: .fit)
                case .failure:
                    fallbackStrip
                case .empty:
                    ProgressView().scaleEffect(0.7)
                @unknown default:
                    fallbackStrip
                }
            }
        } else {
            fallbackStrip
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 6) {
            Text(entry.word.count == 1 ? entry.word : String(entry.word.prefix(2)))
                .font(.system(size: entry.word.count == 1 ? 44 : 28, weight: .black, design: .rounded))
                .foregroundStyle(DS.Colors.accentGradient)
            if entry.word.count > 1 {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 16))
                    .foregroundColor(DS.Colors.accent.opacity(0.4))
            }
        }
    }
    
    private var fallbackStrip: some View {
        VStack(spacing: 8) {
            ASLFingerspellingStrip(text: entry.word, cardSize: 34)
            if entry.word.count > 1 {
                Text("Fingerspelling fallback")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(DS.Colors.textTertiary)
            }
        }
    }
}

// MARK: - Sign Detail Sheet
struct SignDetailSheet: View {
    let entry: ASLDictionaryEntry
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                DS.Colors.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Large image
                        ZStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(DS.Colors.surfaceThin)
                                .frame(height: 280)
                            
                            signImage
                                .frame(maxHeight: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .padding(.horizontal, 20)
                        
                        // Word + category
                        VStack(spacing: 8) {
                            Text(entry.word)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundStyle(DS.Colors.accentGradient)
                            
                            Label(entry.category.rawValue, systemImage: entry.category.icon)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(DS.Colors.accent)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(DS.Colors.accent.opacity(0.12)))
                        }
                        
                        // How to sign it
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundColor(DS.Colors.accent)
                                Text("How to Sign")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(DS.Colors.textPrimary)
                            }
                            
                            Text(entry.description)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(DS.Colors.textSecondary)
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(DS.Colors.cardBackground)
                        )
                        .padding(.horizontal, 20)
                        
                        // Source credit
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 12))
                            Text("Source: Lifeprint.com — Dr. Bill Vicars (ASL University)")
                                .font(.system(size: 11))
                                .foregroundColor(DS.Colors.textTertiary)
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle(entry.word)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(DS.Colors.accent)
                }
            }
        }
    }
    
    @ViewBuilder
    private var signImage: some View {
        if let assetName = entry.imageAssetName, let image = ASLImageLoader.loadImage(for: assetName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if let urlStr = entry.lifeprintURL, let url = URL(string: urlStr) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().aspectRatio(contentMode: .fit)
                case .failure:
                    fallbackLarge
                case .empty:
                    ProgressView()
                @unknown default:
                    fallbackLarge
                }
            }
        } else {
            fallbackLarge
        }
    }
    
    private var placeholderLarge: some View {
        VStack(spacing: 10) {
            Text(entry.word.count <= 2 ? entry.word : String(entry.word.prefix(3)))
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(DS.Colors.accentGradient)
            Text("No image available")
                .font(.system(size: 12))
                .foregroundColor(DS.Colors.textTertiary)
        }
    }
    
    private var fallbackLarge: some View {
        VStack(spacing: 16) {
            ASLFingerspellingStrip(text: entry.word, cardSize: 56)
            Text("Showing bundled fingerspelling reference")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(DS.Colors.textTertiary)
        }
        .padding(.horizontal, 12)
    }
}

struct ASLFingerspellingStrip: View {
    let text: String
    var cardSize: CGFloat = 40
    
    private var signs: [ASLSignImage] {
        ASLTextConverter.convertToASL(text)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: max(6, cardSize * 0.18)) {
                ForEach(signs) { sign in
                    ImprovedWordHandCard(sign: sign, accentColor: DS.Colors.accent, waveColor: DS.Colors.accentLight, cardSize: cardSize)
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    FullDictionaryView()
}
