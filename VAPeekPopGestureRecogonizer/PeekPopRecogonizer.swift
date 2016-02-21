//
//  PeekPopRecogonizer.swift
//  VAPeekPopGestureRecogonizer
//
//  Created by Vaibhav Aggarwal on 2/20/16.
//  Copyright © 2016 Vaibhav Aggarwal. All rights reserved.
//

/*********

Abstract: This class allows to have Peek and Pop functionlality like the one enabled by Force Touch,
but for devices that does not have the 3D touch hardware.
It uses a UILongPressGestureRecognizer to achieve and simulate similar functionality

**********/


import Foundation
import UIKit

/*
* PeekPopGestureRecogonizerProtocol must be implemented by a ViewController that needs the functionality
*
*/
protocol PeekPopGestureRecogonizerProtocol {
  /* return the view controller that needs to be peeked and popped */
  func peekPopViewController() -> UIViewController
  /*
  * Dimisses the peeking view controller
  * The peeking view controller is not presented modally, but is added as a child view controller
  * the delagate view controller needs to implement this method and JUST needs to call PeekPopGestureRecogonizer instance's dismissPeekingController method
  */
  func dismissPeekingViewController() 
}

/* Defines animations for peek */
enum PeekAnimationType {
  case FadeIn // fade in using alpha
  case GrowIn // appear in by scaling CGAffineTransform
}

class PeekPopGestureRecogonizer {
  
  var delegate: PeekPopGestureRecogonizerProtocol?
  private var longPressGestureRecogonizer: UILongPressGestureRecognizer
  private var longPressTimer = NSTimer()
  private weak var peekingViewController: UIViewController?
  private var hasPopped = false
  private var peekAnimationType: PeekAnimationType = .GrowIn
  
  init(view: UIView, peekAnimation: PeekAnimationType?) {
    self.longPressGestureRecogonizer = UILongPressGestureRecognizer()
    self.longPressGestureRecogonizer.minimumPressDuration = 0.5
    self.longPressGestureRecogonizer.addTarget(self, action: "longPressDetected:")
    view.addGestureRecognizer(self.longPressGestureRecogonizer)
    if peekAnimation != nil {
      self.peekAnimationType = peekAnimation!
    }
  }
  
  /*
  * Handles long press gesture and asks to peek, pop or dismiss the new view controller based on the gesture recogonizer state
  * The new vc is popped only if the user continues to touch after the state began is recieved else it is dismissed
  */
  @objc func longPressDetected(recogonizer: UILongPressGestureRecognizer) {
    if recogonizer.state == UIGestureRecognizerState.Began {
      if let vc = self.delegate?.peekPopViewController() {
        self.peekViewController(vc)
        if self.longPressTimer.valid {
          self.longPressTimer.invalidate()
        }
        self.hasPopped = false
        self.longPressTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "popViewController", userInfo: nil, repeats: false)
      }
    }
    else if recogonizer.state == .Ended || recogonizer.state == .Cancelled {
      self.longPressTimer.invalidate()
      if !self.hasPopped {
        self.dismissPeekingController()
      }
    }
    else if recogonizer.state == .Failed {
      self.longPressTimer.invalidate()
      self.dismissPeekingController()
    }
  }
  
  /*
  * Gives a peek of the viewController
  * Animation depends on the peekTypeAnimation variable
  */
  func peekViewController(viewController: UIViewController) {
    if let delegateVC = self.delegate as? UIViewController {
      delegateVC.addChildViewController(viewController)
      viewController.didMoveToParentViewController(delegateVC)
      viewController.view.alpha = 0.0
      viewController.view.frame = delegateVC.view.frame
      if self.peekAnimationType == .FadeIn {
        self.fadeInAnimation(viewController)
      }
      else {
        self.growInAnimation(viewController)
      }
    }
  }
  
  private func growInAnimation(viewController: UIViewController) {
    if let delegateVC = self.delegate as? UIViewController {
      viewController.view.transform = CGAffineTransformMakeScale(0, 0)
      delegateVC.view.addSubview(viewController.view)
      self.peekingViewController = viewController
      UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
        viewController.view.transform = CGAffineTransformMakeScale(0.8, 0.6)
        viewController.view.alpha = 1.0
        }, completion: { (finished: Bool) -> Void in
          
      })
    }
  }
  
  private func fadeInAnimation(viewController: UIViewController){
    if let delegateVC = self.delegate as? UIViewController {
      viewController.view.transform = CGAffineTransformMakeScale(0.8, 0.6)
      delegateVC.view.addSubview(viewController.view)
      self.peekingViewController = viewController
      UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
        viewController.view.alpha = 1.0
        }, completion: { (finished: Bool) -> Void in
          
      })
    }
  }
  
  /*
  * Pops the viewController
  *
  */
  @objc private func popViewController() {
    if let vc = self.peekingViewController {
      UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
        vc.view.transform = CGAffineTransformIdentity
        }, completion: { [weak self] (finished: Bool) -> Void in
          self?.hasPopped = true
      })
    }
  }
  
  /*
  * Dismisses the viewController
  *
  */
  func dismissPeekingController() {
    if let vc = self.peekingViewController {
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        if self.hasPopped {
          vc.view.transform = CGAffineTransformMakeTranslation(0, vc.view.frame.size.height)
          vc.view.alpha = 0.4
        }
        else {
          vc.view.alpha = 0.0
        }
        }) { (finish: Bool) -> Void in
          vc.view.removeFromSuperview()
          vc.willMoveToParentViewController(nil)
          vc.removeFromParentViewController()
      }
    }
  }
}