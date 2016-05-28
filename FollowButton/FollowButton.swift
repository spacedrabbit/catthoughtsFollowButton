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
        self.spinnerImageView.alpha = 0.0
        
      case .Following:
        self.buttonLabel.text = "F O L L O W I N G"
        self.buttonView.backgroundColor = ConceptColors.MediumBlue
        self.buttonLabel.textColor = ConceptColors.OffWhite
        self.currentButtonState = .Following
        self.spinnerImageView.alpha = 0.0
        expandButton()
        
      case .Loading:
        // Why not set the text to an empty string? Its because our height
        // constraints are being held by the labels intrinsic content size
        // In fact, this (the entire animation) works because of the label's size
        // Without it, I would have to adjust way more constraints
        self.buttonView.backgroundColor = UIColor.whiteColor()
        self.currentButtonState = .Loading
        self.spinnerImageView.alpha = 1.0
        shrinkButton()
    }
  }
  
  
  // MARK: Other Helpers
  
  
  // MARK: - Animations
  // ------------------------------------------------------------
  internal func shrinkButton() {
    
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
      
      }) { (complete: Bool) -> Void in
        if complete {
          self.userInteractionEnabled = true
        }
    }
  }
  
  internal func expandButton() {
    self.userInteractionEnabled = false
    
    self.adjustedWidthConstraints.left?.activate()
    self.adjustedWidthConstraints.right?.activate()
    self.setNeedsUpdateConstraints()
    
    UIView.animateWithDuration(0.25, animations: { () -> Void in
      
      self.layoutIfNeeded()
      
      }) { (complete: Bool) -> Void in
        if complete {
          self.userInteractionEnabled = true
        }
    }
  }
  
  internal func animateSpinner() {
    
  }
  
  internal func stopAnimatingSpinner() {
    
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
