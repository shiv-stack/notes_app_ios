// NotesViewModel.swift
// NotesApp
//
// ObservableObject that acts as the bridge between SwiftData and the Views.
// All mutation logic lives here to keep views clean.

import SwiftUI
import SwiftData

@MainActor
@Observable
final class NotesViewModel {

    // MARK: - Published State

    var selectedCategory: NoteCategory = .all
    var searchText: String = ""
    var showAddNote: Bool = false
    var noteCounts: [NoteCategory: Int] = [:]

    // MARK: - Filtering

    /// Returns notes filtered by the currently selected category and search text.
    func filteredNotes(from notes: [Note]) -> [Note] {
        notes
            .filter { note in
                // Category filter (All shows everything)
                if selectedCategory != .all {
                    guard note.noteCategory == selectedCategory else { return false }
                }
                // Search filter
                if !searchText.isEmpty {
                    let q = searchText.lowercased()
                    return note.title.lowercased().contains(q) || note.body.lowercased().contains(q)
                }
                return true
            }
            .sorted { $0.timestamp > $1.timestamp }   // newest first
    }

    /// Refreshes cached tab counts from the full notes array.
    func refreshCounts(from notes: [Note]) {
        noteCounts[.all]        = notes.count
        noteCounts[.important]  = notes.filter { $0.noteCategory == .important  }.count
        noteCounts[.bookmarked] = notes.filter { $0.noteCategory == .bookmarked }.count
    }

    // MARK: - CRUD

    /// Creates and inserts a new Note into the SwiftData context.
    func addNote(
        context: ModelContext,
        title: String,
        body: String,
        category: NoteCategory,
        isChecklist: Bool,
        imageData: Data?,
        cardColorName: String,
        checklistTexts: [String]
    ) {
        let items = checklistTexts
            .enumerated()
            .filter { !$0.element.trimmingCharacters(in: .whitespaces).isEmpty }
            .map { idx, text in ChecklistItem(text: text, orderIndex: idx) }

        let note = Note(
            title: title,
            body: body,
            category: category,
            isChecklist: isChecklist,
            imageData: imageData,
            cardColorName: cardColorName,
            checklistItems: items
        )
        items.forEach { $0.note = note }
        context.insert(note)
    }

    /// Deletes a note from the context.
    func deleteNote(_ note: Note, context: ModelContext) {
        context.delete(note)
    }

    /// Deletes notes at the specified index set from the filtered array.
    func deleteNotes(at offsets: IndexSet, from notes: [Note], context: ModelContext) {
        offsets.forEach { index in
            deleteNote(notes[index], context: context)
        }
    }

    /// Toggles the completion state of a checklist item.
    func toggleChecklistItem(_ item: ChecklistItem) {
        item.isCompleted.toggle()
    }

    // MARK: - Seed Data

    /// Inserts sample notes on first launch (only if the store is empty).
    func seedSampleData(context: ModelContext) {
        // Honey note with checklist
        let honeyChecklist = [
            ChecklistItem(text: "Buy food",   orderIndex: 0),
            ChecklistItem(text: "GYN",        orderIndex: 1),
            ChecklistItem(text: "Meeting",    orderIndex: 2),
        ]
        let honeyNote = Note(
            title: "Buy honey 100% original",
            body: "Buy the new brand honey for my family, here's the pic.",
            category: .all,
            isChecklist: true,
            cardColorName: "cardPink",
            checklistItems: honeyChecklist
        )
        honeyChecklist.forEach { $0.note = honeyNote }
        context.insert(honeyNote)

        // Plan for the day note
        let planChecklist = [
            ChecklistItem(text: "Buy food",   isCompleted: false, orderIndex: 0),
            ChecklistItem(text: "GYN",        isCompleted: false, orderIndex: 1),
            ChecklistItem(text: "Meeting",    isCompleted: false, orderIndex: 2),
        ]
        let planNote = Note(
            title: "Plan for the today",
            body: "",
            category: .important,
            isChecklist: true,
            cardColorName: "cardBlueGray",
            checklistItems: planChecklist
        )
        planChecklist.forEach { $0.note = planNote }
        context.insert(planNote)

        // Tax payment note
        let taxChecklist = [
            ChecklistItem(text: "Audi RS7 sportback 5 seater",      orderIndex: 0),
            ChecklistItem(text: "Harley davidson street guide",      orderIndex: 1),
            ChecklistItem(text: "Lamborghini aventador",            orderIndex: 2),
            ChecklistItem(text: "Shopping of the downtown mall",    orderIndex: 3),
            ChecklistItem(text: "GST filling of the iPhone 14 pro max", orderIndex: 4),
        ]
        let taxNote = Note(
            title: "Tax payment before the end of march",
            body: "This is a reminder note, so as not to forget to pay taxes before the end of march. Don't miss it, you could be fined!\n\nList of assets that must be reported to the government, whether in the form of cash savings, that is mandatory things we have filling the tax payment to the government.",
            category: .important,
            isChecklist: true,
            cardColorName: "cardBlueGray",
            checklistItems: taxChecklist
        )
        taxChecklist.forEach { $0.note = taxNote }
        context.insert(taxNote)

        // Password WiFi note
        let wifiNote = Note(
            title: "Password WiFi gelato cafe near the station",
            body: "Wifi indoor : to reset the wifi password on time to don't get confusion after every 4 weeks.\n\nThis is a gentle reminder.",
            category: .bookmarked,
            isChecklist: false,
            cardColorName: "cardYellow"
        )
        context.insert(wifiNote)
    }
}
