//
//  FollowButton.swift
//  FollowButton
//
//  Created by Louis Tur on 5/28/16.
//  Copyright © 2016 cat.thoughts. All rights reserved.
//

import UIKit
import SnapKit


protocol FollowButtonDelegate: class {
  func didPressFollowButton(currentState: FollowButtonState)
}

internal enum FollowButtonState {
  case NotFollowing
  case Following
  case Loading
}

internal class FollowButton: UIView {
  
  internal struct FollowButtonOptions {
    internal let labelText: String
    internal let textColor: UIColor
    internal let backgroundColor: UIColor
    internal let showSpinner: Bool
    internal let showLabel: Bool
  }
  
  // MARK: - Variables
  // ------------------------------------------------------------
  internal var delegate: FollowButtonDelegate?
  
  private var adjustedWidthConstraints: (left: Constraint?, right: Constraint?)
  private var minButtonWidth: CGFloat?
  private var minButtonHeight: CGFloat?
  private var checkHeightOnce: dispatch_once_t = 0
  
  private var currentButtonState: FollowButtonState = .NotFollowing {
    willSet {
      switch newValue {
      case .NotFollowing: self.updateButtonOptions(self.notFollowingOptionsConfig)
      case .Following: self.updateButtonOptions(self.followingOptionsConfig)
      case .Loading: self.updateButtonOptions(self.loadingOptionsConfig)
      }
    }
  }
  
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
  
  internal func finishAnimating(success: Bool) {
    if success {
      self.followButtonTapped(nil)
    }
    else {
      self.updateButtonToState(self.currentButtonState)
    }
  }
  
  internal func currentState() -> FollowButtonState {
    return self.currentButtonState
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
    super.updateConstraints()
  }
  
  // layoutSubviews is very useful to update the view's corner radius as it has available the view's 
  // size and position based on its constraints
  override func layoutSubviews() {
    self.updateCornerRadius()
    
    // I don't know if this is the best solution, but it seems to work out well in this example
    dispatch_once(&checkHeightOnce) { () -> Void in
      self.minButtonWidth = self.frame.size.height
      self.minButtonHeight = self.minButtonWidth
      print("minBtnWid: \(self.minButtonWidth)")
    }
  }

  
  // MARK: - Helpers -
  // ------------------------------------------------------------
  
  // MARK: UI Helpers
  /** Used to update the UI state of the button and label
  */
  private func updateButtonToState(state: FollowButtonState) {
      switch state {
      case .NotFollowing:
        self.currentButtonState = .NotFollowing
        
      case .Following:
        self.currentButtonState = .Following

        self.expandButton { complete -> Void in
          self.stopAnimatingSpinner()
        }
        
      case .Loading:
        self.currentButtonState = .Loading

        self.shrinkButton { complete -> Void in
          self.animateSpinner()
        }
    }
  }
  
  private func updateButtonOptions(options: FollowButtonOptions) {
    self.buttonLabel.text = options.labelText
    self.buttonLabel.textColor = options.textColor
    self.buttonView.backgroundColor = options.backgroundColor
    self.buttonLabel.alpha = options.showLabel ? 1.0 : 0.0
    self.spinnerImageView.alpha = options.showSpinner ? 1.0 : 0.0
  }
  
  private func updateCornerRadius() {
    let currentHeight: CGFloat = self.frame.size.height
    self.buttonView.layer.cornerRadius = currentHeight/2.0
  }
  
  
  // MARK: Other Helper
  private func rotationTransform(degrees: CGFloat) -> CATransform3D {
    let radians: CGFloat = degrees * (CGFloat(M_PI) / 180.0)
    return CATransform3DMakeRotation(radians, 0.0, 0.0, -1.0)
  }
  
  
  // MARK: - Animations
  // ------------------------------------------------------------
  
