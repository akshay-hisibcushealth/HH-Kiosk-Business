//
//  LottieAnimationView.swift
//  HH_Kiosk_B2B
//
//  Created by Applite Solutions on 20/06/26.
//


import Lottie
import SwiftUI

struct AppLottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop
    var animationSpeed: CGFloat = 1.0

    func makeUIView(context: Context) -> LottieAnimationViewWrapper {
        let view = LottieAnimationViewWrapper()
        view.configure(name: name, loopMode: loopMode, animationSpeed: animationSpeed)
        return view
    }

    func updateUIView(_ uiView: LottieAnimationViewWrapper, context: Context) {}
}

final class LottieAnimationViewWrapper: UIView {
    private let animationView = Lottie.LottieAnimationView(
        configuration: LottieConfiguration(renderingEngine: .mainThread)
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, loopMode: LottieLoopMode, animationSpeed: CGFloat) {
        animationView.animation = LottieAnimation.named(name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.play()
    }
}
