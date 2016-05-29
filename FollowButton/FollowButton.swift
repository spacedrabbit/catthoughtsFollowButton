//
//  FollowButton.swift
//  FollowButton
//
//  Created by Louis Tur on 5/28/16.
//  Copyright © 2016 cat.thoughts. All rights reserved.
//

import UIKit
import SnapKit

class FollowButton: UIView {

  private enum FollowButtonState {
    case NotFollowing
    case Following
    case Loading
  }
  
  // MARK: - Variables
  // ------------------------------------------------------------
  private var adjustedWidthConstraints: (left: Constraint?, right: Constraint?)
  private var minButtonWidth: CGFloat?
  private var checkHeightOnce: dispatch_once_t = 0
  
  private var currentButtonState: FollowButtonState = .NotFollowing
  
  
  // MARK: - Initialization
  // ------------------------------------------------------------
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupViewHierarchy()
    self.configureConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  // MARK: - Layout Setup
  // ------------------------------------------------------------
  private func configureConstraints() {
    
    self.buttonView.snp_makeConstraints { (make) -> Void in
      make.top.bottom.centerX.equalTo(self)
      make.left.greaterThanOrEqualTo(self)
      make.right.lessThanOrEqualTo(self)
    }
    
    self.buttonLabel.snp_makeConstraints { (make) -> Void in
      // pads the top and bottom of the label by expanding the superview
      make.top.equalTo(buttonView).offset(14.0)
      make.bottom.equalTo(buttonView).inset(14.0)
      make.center.equalTo(buttonView).priorityRequired()
      
      // I'll need to save these constraints
      self.adjustedWidthConstraints.left = make.left.equalTo(buttonView).offset(48.0).constraint
      self.adjustedWidthConstraints.right = make.right.equalTo(buttonView).inset(48.0).constraint
    }
    
    self.spinnerImageView.snp_makeConstraints { (make) -> Void in
      make.center.equalTo(self.buttonView)
      make.height.width.equalTo(36.0)
    }
  }
  
  private func setupViewHierarchy() {
    self.addSubview(buttonView)
    self.buttonView.addSubview(buttonLabel)
    self.buttonView.addSubview(spinnerImageView)
  }
  
  override func updateConstraints() {
    print("update contraints")

    super.updateConstraints()
  }
  
  // layoutSubviews is very useful to update the view's corner radius as it has available the view's 
  // size and position based on its constraints
  override func layoutSubviews() {
    self.updateCornerRadius()
    
    // I don't know if this is the best solution, but it seems to work out well in this example
    dispatch_once(&checkHeightOnce) { () -> Void in
      self.minButtonWidth = self.frame.size.height
      print("minBtnWid: \(self.minButtonWidth)")
    }
  }
  
  internal func updateCornerRadius() {
    let currentHeight: CGFloat = self.frame.size.height
    self.buttonView.layer.cornerRadius = currentHeight/2.0
  }
  
  
  // MARK: - Helpers -
  // ------------------------------------------------------------
  
  
  // MARK: UI Helpers
  /** Used to update the UI state of the button and label
  */
  private func updateButtonToState(state: FollowButtonState) {
      switch state {
      case .NotFollowing:
        self.buttonLabel.text = "F O L L O W"
        self.buttonView.backgroundColor = ConceptColors.OffWhite
        self.buttonLabel.textColor = ConceptColors.DarkText
        self.currentButtonState = .NotFollowing
        self.buttonLabel.alpha = 1.0
        self.spinnerImageView.alpha = 0.0
        
      case .Following:
        self.buttonLabel.text = "F O L L O W I N G"
        self.buttonView.backgroundColor = ConceptColors.MediumBlue
        self.buttonLabel.textColor = ConceptColors.OffWhite
        self.currentButtonState = .Following
        self.buttonLabel.alpha = 1.0
        self.spinnerImageView.alpha = 0.0
        self.expandButton { complete -> Void in
          self.userInteractionEnabled = true
          self.stopAnimatingSpinner()
        }
        
      case .Loading:
        /*  Why not set the text to an empty string? Its because the view's height
            constraints are being held in place by the label's intrinsic content size.
            In fact, this (the entire animation) works because of the label's frame size
            simply existing. Without it, I would have to adjust way more constraints        */
        self.buttonView.backgroundColor = UIColor.whiteColor()
        self.currentButtonState = .Loading
        self.buttonLabel.alpha = 0.0
        self.spinnerImageView.alpha = 1.0
        self.shrinkButton { complete -> Void in
          self.userInteractionEnabled = true
          self.animateSpinner()
        }
    }
  }
  
