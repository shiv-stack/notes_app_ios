// NoteDetailView.swift
// NotesApp
//
// Detail screen shown when a note card is tapped.
// Displays the full note content with an editable checklist
// and a bottom toolbar replicating the reference design.

import SwiftUI
import SwiftData

struct NoteDetailView: View {

    // MARK: - Inputs

    @Bindable var note: Note
    let viewModel: NotesViewModel

    // MARK: - Environment

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)       private var dismiss

    // MARK: - Local State

    @State private var newChecklistItemText = ""
    @State private var showDeleteAlert     = false
    @State private var isEditing           = false
    @State private var editedTitle         = ""
    @State private var editedBody          = ""
    @FocusState private var isNewItemFocused: Bool
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isBodyFocused: Bool

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("DetailBackground").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {

                    // --- Title ---
                    if isEditing {
                        TextField("Title", text: $editedTitle, axis: .vertical)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "#1A1A2E"))
                            .padding(.horizontal, AppSpacing.xl)
                            .padding(.top, AppSpacing.xl)
                            .focused($isTitleFocused)
                    } else {
                        Text(note.title)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "#1A1A2E"))
                            .padding(.horizontal, AppSpacing.xl)
                            .padding(.top, AppSpacing.xl)
                    }

                    // --- Body ---
                    if isEditing {
                        ZStack(alignment: .topLeading) {
                            if editedBody.isEmpty {
                                Text("Write your note here…")
                                    .font(AppFont.body())
                                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.3))
                                    .padding(.horizontal, AppSpacing.xl)
                                    .padding(.top, 8)
                            }
                            TextEditor(text: $editedBody)
                                .font(AppFont.body())
                                .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.8))
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 120)
                                .padding(.horizontal, AppSpacing.lg)
                                .focused($isBodyFocused)
                        }
                    } else if !note.body.isEmpty {
                        Text(note.body)
                            .font(AppFont.body())
                            .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.75))
                            .lineSpacing(6)
                            .padding(.horizontal, AppSpacing.xl)
                    }

                    // --- Checklist Items ---
                    if note.isChecklist {
                        checklistSection
                    }

                    // Spacer for toolbar
                    Spacer(minLength: 120)
                }
            }
            .scrollIndicators(.hidden)

            // --- Bottom Toolbar ---
            bottomToolbar
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        startEditing()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 17, weight: .semibold))
                }
            }

            // Show Save/Cancel when editing
            ToolbarItem(placement: .navigationBarLeading) {
                if isEditing {
                    Button("Cancel") {
                        cancelEditing()
                    }
                    .foregroundStyle(.secondary)
                }
            }

            ToolbarItem(placement: .principal) {
                if isEditing {
                    Button("Save") {
                        saveEdits()
                    }
                    .font(.system(size: 15, weight: .semibold))
                }
            }
        }
        .alert("Delete Note?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteNote(note, context: context)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Edit Helpers

    private func startEditing() {
        editedTitle = note.title
        editedBody  = note.body
        isEditing   = true
        isTitleFocused = true
    }

    private func saveEdits() {
        let trimmedTitle = editedTitle.trimmingCharacters(in: .whitespaces)
        if !trimmedTitle.isEmpty {
            note.title = trimmedTitle
        }
        note.body = editedBody.trimmingCharacters(in: .whitespaces)
        isEditing = false
    }

    private func cancelEditing() {
        isEditing = false
    }

    // MARK: - Checklist Section

    @ViewBuilder
    private var checklistSection: some View {
        let sortedItems = note.checklistItems.sorted { $0.orderIndex < $1.orderIndex }

        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ForEach(sortedItems) { item in
                ChecklistRow(item: item) {
                    viewModel.toggleChecklistItem(item)
                }
            }

            // New item input
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.35))

                TextField("Tap here to continue", text: $newChecklistItemText)
                    .font(AppFont.body())
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.55))
                    .focused($isNewItemFocused)
                    .onSubmit { addNewChecklistItem() }
            }
            .padding(.horizontal, AppSpacing.xl)
        }
        .padding(.horizontal, AppSpacing.xl - AppSpacing.lg)
    }

    // MARK: - Bottom Toolbar

    private var bottomToolbar: some View {
        HStack {
            Spacer()

            toolbarItem(icon: "camera")
            Spacer()
            toolbarItem(icon: "pencil")
            Spacer()
            toolbarItem(icon: "paperclip")
            Spacer()
            toolbarItem(icon: "checklist")
            Spacer()

            FABButton(systemImage: "plus", action: {
                isNewItemFocused = true
            })

            Spacer()
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: -4)
        )
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.xl)
    }

    private func toolbarItem(icon: String) -> some View {
        Button {} label: {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.65))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func addNewChecklistItem() {
        let trimmed = newChecklistItemText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let newItem = ChecklistItem(
            text: trimmed,
            orderIndex: note.checklistItems.count
        )
        newItem.note = note
        context.insert(newItem)
        note.checklistItems.append(newItem)
        newChecklistItemText = ""
    }
}

// MARK: - Checklist Row

private struct ChecklistRow: View {
    @Bindable var item: ChecklistItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        item.isCompleted
                        ? Color(hex: "#5B5EA6")
                        : Color(hex: "#1A1A2E").opacity(0.35)
                    )
                    .animation(.spring(response: 0.25), value: item.isCompleted)
            }
            .buttonStyle(.plain)

            Text(item.text)
                .font(AppFont.body())
                .foregroundStyle(Color(hex: "#1A1A2E").opacity(item.isCompleted ? 0.4 : 0.8))
                .strikethrough(item.isCompleted, color: Color(hex: "#1A1A2E").opacity(0.4))
                .animation(.easeInOut(duration: 0.2), value: item.isCompleted)
        }
        .padding(.horizontal, AppSpacing.xl)
    }
}
