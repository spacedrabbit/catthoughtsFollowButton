//
//  FollowButton.swift
//  FollowButton
//
//  Created by Louis Tur on 5/28/16.
//  Copyright © 2016 cat.thoughts. All rights reserved.
//

import UIKit
import SnapKit

/**
  - parameter currentState: The button's current state when pressed. Classes that conform to this protocal
    can check for `.Following` and `.NotFollowing`
*/
public protocol FollowButtonDelegate: class {
  func didPressFollowButton(currentState: FollowButtonState)
}

/**
 - note: `.Loading` state isn't used outside of this class. It is not meant to be checked.
*/
public enum FollowButtonState {
  case NotFollowing
  case Following
  case Loading
}

public class FollowButton: UIView {
  
  // Parameter Struct
  private struct FollowButtonOptions {
    private let labelText: String
    private let labelTextColor: UIColor
    private let labelBackgroundColor: UIColor
    private let showSpinner: Bool
    private let showLabel: Bool
  }
  
  private enum FollowButtonTransition {
    case FollowingToNotFollowing
    case NotFollowingToFollowing
  }
  
  // MARK: - Variables
  // ------------------------------------------------------------
  public var delegate: FollowButtonDelegate?
  
  private var minButtonWidth: CGFloat?
  private var minButtonHeight: CGFloat?
  private var checkHeightOnce: dispatch_once_t = 0
  private var adjustedWidthConstraints: (left: Constraint?, right: Constraint?)
  
  private var transitionalState: FollowButtonTransition = .NotFollowingToFollowing
  private var currentButtonState: FollowButtonState = .NotFollowing {
    willSet {
      switch newValue {
      case .NotFollowing: self.updateButtonOptions(self.notFollowingOptions)
      case .Following: self.updateButtonOptions(self.followingOptions)
      case .Loading: self.updateButtonOptions(self.loadingOptions)
      }
    }
  }
  
