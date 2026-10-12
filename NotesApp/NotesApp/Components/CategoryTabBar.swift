// CategoryTabBar.swift
// NotesApp
//
// Pill-shaped filter tabs for All / Important / Bookmarked.

import SwiftUI

struct CategoryTabBar: View {

    @Binding var selected: NoteCategory
    let counts: [NoteCategory: Int]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(NoteCategory.allCases, id: \.self) { category in
                    TabPill(
                        title: label(for: category),
                        isActive: selected == category
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selected = category
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }

    // MARK: - Helpers

    private func label(for category: NoteCategory) -> String {
        let count = counts[category] ?? 0
        switch category {
        case .all:        return "All (\(count))"
        case .important:  return "Important"
        case .bookmarked: return "Bookmarked"
        }
    }
}

// MARK: - Tab Pill

private struct TabPill: View {
    let title: String
    let isActive: Bool

    var body: some View {
        Text(title)
            .font(AppFont.tab())
            .foregroundStyle(isActive ? Color.white : Color.primaryText.opacity(0.55))
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(isActive ? Color.primaryText : Color.surfaceSecondary)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
    }
}

#Preview {
    CategoryTabBar(
        selected: .constant(.all),
        counts: [.all: 20, .important: 5, .bookmarked: 3]
    )
    .padding()
    .background(Color.black)
}
