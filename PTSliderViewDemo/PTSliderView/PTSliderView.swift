//
//  PTSliderView.swift
//  PTSliderViewDemo
//
//  Created by Pain on 2018/6/8.
//  Copyright © 2018年 Pain. All rights reserved.
//

import UIKit
// PTSliderViewDelegate协议
protocol PTSliderViewDelegate: AnyObject {
    func sliderEndValueChanged(slider: PTSliderView) // 发送滑动结束时的滑块value
    func sliderValueChanging(slider: PTSliderView) // 发送滑动过程的滑块value, 可选
    func sliderBeganTouch() // 触摸开始，可选
    func sliderEndTouch() // 触摸结束，可选
}
// 可选代理方法
extension PTSliderViewDelegate {
    func sliderValueChanging(slider: PTSliderView) {
        
    }
    func sliderBeganTouch() {
        
    }
    func sliderEndTouch() {
        
    }
}

// 用于处理文字渐变颜色
struct TextColorRGB {
    var red:CGFloat
    var green:CGFloat
    var blue:CGFloat
    var alpha:CGFloat
}
// 常量
private let sliderBorderWidth: CGFloat = 0.2 //默认边框为2
private let sliderBorderColor = UIColor.black //默认边框颜色
private let thumbAnimationSpeed: TimeInterval = 0.3//默认Thumb动画移速
private let leftViewColor = UIColor.orange //默认滑过颜色
private let sliderBackgroundColor = UIColor.darkGray //默认未滑过颜色
private let thumbColor = UIColor.lightGray //默认Thumb颜色

class PTSliderView: UIView {
    
    // Xib实现，可以在Xib上设置各个子控件属性默认值
    @IBOutlet private weak var textLabel: UILabel!

    @IBOutlet private weak var thumbView: UIView!
    
    @IBOutlet private weak var leftView: UIView!
    @IBOutlet private weak var thumbLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var thumbTextLabel: UILabel!
    @IBOutlet private weak var thumbImageView: UIImageView!
    @IBOutlet weak var thumbContentViewSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbImageViewTrailingConstraint: NSLayoutConstraint!
    
    var isTextIndentThumbWidth: Bool = false {
        didSet {
            labelLeadingConstraint.constant = thumbView.bounds.width
        }
    }
    
    // slider的值
    private(set) var value: CGFloat = 0.0 {
        didSet {
            guard isTextFade == true else {
                return
            }
            // 文字颜色渐变效果
            let red = minValueTextColorRGB.red + (maxValueTextColorRGB.red - minValueTextColorRGB.red) * value
            let green = minValueTextColorRGB.green + (maxValueTextColorRGB.green - minValueTextColorRGB.green) * value
            let blue = minValueTextColorRGB.blue + (maxValueTextColorRGB.blue - minValueTextColorRGB.blue) * value
            let alpha = minValueTextColorRGB.alpha + (maxValueTextColorRGB.alpha - minValueTextColorRGB.alpha) * value
            self.textLabel.textColor = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
        }
    }
    // 是否隐藏thumb
    private var isThumbHidden: Bool = false {
        didSet {
            if isThumbHidden == true {
                thumbView.isHidden = true
            } else {
                thumbView.isHidden = false
            }
        }
    }
    // thumb是否自动返回起点
    private var thumbBack: Bool = true
    
