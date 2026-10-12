// NoteCard.swift
// NotesApp
//
// Reusable card view rendered inside the masonry / grid layout.
// Adapts its content based on whether the note is a checklist or text note,
// and whether it has an image attachment.

import SwiftUI

struct NoteCard: View {

    let note: Note
    /// Width is injected by the parent grid to allow responsive sizing.
    let width: CGFloat

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {

            // --- Image Attachment ---
            if let imageData = note.imageData,
               let uiImage  = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
            }

            // --- Title ---
            Text(note.title)
                .font(AppFont.title2())
                .foregroundStyle(Color(hex: "#1A1A2E"))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            // --- Body or Checklist ---
            if note.isChecklist && !note.checklistItems.isEmpty {
                checklistPreview
            } else if !note.body.isEmpty {
                Text(note.body)
                    .font(AppFont.body())
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.7))
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(AppSpacing.lg)
        .frame(width: width, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(Color.cardColor(named: note.cardColorName))
        )
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 3)
    }

    // MARK: - Checklist Preview (shows up to 3 items)

    @ViewBuilder
    private var checklistPreview: some View {
        let sortedItems = note.checklistItems.sorted { $0.orderIndex < $1.orderIndex }
        let previewItems = Array(sortedItems.prefix(3))

        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            ForEach(previewItems) { item in
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14))
                        .foregroundStyle(
                            item.isCompleted
                            ? Color(hex: "#5B5EA6")
                            : Color(hex: "#1A1A2E").opacity(0.4)
                        )
                    Text(item.text)
                        .font(AppFont.body())
                        .foregroundStyle(Color(hex: "#1A1A2E").opacity(item.isCompleted ? 0.45 : 0.75))
                        .strikethrough(item.isCompleted)
                        .lineLimit(1)
                }
            }
            if sortedItems.count > 3 {
                Text("+ \(sortedItems.count - 3) more")
                    .font(AppFont.caption())
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.4))
            }
        }
    }
}
