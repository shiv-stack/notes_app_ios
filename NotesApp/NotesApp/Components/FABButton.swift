// FABButton.swift
// NotesApp
//
// Floating Action Button with a spring press animation.

import SwiftUI

struct FABButton: View {

    let systemImage: String
    let action: () -> Void
    var backgroundColor: Color = Color.primaryText
    var foregroundColor: Color = Color("AppBackground")
    var size: CGFloat = 56

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { isPressed = false }
            }
            action()
        }) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(foregroundColor)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(backgroundColor)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
