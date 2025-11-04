import SwiftUI

enum ResultType {
    case risk, bloodPressure, heartRate
}

class ResultCardCell: UICollectionViewCell {
    
    // UI Elements
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let scaleView = UIStackView()
    private let arrowView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, value: String, progress: Float, icon: UIImage?, unit: String?, minValue: Int, maxValue: Int) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let type = getResultType(for: title)
        switch type {
        case .risk:
            configureCell(icon: icon,title: title, value: value,unit: unit, segments: [
                (UIColor(hex: "#5EC54C"), 0.2),
                (UIColor(hex: "#C2EA73"), 0.2),
                (UIColor(hex: "#F7CD6C"), 0.2),
                (UIColor(hex: "#EE8F64"), 0.2),
                (UIColor(hex: "#A5391E"), 0.2)
            ] ,minValue: minValue, maxValue: maxValue
            )
        case .bloodPressure:
            configureCell(icon: icon,title: title, value: value, unit: unit,segments: [
                (UIColor(hex: "#F7CD6C"), 0.2),
                (UIColor(hex: "#5EC54C"), 0.2),
                (UIColor(hex: "#5EC54C"), 0.2),
                (UIColor(hex: "#F7CD6C"), 0.2),
                (UIColor(hex: "#A5391E"), 0.2)
            ]  ,minValue: minValue, maxValue: maxValue)
        case .heartRate:
            configureCell(icon: icon,title: title, value: value, unit: unit,segments: [
                (UIColor(hex: "#F7CD6C"), 0.2),
                (UIColor(hex: "#5EC54C"), 0.2),
                (UIColor(hex: "#5EC54C"), 0.2),
                (UIColor(hex: "#5EC54C"), 0.2),
                (UIColor(hex: "#F7CD6C"), 0.2)
            ] ,minValue: minValue, maxValue: maxValue  )
        }
    }
    
    private func getResultType(for title: String) -> ResultType {
        switch title {
        case "Systolic Blood Pressure", "Diastolic Blood Pressure":
            return .bloodPressure
        case "Heart Rate":
            return .heartRate
        default:
            return .risk
        }
    }
    
    // MARK: - UI Templates
    
    func configureCell(icon: UIImage?, title: String, value: String, unit: String?, segments: [(UIColor, CGFloat)], minValue: Int, maxValue: Int) {
        self.contentView.subviews.forEach { $0.removeFromSuperview() } // clean old views
        
        let iconView = UIImageView(image: icon)
        iconView.tintColor = .label
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleStack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        titleStack.axis = .horizontal
        titleStack.spacing = 8
        titleStack.alignment = .center
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Bar container
        let barContainer = UIView()
        barContainer.translatesAutoresizingMaskIntoConstraints = false
        barContainer.layer.cornerRadius = 8
        barContainer.clipsToBounds = true
        
        var previous: UIView? = nil
        for segment in segments {
            let segmentView = UIView()
            segmentView.backgroundColor = segment.0
            segmentView.translatesAutoresizingMaskIntoConstraints = false
            barContainer.addSubview(segmentView)
            
            NSLayoutConstraint.activate([
                segmentView.topAnchor.constraint(equalTo: barContainer.topAnchor),
                segmentView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor),
                segmentView.widthAnchor.constraint(equalTo: barContainer.widthAnchor, multiplier: segment.1)
            ])
            
            if let prev = previous {
                segmentView.leadingAnchor.constraint(equalTo: prev.trailingAnchor).isActive = true
            } else {
                segmentView.leadingAnchor.constraint(equalTo: barContainer.leadingAnchor).isActive = true
            }
            previous = segmentView
        }
        
        // Arrow indicator
        let arrow = TriangleView(color: .systemIndigo)
        arrow.translatesAutoresizingMaskIntoConstraints = false
        
        // Value label
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: 24)
        
        
        // Determine the value as float
        let numericValue = Float(value.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)) ?? 0
        
        // Map value to color based on cumulative segment ranges
        var cumulative: Float = 0
        var matchedColor: UIColor = .label
        
        for segment in segments {
            let range = segment.1 * CGFloat(maxValue)
            if numericValue <= cumulative + Float(range) {
                matchedColor = segment.0
                break
            }
            cumulative += Float(range)
        }
        
        valueLabel.textColor = matchedColor
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.font = .systemFont(ofSize: 16)
        unitLabel.textColor = .secondaryLabel
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueStack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        valueStack.axis = .horizontal
        valueStack.spacing = 4
        valueStack.alignment = .firstBaseline
        valueStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to contentView
        let container = self.contentView
        container.addSubview(titleStack)
        container.addSubview(barContainer)
        container.addSubview(arrow)
        container.addSubview(valueStack)
        
        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            barContainer.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 12),
            barContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            barContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            barContainer.heightAnchor.constraint(equalToConstant: 16),
            
            arrow.topAnchor.constraint(equalTo: barContainer.bottomAnchor, constant: 6),
            arrow.centerXAnchor.constraint(equalTo: barContainer.leadingAnchor, constant:
                                            16 + computeArrowOffset(value: value, minValue: minValue, maxValue: maxValue, totalWidth: container.bounds.width - 32 - 32)
                                          ),
            
            arrow.widthAnchor.constraint(equalToConstant: 10),
            arrow.heightAnchor.constraint(equalToConstant: 10),
            
            valueStack.topAnchor.constraint(equalTo: arrow.bottomAnchor, constant: 12),
            valueStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        ])
    }
    
    
    func computeArrowOffset(value: String, minValue: Int, maxValue: Int, totalWidth: CGFloat) -> CGFloat {
        let cleaned = value.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)
        guard let numericValue = Float(cleaned) else { return 0 }
        
        let clamped = Swift.min(Swift.max(numericValue, Float(minValue)), Float(maxValue))
        let normalized = (clamped - Float(minValue)) / Float(maxValue - minValue) // 0 to 1
        return CGFloat(normalized) * totalWidth
    }
    
    
}

