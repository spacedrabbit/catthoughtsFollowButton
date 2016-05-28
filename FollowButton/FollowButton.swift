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
  
  
  // MARK: - UI Helpers
  // ------------------------------------------------------------
  /** Used to update the UI state of the button and label
  */
  private func updateButtonToState(state: FollowButtonState) {
    switch state {
    case .NotFollowing:
      self.buttonLabel.text = "F O L L O W"
      self.buttonView.backgroundColor = ConceptColors.OffWhite
      self.buttonLabel.textColor = ConceptColors.DarkText
      
    case .Following:
      self.buttonLabel.text = "F O L L O W I N G"
      self.buttonView.backgroundColor = ConceptColors.MediumBlue
      self.buttonLabel.textColor = ConceptColors.OffWhite
      
    case .Loading:
      self.buttonLabel.text = ""
      self.buttonView.backgroundColor = ConceptColors.OffWhite
    }
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