  // MARK: - Initialization
  // ------------------------------------------------------------
  /**
  Instantiate with a specified `FollowButtonState`
  - parameter state: The state to initialize the button in.
  - note: Do not initialize in the `.Loading` state. If `.Loading` is passed as the paramter, an instance
    of `FollowButton` will be returned in the `.NotFollowing` state
  */
  public convenience init(withState state: FollowButtonState) {
    self.init(frame: CGRectZero)
    
    guard state != .Loading else { return }
    self.updateButtonToState(state)
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setupViewHierarchy()
    self.configureConstraints()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  /** 
   Use this function to finish the button's loading state in either a success state, or failure state.
   - parameter success: 
     - `true` If the button should finish its transition to a new state
     - `false` If the button should return to it's original state
   - note: In a scenario where the button is pressed and going from a `.NotFollowing` -> `.Following`, a value of `true`
      will finish the loading animation and finish the transition to `.Following`. A value of `false` will finish the 
      loading animation and animate back to it's original state, in this case `.NotFollowing`
  */
  internal func finishAnimating(success success: Bool) {
    self.finishTransition(success)
  }

  /// - returns: The button's current `FollowButtonState`
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

  public override func layoutSubviews() {
    self.updateCornerRadius()
    
    // Get the button's height once, once we can get it's size from it's constraints
    dispatch_once(&checkHeightOnce) { () -> Void in
      self.minButtonWidth = self.frame.size.height
      self.minButtonHeight = self.minButtonWidth
    }
  }

  
  // MARK: - Helpers -
  // ------------------------------------------------------------
  
  // MARK: UI Helpers
  /// Used to update the UI state of the button and label.
  private func updateButtonToState(state: FollowButtonState) {
      switch state {
      case .NotFollowing:
        self.currentButtonState = .NotFollowing
        self.expandButton { complete -> Void in
          self.stopAnimatingSpinner()
        }
        
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
  
  /** 
   Starts the button animation and tracks the transition states.
    - parameters: 
      - fromState: Button's original state before being pressed
      - toState: Button's final state after being pressed
  */
  private func transition(fromState fromState: FollowButtonState, toState: FollowButtonState) {
    self.updateButtonToState(.Loading)
    
    if fromState == .NotFollowing {
      self.transitionalState = .NotFollowingToFollowing
    }
    else if fromState == .Following {
      self.transitionalState = .FollowingToNotFollowing
    }
  }
  
  /** 
   Finishes the current animations and updates the button to a new state
   - parameter success: On `true`, the button moves from it's original `fromState` to its new `toState`. On 'false'
   the button returns to it's original `fromState` 
   - seealso: `transition(fromState:toState:)`
   */
  private func finishTransition(success: Bool) {
    let (successState, transitionState): (Bool, FollowButtonTransition) = (success, self.transitionalState)
    
    switch (successState, transitionState) {
    case (true, .NotFollowingToFollowing),
         (false, .FollowingToNotFollowing):
      self.updateButtonToState(.Following)
      
    case (true, .FollowingToNotFollowing),
         (false, .NotFollowingToFollowing):
      self.updateButtonToState(.NotFollowing)
    }
    
  }
  
  private func updateButtonOptions(options: FollowButtonOptions) {
    self.buttonLabel.text = options.labelText
    self.buttonLabel.textColor = options.labelTextColor
    self.buttonView.backgroundColor = options.labelBackgroundColor
    self.buttonLabel.alpha = options.showLabel ? 1.0 : 0.0
    self.spinnerImageView.alpha = options.showSpinner ? 1.0 : 0.0
  }
  
  private func updateCornerRadius() {
    let currentHeight: CGFloat = self.frame.size.height
    self.buttonView.layer.cornerRadius = currentHeight/2.0
  }
  
  private func rotationTransform(degrees: CGFloat) -> CATransform3D {
    let radians: CGFloat = degrees * (CGFloat(M_PI) / 180.0)
    return CATransform3DMakeRotation(radians, 0.0, 0.0, -1.0)
  }
  
  
  // MARK: - Animations
  // ------------------------------------------------------------
  
  // MARK: Button Shrink/Expand
  private func shrinkButton(completetion: ((complete: Bool)->Void)? = nil) {
    
    guard self.minButtonWidth != nil && self.minButtonWidth > 0.0 else { return }
   
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
    
    self.adjustedWidthConstraints.left?.activate()
    self.adjustedWidthConstraints.right?.activate()
    self.setNeedsUpdateConstraints()
    
    UIView.animateWithDuration(0.25, animations: { () -> Void in
      self.layoutIfNeeded()
      }, completion: completetion)
  }
  
  // MARK: Spinner
  private func animateSpinner() {
    self.userInteractionEnabled = false
    
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
      self.transition(fromState: .NotFollowing, toState: .Following)
      self.delegate?.didPressFollowButton(.NotFollowing)
      
    case .Following:
      self.transition(fromState: .Following, toState: .NotFollowing)
      self.delegate?.didPressFollowButton(.Following)
      
    case .Loading:
      return
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
  
  private lazy var notFollowingOptions: FollowButtonOptions = {
    let options = FollowButtonOptions(labelText: "F O L L O W",
      labelTextColor: ConceptColors.DarkText,
      labelBackgroundColor: ConceptColors.OffWhite,
      showSpinner: false, showLabel: true)
    return options
  }()
  
  private lazy var followingOptions: FollowButtonOptions = {
    let options = FollowButtonOptions(labelText: "F O L L O W I N G",
      labelTextColor: ConceptColors.OffWhite,
      labelBackgroundColor: ConceptColors.MediumBlue,
      showSpinner: false, showLabel: true)
    return options
  }()
  
  private lazy var loadingOptions: FollowButtonOptions = {
    let options = FollowButtonOptions(labelText: "",
      labelTextColor: ConceptColors.DarkText,
      labelBackgroundColor: UIColor.whiteColor(),
      showSpinner: true, showLabel: false)
    return options
  }()
}
