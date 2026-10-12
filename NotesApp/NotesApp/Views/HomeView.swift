// HomeView.swift
// NotesApp
//
// Main screen: toolbar with add-note button, category tabs, masonry note grid.

import SwiftUI
import SwiftData

struct HomeView: View {

    // MARK: - Environment & Data

    @Environment(\.modelContext) private var context
    @Query private var allNotes: [Note]

    @State private var viewModel = NotesViewModel()
    @State private var selectedNote: Note? = nil
    @State private var navigateToDetail = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {

                        // ---- Title ----
                        Text("My Notes")
                            .font(AppFont.largeTitle())
                            .foregroundStyle(Color.primaryText)
                            .padding(.horizontal, AppSpacing.lg)

                        // ---- Category Tab Bar ----
                        CategoryTabBar(
                            selected: $viewModel.selectedCategory,
                            counts:   viewModel.noteCounts
                        )

                        // ---- Notes Grid ----
                        let filtered = viewModel.filteredNotes(from: allNotes)

                        if filtered.isEmpty {
                            emptyState
                        } else {
                            notesGrid(filtered)
                        }

                                // Bottom padding so FAB doesn't overlap last card
                        Spacer(minLength: 100)
                    }
                    .padding(.top, AppSpacing.md)
                }
                .scrollIndicators(.hidden)

                // ---- FAB ----
                FABButton(
                    systemImage: "plus",
                    action: { viewModel.showAddNote = true },
                    backgroundColor: .black,
                    foregroundColor: .white,
                    size: 60
                )
                .padding(.trailing, AppSpacing.xl)
                .padding(.bottom, 36)
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToDetail) {
                if let note = selectedNote {
                    NoteDetailView(note: note, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $viewModel.showAddNote) {
                AddNoteView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.refreshCounts(from: allNotes)
                seedIfNeeded()
            }
            .onChange(of: allNotes) { _, _ in
                viewModel.refreshCounts(from: allNotes)
            }
        }
    }

    // MARK: - Notes Grid (Masonry)

    @ViewBuilder
    private func notesGrid(_ notes: [Note]) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: AppSpacing.md),
            GridItem(.flexible(), spacing: AppSpacing.md),
        ]

        LazyVGrid(columns: columns, alignment: .leading, spacing: AppSpacing.md) {
            ForEach(notes) { note in
                NoteCard(note: note, width: .infinity)
                    .onTapGesture {
                        selectedNote    = note
                        navigateToDetail = true
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.deleteNote(note, context: context)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "note.text")
                .font(.system(size: 56))
                .foregroundStyle(Color.primaryText.opacity(0.25))
            Text("No notes yet")
                .font(AppFont.title2())
                .foregroundStyle(Color.primaryText.opacity(0.4))
            Text("Tap + to create your first note")
                .font(AppFont.body())
                .foregroundStyle(Color.primaryText.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Seed Helper

    private func seedIfNeeded() {
        if allNotes.isEmpty {
            viewModel.seedSampleData(context: context)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Note.self, ChecklistItem.self], inMemory: true)
}
