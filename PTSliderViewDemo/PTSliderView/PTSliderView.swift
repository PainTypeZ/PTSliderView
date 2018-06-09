//
//  PTSliderView.swift
//  BlackBoxTest
//
//  Created by Pain on 2018/5/25.
//  Copyright © 2018年 彭平军. All rights reserved.
//

import UIKit
// PTSliderViewDelegate协议
protocol PTSliderViewDelegate:NSObjectProtocol {
    func sliderEndValueChanged(slider:PTSliderView) // 发送滑动结束时的滑块value
    func sliderValueChanging(slider:PTSliderView) // 发送滑动过程的滑块value，可选
    func sliderBeganTouch() // 触摸开始，可选
    func sliderEndTouch() // 触摸结束，可选
}
// 可选代理方法
extension PTSliderViewDelegate {
    func sliderValueChanging(slider:PTSliderView) {
        
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
private let sliderBorderWidth:CGFloat = 0.2 //默认边框为2
private let sliderBorderColor = UIColor.black //默认边框颜色
private let thumbAnimationSpeed:TimeInterval = 0.3//默认Thumb动画移速
private let leftViewColor = UIColor.orange //默认滑过颜色
private let sliderBackgroundColor = UIColor.darkGray //默认未滑过颜色
private let thumbColor = UIColor.lightGray //默认Thumb颜色

class PTSliderView: UIView {
    
    // Xib实现，可以在Xib上设置各个子控件属性默认值
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var thumbImageView: UIImageView!
    @IBOutlet private weak var leftView: UIView!
    @IBOutlet private weak var thumbLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelLeadingConstraint: NSLayoutConstraint!
    
    // slider的值
    private(set) var value:CGFloat = 0.0 {
        didSet {
            // 文字颜色渐变效果
            let red = self.minValueTextColorRGB.red + (self.maxValueTextColorRGB.red - self.minValueTextColorRGB.red) * self.value
            let green = self.minValueTextColorRGB.green + (self.maxValueTextColorRGB.green - self.minValueTextColorRGB.green) * self.value
            let blue = self.minValueTextColorRGB.blue + (self.maxValueTextColorRGB.blue - self.minValueTextColorRGB.blue) * self.value
            let alpha = self.minValueTextColorRGB.alpha + (self.maxValueTextColorRGB.alpha - self.minValueTextColorRGB.alpha) * self.value
            self.textLabel.textColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    // 是否隐藏thumb
    private var isThumbHidden:Bool = false {
        didSet {
            if isThumbHidden == true {
                thumbImageView.isHidden = true
            } else {
                thumbImageView.isHidden = false
            }
        }
    }
    // thumb是否自动返回起点
    private var thumbBack:Bool = true
    // slider最小值时的文字颜色
    private var minValueTextColorRGB:TextColorRGB = TextColorRGB(red: 133/255.0, green: 133/255.0, blue: 133/255.0, alpha: 1.0)
    // slider最大值时的文字颜色
    private var maxValueTextColorRGB:TextColorRGB = TextColorRGB(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    // 用于计算滑块移动距离的参考点（触摸点）
    private var originalPoint = CGPoint(x:0, y:0)
    // 代理
    weak var delegate:PTSliderViewDelegate?
    
    // 必须从加载xib初始化，还未兼容frame
    override func awakeFromNib() {
        super.awakeFromNib()
        initSetting()
    }
    // 初始化配置
    private func initSetting() {
        self.labelLeadingConstraint.constant = self.thumbImageView.bounds.height
        self.layer.borderWidth = sliderBorderWidth
        self.layer.borderColor = sliderBorderColor.cgColor
        
        self.backgroundColor = sliderBackgroundColor
        leftView.backgroundColor = leftViewColor
        thumbImageView.backgroundColor = thumbColor
    }
    // MARK: - Intetnal Functions
    // 设置滑块thumb图像
    func setThumbImage(_ image:UIImage) {
        self.thumbImageView.image = image
    }
    // 设置边框颜色
    func setBorderColor(_ color:UIColor) {
        self.layer.borderColor = color.cgColor
    }
    // 设置左滑轨颜色
    func setLeftViewColor(_ color:UIColor) {
        leftView.backgroundColor = color
    }
    // 设置右滑轨颜色（slider底部背景色）
    func setRightViewColor(_ color:UIColor) {
        self.backgroundColor = color
    }
    // 设置滑块滑动至最大位置
    func setThumbToMaximumValue() {
        self.labelLeadingConstraint.constant = 0
        thumbBack = false
        isThumbHidden = true
        isUserInteractionEnabled = false
        setSliderValue(value: 1, isAnimated: true)
    }
    // 设置滑块滑动至最小位置
    func setThumbToMinimumValue() {
        self.labelLeadingConstraint.constant = thumbImageView.bounds.width
        thumbBack = true
        isThumbHidden = false
        isUserInteractionEnabled = true
        setSliderValue(value: 0, isAnimated: true)
    }
    // 设置滑块滑动到指定位置
    func setSliderValue(value:CGFloat, isAnimated: Bool) {
        self.originalPoint = CGPoint(x: 0, y: 0)
        self.value = value
        if self.value >= 1 {
            self.value = 1
        }
        if self.value <= 0 {
            self.value = 0
        }
        let point = CGPoint(x: value * (bounds.width - thumbImageView.bounds.height), y: 0);
        slideAnimation(point: point, isAnimated: isAnimated)
    }
    // 设置文字
    func setText(text:String) {
        textLabel.text = text
    }
    // 设置文字字体
    func setFont(font:UIFont) {
        textLabel.font = font
    }
    // 设置文字颜色变化范围（min和max参数传一样的则不改变颜色）
    func setTexrColor(minRGB:TextColorRGB, maxRGB:TextColorRGB) {
        minValueTextColorRGB = minRGB
        maxValueTextColorRGB = maxRGB
    }
    // MARK: - Privte Functions
    // 滑动事件
    private func slideAnimation(point:CGPoint, isAnimated:Bool) {
        var movePoint = point
        movePoint.x -= originalPoint.x
        if movePoint.x <= 0 {
            movePoint.x = 0
        }
        if movePoint.x >= bounds.width - thumbImageView.bounds.height {
            movePoint.x = bounds.width - thumbImageView.bounds.height
        }
        value = movePoint.x / (bounds.width - thumbImageView.bounds.height)
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
        if touch.view != thumbImageView {
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
        if touch.view != thumbImageView {
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
        if touch.view != thumbImageView {
            return
        }
        var point = touch.location(in: self)
        slideAnimation(point: point, isAnimated: false)
        delegate?.sliderEndValueChanged(slider: self)
        if thumbBack == true {
            point.x = 0;
            self.slideAnimation(point: point, isAnimated: true)
        }
    }
}


