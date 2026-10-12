// AddNoteView.swift
// NotesApp
//
// Modal sheet for creating a new note.
// Supports plain text, checklist, card colour picker, and image attachment.

import SwiftUI
import SwiftData
import PhotosUI

struct AddNoteView: View {

    // MARK: - Inputs

    let viewModel: NotesViewModel

    // MARK: - Environment

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)       private var dismiss

    // MARK: - Form State

    @State private var title:             String         = ""
    @State private var noteBody:          String         = ""
    @State private var selectedCategory: NoteCategory   = .all
    @State private var isChecklist:       Bool           = false
    @State private var selectedColorName: String         = "cardPink"
    @State private var checklistItems:    [String]       = [""]

    // Image picker
    @State private var selectedPhoto:    PhotosPickerItem? = nil
    @State private var imageData:        Data?             = nil

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color("DetailBackground").ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {

                        // ---- Card Color Picker ----
                        colorPicker

                        // ---- Title ----
                        TextField("Note title…", text: $title, axis: .vertical)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "#1A1A2E"))
                            .padding(.horizontal, AppSpacing.xl)

                        // ---- Type Toggle ----
                        typeToggle

                        // ---- Body or Checklist ----
                        if isChecklist {
                            checklistEditor
                        } else {
                            bodyEditor
                        }

                        // ---- Image Attachment ----
                        imageSection

                        Spacer(minLength: 60)
                    }
                    .padding(.top, AppSpacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.6))
                }
                ToolbarItem(placement: .principal) {
                    // Category Picker
                    Picker("", selection: $selectedCategory) {
                        ForEach(NoteCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 240)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveNote() }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    // MARK: - Color Picker

    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.md) {
                ForEach(cardColorOptions) { option in
                    Circle()
                        .fill(option.color)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "#1A1A2E").opacity(0.6), lineWidth: 2)
                                .opacity(selectedColorName == option.name ? 1 : 0)
                        )
                        .onTapGesture { selectedColorName = option.name }
                }
            }
            .padding(.horizontal, AppSpacing.xl)
        }
    }

    // MARK: - Type Toggle

    private var typeToggle: some View {
        HStack(spacing: AppSpacing.sm) {
            Text("Checklist")
                .font(AppFont.tab())
                .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.65))

            Toggle("", isOn: $isChecklist.animation())
                .labelsHidden()
                .tint(Color(hex: "#5B5EA6"))
        }
        .padding(.horizontal, AppSpacing.xl)
    }

    // MARK: - Body Editor

    private var bodyEditor: some View {
        ZStack(alignment: .topLeading) {
            if noteBody.isEmpty {
                Text("Write your note here…")
                    .font(AppFont.body())
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.3))
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.top, 8)
            }
            TextEditor(text: $noteBody)
                .font(AppFont.body())
                .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.8))
                .scrollContentBackground(.hidden)
                .frame(minHeight: 180)
                .padding(.horizontal, AppSpacing.lg)
        }
    }

    // MARK: - Checklist Editor

    private var checklistEditor: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ForEach(checklistItems.indices, id: \.self) { idx in
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "circle")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.35))

                    TextField("Item \(idx + 1)", text: $checklistItems[idx])
                        .font(AppFont.body())
                        .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.8))
                        .onSubmit {
                            if idx == checklistItems.count - 1 {
                                checklistItems.append("")
                            }
                        }

                    if checklistItems.count > 1 {
                        Button {
                            checklistItems.remove(at: idx)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.25))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.xl)
            }

            Button {
                checklistItems.append("")
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add item")
                }
                .font(AppFont.body())
                .foregroundStyle(Color(hex: "#5B5EA6"))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.xl)
        }
    }

    // MARK: - Image Section

    @ViewBuilder
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: imageData == nil ? "photo.badge.plus" : "photo")
                        .font(.system(size: 16))
                    Text(imageData == nil ? "Attach Image" : "Change Image")
                        .font(AppFont.body())
                }
                .foregroundStyle(Color(hex: "#5B5EA6"))
                .padding(.horizontal, AppSpacing.xl)
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }

            if let data = imageData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                    .padding(.horizontal, AppSpacing.xl)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            imageData    = nil
                            selectedPhoto = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.white)
                                .shadow(radius: 3)
                        }
                        .padding(.top, 8)
                        .padding(.trailing, AppSpacing.xl + 8)
                    }
            }
        }
    }

    // MARK: - Save

    private func saveNote() {
        viewModel.addNote(
            context: context,
            title:            title.trimmingCharacters(in: .whitespaces),
            body:             noteBody.trimmingCharacters(in: .whitespaces),
            category:         selectedCategory,
            isChecklist:      isChecklist,
            imageData:        imageData,
            cardColorName:    selectedColorName,
            checklistTexts:   isChecklist ? checklistItems : []
        )
        dismiss()
    }
}

#Preview {
    AddNoteView(viewModel: NotesViewModel())
        .modelContainer(for: [Note.self, ChecklistItem.self], inMemory: true)
}
