import SwiftUI

struct HomeView: View {
    @ObservedObject var store: ConversationStore
    @State private var selectedConversation: Conversation?
    @State private var showSettings = false
    @State private var searchText = ""
    @State private var showDeleteAlert = false
    @State private var conversationToDelete: Conversation?
    @State private var animateCards = false
    @State private var animateHeader = false
    
    var filteredConversations: [Conversation] {
        if searchText.isEmpty { return store.conversations }
        return store.conversations.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.lastMessagePreview.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Professional medical gradient - warm, calm
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.95, blue: 0.92),
                        Color(red: 0.96, green: 0.91, blue: 0.86),
                        Color(red: 0.94, green: 0.88, blue: 0.82)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    if store.conversations.isEmpty {
                        emptyStateView
                    } else {
                        conversationsList
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedConversation) { conversation in
                ConversationView(store: store, conversationId: conversation.id)
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
            .alert("Delete Conversation", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let convo = conversationToDelete {
                        HapticManager.shared.error()
                        withAnimation(DS.Animation.smooth) {
                            store.deleteConversation(convo)
                        }
                    }
                }
            } message: {
                Text("This conversation will be permanently deleted.")
            }
            .onAppear {
                withAnimation(DS.Animation.gentle) { animateHeader = true }
                withAnimation(DS.Animation.gentle.delay(0.15)) { animateCards = true }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: DS.Spacing.lg) {
            // Top row
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SilentSpeak")
                        .font(DS.Typography.largeTitle())
                        .foregroundStyle(DS.Colors.accentGradient)
                    
                    Text(greeting)
                        .font(DS.Typography.footnote())
                        .foregroundColor(DS.Colors.textTertiary)
                }
                .offset(x: animateHeader ? 0 : -30)
                .opacity(animateHeader ? 1 : 0)
                
                Spacer()
                
