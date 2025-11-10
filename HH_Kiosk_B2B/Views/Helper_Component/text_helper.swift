import SwiftUI


func buildSemiBoldText(_ text: String,_ fontSize: CGFloat, color: Color = .black) -> some View {
    Text(text)
        .font(.custom("NewSpirit-SemiBold", size: fontSize))
        .foregroundColor(color)
    
}

func buildBoldText(_ text: String,_ fontSize: CGFloat, color: Color = .black) -> some View {
    Text(text)
        .font(.custom("NewSpirit-Bold", size: fontSize))
        .foregroundColor(color)
    
}

func buildMediumText(
    _ text: String,
    _ fontSize: CGFloat,
    color: Color = .black,
    alignment: TextAlignment = .leading
) -> some View {
    Text(text)
        .font(.custom("NewSpirit-Medium", size: fontSize))
        .foregroundColor(color)
        .multilineTextAlignment(alignment)
}

func buildMediumText(
    _ text: AttributedString,
    _ fontSize: CGFloat,
    color: Color = .black,
    alignment: TextAlignment = .leading
) -> some View {
    Text(text)
        .font(.custom("NewSpirit-Medium", size: fontSize))
        .foregroundColor(color)
        .multilineTextAlignment(alignment)
}
