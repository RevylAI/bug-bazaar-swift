import SwiftUI

struct FilterChips: View {
    @Binding var activeFilter: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.s) {
                ForEach(categories, id: \.self) { filter in
                    Button {
                        activeFilter = filter
                    } label: {
                        Text(filter)
                            .font(.bodyFont(13, bold: true))
                            .foregroundColor(activeFilter == filter ? Theme.paperWhite : Theme.inkBlack)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                Capsule().fill(activeFilter == filter ? Theme.inkBlack : Theme.lightGray)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.m)
            .padding(.bottom, Spacing.m)
        }
    }
}