  // MARK: Other Helpers
  private func rotationTransform(degrees: CGFloat) -> CATransform3D {
    let radians: CGFloat = degrees * (CGFloat(M_PI) / 180.0)
    return CATransform3DMakeRotation(radians, 0.0, 0.0, -1.0)
  }
  
  
  // MARK: - Animations
  // ------------------------------------------------------------
  internal func shrinkButton(completetion: ((complete: Bool)->Void)? = nil) {
    
    guard self.minButtonWidth != nil && self.minButtonWidth > 0.0 else { return }
    self.userInteractionEnabled = false
   
    self.adjustedWidthConstraints.left?.deactivate()
    self.adjustedWidthConstraints.right?.deactivate()
    self.buttonView.snp_updateConstraints { (make) -> Void in
      make.width.greaterThanOrEqualTo(self.minButtonWidth!)
    }
    self.setNeedsUpdateConstraints()
    
    UIView.animateWithDuration(0.45, animations: { () -> Void in
      self.layoutIfNeeded()
      }, completion: completetion)
  }
  
  internal func expandButton(completetion: ((complete: Bool)->Void)? = nil) {
    self.userInteractionEnabled = false
    
    self.adjustedWidthConstraints.left?.activate()
    self.adjustedWidthConstraints.right?.activate()
    self.setNeedsUpdateConstraints()
    
    UIView.animateWithDuration(0.25, animations: { () -> Void in
      self.layoutIfNeeded()
      }, completion: completetion)
  }
  
  internal func animateSpinner() {
    
    UIView.animateKeyframesWithDuration(1.25, delay: 0.0, options: [.Repeat, .BeginFromCurrentState, .CalculationModePaced], animations: { () -> Void in
      
      UIView.addKeyframeWithRelativeStartTime(0.0,
        relativeDuration: 0.25,
        animations: { () -> Void in
          self.spinnerImageView.layer.transform = self.rotationTransform(90.0)
      })
      
      UIView.addKeyframeWithRelativeStartTime(0.25,
        relativeDuration: 0.25,
        animations: { () -> Void in
          self.spinnerImageView.layer.transform = self.rotationTransform(180.0)
      })
      
      UIView.addKeyframeWithRelativeStartTime(0.50,
        relativeDuration: 0.25,
        animations: { () -> Void in
          self.spinnerImageView.layer.transform = self.rotationTransform(270.0)
      })
      
      UIView.addKeyframeWithRelativeStartTime(0.75,
        relativeDuration: 0.25,
        animations: { () -> Void in
          self.spinnerImageView.layer.transform = self.rotationTransform(360.0)
      })
      
      }) { (complete: Bool) -> Void in
        if complete {
        
        }
    }
    
  }
  
  internal func stopAnimatingSpinner() {
    self.spinnerImageView.layer.removeAllAnimations()
  }
  
  
  // MARK: - Button Control Actions
  // ------------------------------------------------------------
  internal func followButtonTapped(sender: AnyObject?) {
    switch currentButtonState {
    case .NotFollowing:
      self.updateButtonToState(.Loading)
      
    case .Loading:
      self.updateButtonToState(.Following)
      
    case .Following:
      self.updateButtonToState(.NotFollowing)
    }
  }
  
  internal func followButtonHighlighted(sender: AnyObject?) {
    if currentButtonState == .NotFollowing {
      self.buttonLabel.textColor = ConceptColors.MediumBlue
    } else {
      self.buttonLabel.textColor = ConceptColors.DarkText
    }
  }
  
  internal func followButtonReleased(sender: AnyObject?) {
    if currentButtonState == .Following {
      self.buttonLabel.textColor = ConceptColors.DarkText
    } else {
      self.buttonLabel.textColor = ConceptColors.MediumBlue
    }
  }

  
  // MARK: - Lazy Instances
  // ------------------------------------------------------------
  // Note: I like using UIControls over UIView's (or other subclasses, UIButton etc.) for custom behaviors because it gives a
  // little more flexibility for target/actions and doesn't come with any pre-defined action behaviour
  internal lazy var buttonView: UIControl = {
    let control: UIControl = UIControl()
    control.backgroundColor = UIColor.whiteColor()
    control.layer.cornerRadius = 15.0
    control.clipsToBounds = true
    
    control.addTarget(self, action: "followButtonTapped:", forControlEvents: [.TouchUpInside, .TouchUpOutside])
    control.addTarget(self, action: "followButtonHighlighted:", forControlEvents: [.TouchDown, .TouchDragEnter, .TouchDragInside])
    control.addTarget(self, action: "followButtonReleased:", forControlEvents: [.TouchCancel, .TouchDragExit, .TouchDragOutside])
    return control
  }()
  
  internal lazy var buttonLabel: UILabel = {
    var label: UILabel = UILabel()
    label.textColor = ConceptColors.DarkText
    label.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
    label.text = "F O L L O W"
    return label
  }()
  
  internal lazy var spinnerImageView: UIImageView = {
    let imageView: UIImageView = UIImageView(image: UIImage(named: "squareSpinner"))
    imageView.contentMode = .ScaleAspectFit
    imageView.alpha = 0.0
    return imageView
  }()
}