  // MARK: Button Shrink/Expand
  private func shrinkButton(completetion: ((complete: Bool)->Void)? = nil) {
    
    guard self.minButtonWidth != nil && self.minButtonWidth > 0.0 else { return }
    self.userInteractionEnabled = false
   
    self.adjustedWidthConstraints.left?.deactivate()
    self.adjustedWidthConstraints.right?.deactivate()
    self.buttonView.snp_updateConstraints { (make) -> Void in
      make.width.height.greaterThanOrEqualTo(self.minButtonWidth!)
    }
    self.setNeedsUpdateConstraints()
    
    UIView.animateWithDuration(0.35, animations: { () -> Void in
      self.layoutIfNeeded()
      }, completion: completetion)
  }
  
  private func expandButton(completetion: ((complete: Bool)->Void)? = nil) {
    
    guard self.minButtonWidth != nil && self.minButtonWidth > 0.0 else { return }
    self.userInteractionEnabled = false
    
    self.adjustedWidthConstraints.left?.activate()
    self.adjustedWidthConstraints.right?.activate()
    self.setNeedsUpdateConstraints()
    
    UIView.animateWithDuration(0.25, animations: { () -> Void in
      self.layoutIfNeeded()
      }, completion: completetion)
  }
  
  // MARK: Spinner
  private func animateSpinner() {
    self.userInteractionEnabled = true
    
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
  
  private func stopAnimatingSpinner() {
    self.userInteractionEnabled = true
    self.spinnerImageView.layer.removeAllAnimations()
  }
  
  
  // MARK: - Button Control Actions
  // ------------------------------------------------------------
  internal func followButtonTapped(sender: AnyObject?) {
    switch currentButtonState {
    case .NotFollowing:
      self.updateButtonToState(.Loading)
      self.delegate?.didPressFollowButton(.Following)
      
    case .Loading:
      self.updateButtonToState(.Following)
      self.delegate?.didPressFollowButton(.Loading)
      
    case .Following:
      self.updateButtonToState(.NotFollowing)
      self.delegate?.didPressFollowButton(.NotFollowing)
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
  /* I like using UIControls over UIView's (or other subclasses, UIButton etc.) for custom behaviors because it gives a
     little more flexibility for target/actions */
  private lazy var buttonView: UIControl = {
    let control: UIControl = UIControl()
    control.backgroundColor = UIColor.whiteColor()
    control.layer.cornerRadius = 15.0
    control.clipsToBounds = true
    
    control.addTarget(self, action: "followButtonTapped:", forControlEvents: [.TouchUpInside, .TouchUpOutside])
    control.addTarget(self, action: "followButtonHighlighted:", forControlEvents: [.TouchDown, .TouchDragEnter, .TouchDragInside])
    control.addTarget(self, action: "followButtonReleased:", forControlEvents: [.TouchCancel, .TouchDragExit, .TouchDragOutside])
    return control
  }()
  
  private lazy var buttonLabel: UILabel = {
    var label: UILabel = UILabel()
    label.textColor = ConceptColors.DarkText
    label.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
    label.text = "F O L L O W"
    return label
  }()
  
  private lazy var spinnerImageView: UIImageView = {
    let imageView: UIImageView = UIImageView(image: UIImage(named: "squareSpinner"))
    imageView.contentMode = .ScaleAspectFit
    imageView.alpha = 0.0
    return imageView
  }()
  
  private lazy var notFollowingOptionsConfig: FollowButtonOptions = {
    let options = FollowButtonOptions(labelText: "F O L L O W",
      textColor: ConceptColors.DarkText,
      backgroundColor: ConceptColors.OffWhite,
      showSpinner: false, showLabel: true)
    return options
  }()
  
  private lazy var followingOptionsConfig: FollowButtonOptions = {
    let options = FollowButtonOptions(labelText: "F O L L O W I N G",
      textColor: ConceptColors.OffWhite,
      backgroundColor: ConceptColors.MediumBlue,
      showSpinner: false, showLabel: true)
    return options
  }()
  
  private lazy var loadingOptionsConfig: FollowButtonOptions = {
    let options = FollowButtonOptions(labelText: "",
      textColor: ConceptColors.DarkText,
      backgroundColor: UIColor.whiteColor(),
      showSpinner: true, showLabel: false)
    return options
  }()
}
