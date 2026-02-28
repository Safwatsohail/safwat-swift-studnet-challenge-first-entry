import SwiftUI

struct RootTabView: View {
    @ObservedObject var store: ConversationStore
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, sound, dictionary
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(store: store)
                    .tag(Tab.home)
                
                SoundDetectionView()
                    .tag(Tab.sound)
                
                FullDictionaryView()
                    .tag(Tab.dictionary)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Custom floating tab bar
            customTabBar
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(tab: .home, icon: "bubble.left.and.text.bubble.right.fill", label: "Chats")
            tabButton(tab: .sound, icon: "waveform.badge.exclamationmark", label: "Alerts")
            tabButton(tab: .dictionary, icon: "hand.raised.fingers.spread.fill", label: "Signs")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 25)
    }
    
    private func tabButton(tab: Tab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == tab
        return Button(action: {
            HapticManager.shared.selection()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(DS.Colors.accentGradient)
                            .frame(width: 50, height: 30)
                            .shadow(color: DS.Colors.accent.opacity(0.4), radius: 8, x: 0, y: 3)
                            .transition(.scale.combined(with: .opacity))
                    }
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .white : DS.Colors.textTertiary)
                }
                Text(label)
                    .font(.system(size: 9, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? DS.Colors.accent : DS.Colors.textTertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(BouncyPressStyle())
    }
}
