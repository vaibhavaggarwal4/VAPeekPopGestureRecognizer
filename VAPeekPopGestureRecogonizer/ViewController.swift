//
//  ViewController.swift
//  VAPeekPopGestureRecogonizer
//
//  Created by Vaibhav Aggarwal on 2/20/16.
//  Copyright © 2016 Vaibhav Aggarwal. All rights reserved.
//

import UIKit

/** Example Usage **/
class ViewController: UIViewController {

  let label = UILabel()
  var peekPopRecognizer: PeekPopGestureRecogonizer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
    self.view.addSubview(self.label)
    self.label.text = "Long Tap on me"
    self.label.font = UIFont.boldSystemFontOfSize(28.0)
    self.label.textColor = UIColor.whiteColor()
    self.label.sizeToFit()
    self.label.userInteractionEnabled = true
    self.peekPopRecognizer = PeekPopGestureRecogonizer(view: self.label, peekAnimation: PeekAnimationType.GrowIn)
    self.peekPopRecognizer?.delegate = self
  }

  override func viewWillLayoutSubviews() {
  super.viewWillLayoutSubviews()
    self.label.center = self.view.center
  }
}

extension ViewController: PeekPopGestureRecogonizerProtocol {
  func peekPopViewController() -> UIViewController {
    let vc = AnotherViewController()
    return vc
  }
  
  func dismissPeekingViewController() {
    self.peekPopRecognizer?.dismissPeekingController()
  }
}

