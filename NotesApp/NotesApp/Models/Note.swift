// Note.swift
// NotesApp
//
// Core data model using SwiftData for local persistence.

import Foundation
import SwiftData

// MARK: - Category Enum

enum NoteCategory: String, Codable, CaseIterable {
    case all        = "All"
    case important  = "Important"
    case bookmarked = "Bookmarked"
}

// MARK: - ChecklistItem Model

@Model
final class ChecklistItem {
    var id: UUID
    var text: String
    var isCompleted: Bool
    var orderIndex: Int

    // Back-reference to parent Note (optional to avoid circular requirement)
    var note: Note?

    init(text: String, isCompleted: Bool = false, orderIndex: Int = 0) {
        self.id = UUID()
        self.text = text
        self.isCompleted = isCompleted
        self.orderIndex = orderIndex
    }
}

// MARK: - Note Model

@Model
final class Note {
    var id: UUID
    var title: String
    var body: String
    var category: String                  // Stored as String (NoteCategory.rawValue)
    var isChecklist: Bool
    var imageData: Data?                  // Optional image attachment stored as raw bytes
    var cardColorName: String             // Name of the card accent colour
    var isPinned: Bool
    var timestamp: Date

    // SwiftData relationship – cascade deletes checklist items with note
    @Relationship(deleteRule: .cascade) var checklistItems: [ChecklistItem]

    // Computed helper
    var noteCategory: NoteCategory {
        get { NoteCategory(rawValue: category) ?? .all }
        set { category = newValue.rawValue }
    }

    init(
        title: String,
        body: String,
        category: NoteCategory = .all,
        isChecklist: Bool = false,
        imageData: Data? = nil,
        cardColorName: String = "cardPink",
        isPinned: Bool = false,
        checklistItems: [ChecklistItem] = []
    ) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.category = category.rawValue
        self.isChecklist = isChecklist
        self.imageData = imageData
        self.cardColorName = cardColorName
        self.isPinned = isPinned
        self.timestamp = Date()
        self.checklistItems = checklistItems
    }
}
