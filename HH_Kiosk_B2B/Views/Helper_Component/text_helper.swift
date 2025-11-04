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
