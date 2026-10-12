// MasonryGrid.swift
// NotesApp
//
// Two-column masonry (Pinterest-style) layout.
// Cards are placed into the shorter column to achieve natural height variation.

import SwiftUI

struct MasonryGrid<Item: Identifiable, Content: View>: View {

    let items: [Item]
    let columns: Int
    let spacing: CGFloat
    @ViewBuilder let content: (Item, CGFloat) -> Content

    var body: some View {
        GeometryReader { geo in
            let totalSpacing = spacing * CGFloat(columns - 1) + AppSpacing.lg * 2
            let columnWidth  = (geo.size.width - totalSpacing) / CGFloat(columns)

            MasonryLayout(
                items: items,
                columns: columns,
                spacing: spacing,
                columnWidth: columnWidth,
                content: content
            )
        }
    }
}

// MARK: - Internal Layout Engine

private struct MasonryLayout<Item: Identifiable, Content: View>: View {

    let items: [Item]
    let columns: Int
    let spacing: CGFloat
    let columnWidth: CGFloat
    @ViewBuilder let content: (Item, CGFloat) -> Content

    @State private var columnHeights: [CGFloat] = []
    @State private var positions: [(x: CGFloat, y: CGFloat)] = []
    @State private var totalHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                if idx < positions.count {
                    content(item, columnWidth)
                        .offset(
                            x: positions[idx].x + AppSpacing.lg,
                            y: positions[idx].y
                        )
                        .background(
                            GeometryReader { cardGeo in
                                Color.clear
                                    .preference(
                                        key: CardHeightKey.self,
                                        value: [idx: cardGeo.size.height]
                                    )
                            }
                        )
                }
            }
        }
        .frame(height: totalHeight)
        .onPreferenceChange(CardHeightKey.self) { heights in
            updatePositions(with: heights)
        }
        .onAppear {
            // Initialise with zero heights to trigger layout pass
            columnHeights = Array(repeating: 0, count: columns)
            positions = Array(repeating: (0, 0), count: items.count)
        }
    }

    private func updatePositions(with heights: [Int: CGFloat]) {
        guard !columnHeights.isEmpty else { return }

        var cols = columnHeights
        var pos  = positions

        for (idx, _) in items.enumerated() {
            guard let h = heights[idx] else { continue }
            let shortestCol = cols.indices.min(by: { cols[$0] < cols[$1] }) ?? 0
            let xOffset = CGFloat(shortestCol) * (columnWidth + spacing)
            pos[idx] = (xOffset, cols[shortestCol])
            cols[shortestCol] += h + spacing
        }

        columnHeights = cols
        positions     = pos
        totalHeight   = (cols.max() ?? 0)
    }
}

// MARK: - Preference Key for card heights

private struct CardHeightKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}
