//
//  ViewController.swift
//  PTSliderViewDemo
//
//  Created by Pain on 2018/6/8.
//  Copyright © 2018年 Pain. All rights reserved.
//

import UIKit
import SnapKit

// 用于判断滑块是否已经滑到最大值的常量
let slideMaxValue:CGFloat = 1.0 // 0.0 ~ 1.0

class ViewController: UIViewController {
    lazy var slider:PTSliderView = Bundle.main.loadNibNamed("PTSliderView", owner: self, options: nil)?.first as! PTSliderView
    override func viewDidLoad() {
        super.viewDidLoad()
        // 添加滑块
        addSliderView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    // 添加滑块
    private func addSliderView() {
        // 先添加滑块到self.view并设置约束，然后再配置属性
        view.addSubview(slider)
        // 设置约束
        slider.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        // 设置代理
        slider.delegate = self
        
        // 由于autolayout的frame计算时机问题，属性配置必须放在slider建立外部约束关系之后，否则slider内部控件的位置在初始状态时将会出现异常
        // 设置滑块文字是否向右缩进Thumb宽度,默认False，需要优先于其他属性配置
        slider.isTextIndentThumbWidth = true
        
        // 设置滑块文字/图片,文字长度为0时，thumbImageView将自动居中且边距为0，同理图片为空时，文字也将自动居中且边距为0
        slider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"))
//        slider.setThumbImage(nil)
        slider.setThumbText("")
//        slider.setThumbText("123")
        // 设置文字
        slider.setText(text: "请滑动滑块到最右侧")
        // 设置文字颜色（不渐变）
//        slider.setTextColor(UIColor.red)
        // 设置文字颜色（渐变）
        let startColor = TextColorRGB(red: 255, green: 255, blue: 255, alpha: 1)
        let endColor = TextColorRGB(red: 0, green: 0, blue: 0, alpha: 1)
        slider.setTextColor(minRGB: startColor, maxRGB: endColor)
        // 设置左侧滑轨颜色
        slider.setLeftViewColor(UIColor(red: 24/255.0, green: 181/255.0, blue: 132/255.0, alpha: 1.0))
        // 设置右侧滑轨颜色
        slider.setRightViewColor(UIColor.red)
        

    }
    @IBAction func resetSliderButtonAction(_ sender: UIButton) {
        slider.setText(text: "请滑动滑块到最右侧")
        slider.setThumbToMinimumValue()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
// MARK: - PTSliderViewDelegate
extension ViewController:PTSliderViewDelegate {
    // 结束滑动时的value
    func sliderEndValueChanged(slider: PTSliderView) {
        if slider.value >= slideMaxValue {
            slider.setText(text: "滑动成功")
            slider.setThumbToMaximumValue()
        }
        print("滑动结束：value：\(slider.value)")
    }
    // 滑块滑动过程的value, 可选
    func sliderValueChanging(slider: PTSliderView) {
        print("滑块value：\(slider.value)")
    }
    // 触摸开始，可选
    func sliderBeganTouch() {
        print("触摸开始")
    }
    // 触摸结束，可选
    func sliderEndTouch() {
        print("触摸结束")
    }
    
}
