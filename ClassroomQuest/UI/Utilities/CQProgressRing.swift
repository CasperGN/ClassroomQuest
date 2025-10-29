import SwiftUI

struct CQProgressRing: View {
    var value: Double
    var lineWidth: CGFloat = 8
    var color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.08, min(1, value)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .fill(color.gradient)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
            Text("\(Int(value * 100))%")
                .font(.cqCaption)
                .foregroundStyle(CQTheme.textPrimary)
        }
    }
}

#Preview {
    CQProgressRing(value: 0.65, color: CQTheme.bluePrimary)
        .frame(width: 64, height: 64)
        .padding()
        .background(Color.gray.opacity(0.2))
}
