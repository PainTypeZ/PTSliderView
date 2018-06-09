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
let slideMaxValue:CGFloat = 0.8 // 0.0 ~ 1.0

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
        // 设置代理
        slider.delegate = self
        // 设置文字
        slider.setText(text: "请滑动滑块到最右侧")
        // 设置左侧滑轨颜色
        slider.setLeftViewColor(UIColor(red: 24/255.0, green: 181/255.0, blue: 132/255.0, alpha: 1.0))
        // 设置右侧滑轨颜色
        slider.setRightViewColor(UIColor.yellow)
        // 设置Thumb图像
        slider.setThumbImage(#imageLiteral(resourceName: "slider_thumb"))
        // 添加滑块到self.view
        view.addSubview(slider)
        // 设置约束
        slider.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
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
