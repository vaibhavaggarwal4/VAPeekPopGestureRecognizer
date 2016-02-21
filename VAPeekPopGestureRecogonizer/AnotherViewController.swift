//
//  AnotherViewController.swift
//  VAPeekPopGestureRecogonizer
//
//  Created by Vaibhav Aggarwal on 2/20/16.
//  Copyright © 2016 Vaibhav Aggarwal. All rights reserved.
//

import Foundation
import UIKit
class AnotherViewController: UIViewController {
  
  let button = UIButton(type: .Custom)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.orangeColor()
    self.button.setTitle("Close", forState: .Normal)
    self.button.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
    self.button.sizeToFit()
    self.view.addSubview(self.button)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    self.button.center = self.view.center
  }
  
  func dismiss() {
    if let parent = self.parentViewController as? PeekPopGestureRecogonizerProtocol {
      parent.dismissPeekingViewController()
    }
  }
}