    // slider是否需要文字渐变
    var isTextFade = false
    // slider最小值时的文字颜色
    private var minValueTextColorRGB: TextColorRGB = TextColorRGB(red: 133/255.0, green: 133/255.0, blue: 133/255.0, alpha: 1.0)
    // slider最大值时的文字颜色
    private var maxValueTextColorRGB: TextColorRGB = TextColorRGB(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    // 用于计算滑块移动距离的参考点（触摸点）
    private var originalPoint = CGPoint(x:0, y:0)
    // 代理
    weak var delegate: PTSliderViewDelegate?
    
    // 必须从加载xib初始化，还未兼容frame
    override func awakeFromNib() {
        super.awakeFromNib()
        initSetting()
    }
    // 初始化配置
    private func initSetting() {
//        labelLeadingConstraint.constant = thumbView.bounds.width
        layer.borderWidth = sliderBorderWidth
        layer.borderColor = sliderBorderColor.cgColor
        
        backgroundColor = sliderBackgroundColor
        leftView.backgroundColor = leftViewColor
        thumbView.backgroundColor = thumbColor
    }
    // MARK: - Intetnal Functions
    // 设置Thumb背景色
    func setThumbBackGroundColor(_ color: UIColor) {
        thumbView.backgroundColor = color
    }
    // 设置thumbLabel和thumbImageView的间距
    func setThumbContentViewSpacing(_ constant: CGFloat) {
        thumbContentViewSpacingConstraint.constant = constant
    }
    // 设置thumbLabel的左边距
    func setThumbLabelLeadingSpacing(_ constant: CGFloat) {
        thumbLabelLeadingConstraint.constant = constant
    }
    // 设置thumbImageView的右边距
    func setThumbImageViewTrailingSpacing(_ constant: CGFloat) {
        thumbImageViewTrailingConstraint.constant = constant
    }
    // 快捷设置thumb只有单一控件的约束
    func setThumbWithoutSpacing() {
        if thumbContentViewSpacingConstraint.constant != 0 {
            thumbContentViewSpacingConstraint.constant = 0
            thumbLabelLeadingConstraint.constant = 0
            thumbImageViewTrailingConstraint.constant = 0
        }
        if isTextIndentThumbWidth == true {
            layoutIfNeeded()
            labelLeadingConstraint.constant = thumbView.bounds.width
        }
    }
    // 快捷设置thumb有两个控件时的约束
    func setThumbWithSapcing() {
        if thumbContentViewSpacingConstraint.constant != 5 {
            thumbContentViewSpacingConstraint.constant = 5
            thumbLabelLeadingConstraint.constant = 10
            thumbImageViewTrailingConstraint.constant = 10
        }
        if isTextIndentThumbWidth == true {
            layoutIfNeeded()
            labelLeadingConstraint.constant = thumbView.bounds.width
        }
    }
    // 设置Thumb文字
    func setThumbText(_ text: String) {
        thumbTextLabel.text = text
        if text.isEmpty == true {
            setThumbWithoutSpacing()
        } else if thumbImageView.image != nil {
            setThumbWithSapcing()
        }
    }
    func setThumbTextColor(color: UIColor) {
        thumbTextLabel.textColor = color
    }
    // 设置滑块thumb图像
    func setThumbImage(_ image: UIImage?) {
        thumbImageView.image = image
        if image == nil {
            setThumbWithoutSpacing()
        } else if thumbTextLabel.text?.isEmpty == false {
            setThumbWithSapcing()
        }
    }
    // 设置边框颜色
    func setBorderColor(_ color: UIColor) {
        layer.borderColor = color.cgColor
    }
    // 设置左滑轨颜色
    func setLeftViewColor(_ color: UIColor) {
        leftView.backgroundColor = color
    }
    // 设置右滑轨颜色（slider底部背景色）
    func setRightViewColor(_ color: UIColor) {
        backgroundColor = color
    }
    // 设置滑块滑动至最大位置
    func setThumbToMaximumValue() {
        if isTextIndentThumbWidth == true {
            labelLeadingConstraint.constant = 0
        }
        thumbBack = false
        isThumbHidden = true
        isUserInteractionEnabled = false
        setSliderValue(value: 1, isAnimated: true)
    }
    // 设置滑块滑动至最小位置
    func setThumbToMinimumValue() {
        if isTextIndentThumbWidth == true {
            labelLeadingConstraint.constant = thumbView.bounds.width
        }
        thumbBack = true
        isThumbHidden = false
        isUserInteractionEnabled = true
        setSliderValue(value: 0, isAnimated: true)
    }
    // 设置滑块滑动到指定位置
    func setSliderValue(value: CGFloat, isAnimated: Bool) {
        self.originalPoint = CGPoint(x: 0, y: 0)
        self.value = value
        if self.value >= 1 {
            self.value = 1
        }
        if self.value <= 0 {
            self.value = 0
        }
        let point = CGPoint(x: value * (bounds.width - thumbView.bounds.width), y: 0);
        slideAnimation(point: point, isAnimated: isAnimated)
    }
    // 设置文字
    func setText(text: String) {
        textLabel.text = text
    }
    // 设置文字字体
    func setFont(font: UIFont) {
        textLabel.font = font
    }
    // 设置文字颜色变化范围（min和max参数传一样的则不改变颜色）
    func setTextColor(minRGB: TextColorRGB, maxRGB: TextColorRGB) {
        isTextFade = true
        minValueTextColorRGB = minRGB
        maxValueTextColorRGB = maxRGB
        textLabel.textColor = UIColor(red: minRGB.red/255.0, green: minRGB.green/255.0, blue: minRGB.blue/255.0, alpha: minRGB.alpha)
    }
    func setTextColor(_ color: UIColor) {
        isTextFade = false
        textLabel.textColor = color
    }
    // MARK: - Privte Functions
    // 滑动事件
    private func slideAnimation(point: CGPoint, isAnimated: Bool) {
        var movePoint = point
        movePoint.x -= originalPoint.x
        if movePoint.x <= 0 {
            movePoint.x = 0
        }
        if movePoint.x >= bounds.width - thumbView.bounds.width {
            movePoint.x = bounds.width - thumbView.bounds.width
        }
        value = movePoint.x / (bounds.width - thumbView.bounds.width)
        if isAnimated == true {
            UIView.animate(withDuration: thumbAnimationSpeed) {
                self.thumbLeadingConstraint.constant = movePoint.x
                self.layoutIfNeeded()
            }
        } else {
            thumbLeadingConstraint.constant = movePoint.x
        }
    }
    // MARK: - Touch
    // 触摸开始
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        if !(touch.view == thumbView || touch.view == thumbImageView || touch.view == thumbTextLabel) {
            return
        }
        let point = touch.location(in: self)
        originalPoint = point
        delegate?.sliderBeganTouch()
    }
    // 触摸移动
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        if !(touch.view == thumbView || touch.view == thumbImageView || touch.view == thumbTextLabel) {
            return
        }
        let point = touch.location(in: self)
        slideAnimation(point: point, isAnimated: false)
        delegate?.sliderValueChanging(slider: self)
    }
    // 触摸结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.sliderEndTouch()
        guard let touch = touches.first else {
            return
        }
        if !(touch.view == thumbView || touch.view == thumbImageView || touch.view == thumbTextLabel) {
            return
        }
        var point = touch.location(in: self)
        slideAnimation(point: point, isAnimated: false)
        delegate?.sliderEndValueChanged(slider: self)
        if thumbBack == true {
            point.x = 0
            slideAnimation(point: point, isAnimated: true)
        }
    }
}