                HStack(spacing: DS.Spacing.md) {
                    // Settings button only
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        showSettings = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(DS.Colors.cardBackground)
                                .frame(width: 42, height: 42)
                                .shadow(color: DS.Colors.accent.opacity(0.1), radius: 8, x: 0, y: 4)
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16))
                                .foregroundColor(DS.Colors.accent)
                        }
                    }
                    .buttonStyle(BouncyPressStyle())
                }
                .offset(x: animateHeader ? 0 : 30)
                .opacity(animateHeader ? 1 : 0)
            }
            .padding(.horizontal, DS.Spacing.xxl)
            .padding(.top, DS.Spacing.lg)
            
            // Search bar
            if !store.conversations.isEmpty {
                HStack(spacing: DS.Spacing.md) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(DS.Colors.textTertiary)
                    
                    TextField("Search conversations...", text: $searchText)
                        .font(DS.Typography.subheadline())
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            withAnimation(DS.Animation.quick) { searchText = "" }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(DS.Colors.textTertiary)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(BouncyPressStyle())
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.vertical, DS.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                        .fill(DS.Colors.surfaceThin)
                )
                .padding(.horizontal, DS.Spacing.xxl)
                .opacity(animateHeader ? 1 : 0)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: DS.Spacing.xxxl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(DS.Colors.accent.opacity(0.05))
                    .frame(width: 180, height: 180)
                    .breathingScale(min: 0.94, max: 1.06, duration: 2.5)
                
                Circle()
                    .fill(DS.Colors.accent.opacity(0.08))
                    .frame(width: 130, height: 130)
                
                Image(systemName: "bubble.left.and.text.bubble.right.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(DS.Colors.accent.opacity(0.5))
                    .floatingAnimation(offset: 4, duration: 3)
            }
            
            VStack(spacing: DS.Spacing.md) {
                Text("Start Your First Conversation")
                    .font(DS.Typography.title2())
                    .foregroundColor(DS.Colors.textPrimary)
                
                Text("Tap below to begin translating between\nsign language and speech in real time")
                    .font(DS.Typography.subheadline())
                    .foregroundColor(DS.Colors.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            // New conversation button
            Button(action: {
                HapticManager.shared.mediumImpact()
                let newConvo = store.createConversation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    selectedConversation = newConvo
                }
            }) {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("New Conversation")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, DS.Spacing.xxxl)
                .padding(.vertical, DS.Spacing.lg)
                .background(
                    Capsule().fill(DS.Colors.elevatedGradient)
                )
            }
            .buttonStyle(GlowButtonStyle(primaryColor: DS.Colors.accent))
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xxl)
    }
    
    // MARK: - Conversations List
    private var conversationsList: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: DS.Spacing.sm) {
                    // Pinned
                    if !store.pinnedConversations.isEmpty {
                        DSSectionHeader(title: "Pinned", icon: "pin.fill", color: DS.Colors.accent)
                            .padding(.top, DS.Spacing.lg)
                            .staggeredAppear(index: 0, isVisible: animateCards)
                        
                        ForEach(Array(store.pinnedConversations.enumerated()), id: \.element.id) { i, convo in
                            conversationRow(convo, index: i + 1, pinned: true)
                        }
                    }
                    
                    // Recent
                    if filteredConversations.contains(where: { !$0.isPinned }) {
                        DSSectionHeader(title: "Recent", icon: "clock.fill")
                            .padding(.top, DS.Spacing.lg)
                            .staggeredAppear(index: store.pinnedConversations.count + 1, isVisible: animateCards)
                        
                        ForEach(Array(filteredConversations.filter { !$0.isPinned }.enumerated()), id: \.element.id) { i, convo in
                            conversationRow(convo, index: store.pinnedConversations.count + i + 2, pinned: false)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
            
            // FAB
            Button(action: {
                HapticManager.shared.mediumImpact()
                let newConvo = store.createConversation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    selectedConversation = newConvo
                }
            }) {
                ZStack {
                    Circle()
                        .fill(DS.Colors.elevatedGradient)
                        .frame(width: 56, height: 56)
                        .shadow(color: DS.Colors.accent.opacity(0.4), radius: 16, x: 0, y: 8)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(GlowButtonStyle(primaryColor: DS.Colors.accent))
            .padding(.trailing, DS.Spacing.xxl)
            .padding(.bottom, DS.Spacing.xxxl)
        }
    }
    
    // MARK: - Conversation Row
    private func conversationRow(_ convo: Conversation, index: Int, pinned: Bool) -> some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            selectedConversation = convo
        }) {
            HStack(spacing: DS.Spacing.lg) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(pinned ? DS.Colors.accentGradient : LinearGradient(colors: [DS.Colors.accent.opacity(0.15)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 18))
                        .foregroundColor(pinned ? .white : DS.Colors.accent)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(convo.title)
                            .font(DS.Typography.headline())
                            .foregroundColor(DS.Colors.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text(convo.formattedDate)
                            .font(DS.Typography.caption2())
                            .foregroundColor(DS.Colors.textTertiary)
                    }
                    
                    HStack {
                        Text(convo.lastMessagePreview)
                            .font(DS.Typography.footnote())
                            .foregroundColor(DS.Colors.textTertiary)
                            .lineLimit(1)
                        Spacer()
                        if convo.messageCount > 0 {
                            Text("\(convo.messageCount)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(DS.Colors.accent))
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DS.Colors.textTertiary.opacity(0.5))
            }
            .padding(DS.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .light)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                    .stroke(pinned ? DS.Colors.accent.opacity(0.2) : Color.white.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal, DS.Spacing.xl)
        }
        .buttonStyle(AnimatedPressStyle(scaleAmount: 0.98, glowColor: DS.Colors.accent))
        .contextMenu {
            Button(action: { selectedConversation = convo }) {
                Label("Open", systemImage: "bubble.left.and.bubble.right")
            }
            Button(action: {
                HapticManager.shared.selection()
                store.togglePin(convo)
            }) {
                Label(convo.isPinned ? "Unpin" : "Pin", systemImage: convo.isPinned ? "pin.slash" : "pin")
            }
            Button(role: .destructive, action: {
                conversationToDelete = convo
                showDeleteAlert = true
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .staggeredAppear(index: index, isVisible: animateCards)
    }
    
    // MARK: - Greeting
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Ready to connect"
        case 12..<17: return "Let's communicate"
        case 17..<22: return "Bridge the gap"
        default: return "Connect anytime"
        }
    }
}
