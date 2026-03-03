struct Album: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String   // Later replace with imageURL from API
}