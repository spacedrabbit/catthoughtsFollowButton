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
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 Thanks for looking! Check me out on Twitter and >catthoughts
 - author: Louis Tur [@louistur](https://twitter.com/louistur) / [catthoughts](http://catthoughts.ghost.io/)
 
 Design found @[Uplabs](http://www.ios.uplabs.com/posts/profile-page-interaction-and-animation)
 Designer: Malik, [@iOfficialBlack](https://twitter.com/iOfficialBlack) / [@Uplabs](http://www.ios.uplabs.com/iOfficialBlack)
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 */
class ProfileViewController: UIViewController, FollowButtonDelegate {
  
  
  // MARK: - Lifecycle -
  // ------------------------------------------------------------
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupViewHierarchy()
    self.configureConstraints()
    
    self.drawGradientIn(self.profileTopSectionView)
  }
  
  
  // MARK: - Layout -
  // ------------------------------------------------------------
  internal func configureConstraints() {
    
    self.profileBackgroundView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(60.0, 22.0, 60.0, 22.0))
    }
    
    self.profileTopSectionView.snp_makeConstraints { (make) -> Void in
      make.top.left.right.equalTo(self.profileBackgroundView)
      make.bottom.equalTo(self.profileBottomSectionView.snp_top)
    }
    
    self.profileBottomSectionView.snp_makeConstraints { (make) -> Void in
      make.left.right.bottom.equalTo(self.profileBackgroundView)
      make.top.equalTo(self.profileBackgroundView.snp_centerY).multipliedBy(1.30)
    }
    
    self.followButton.snp_makeConstraints { (make) -> Void in
      make.centerY.equalTo(self.profileBottomSectionView.snp_top)
      make.centerX.equalTo(self.profileBottomSectionView)
      make.height.width.greaterThanOrEqualTo(0.0).priority(990.0)
    }
  }
  
  internal func setupViewHierarchy() {
    self.view.backgroundColor = UIColor.grayColor()
    self.followButton.delegate = self
    
    self.view.addSubview(profileBackgroundView)
    self.profileBackgroundView.addSubview(self.profileTopSectionView)
    self.profileBackgroundView.addSubview(self.profileBottomSectionView)
    self.profileBackgroundView.addSubview(self.followButton)
  }
  
  
  // MARK: - FollowButtonDelegate
  func didPressFollowButton(currentState: FollowButtonState) {
  
    if currentState == .Following || currentState == .NotFollowing {
      let threeSecondsFromNow: NSDate = NSDate(timeInterval: 3.0, sinceDate: NSDate())
      let fakeNetworkRequestTimer: NSTimer = NSTimer(fireDate: threeSecondsFromNow, interval: 0.0, target: self, selector: "finishFakeNetworkRequest", userInfo: nil, repeats: false)

      NSRunLoop.currentRunLoop().addTimer(fakeNetworkRequestTimer, forMode: NSDefaultRunLoopMode)
    }
    
  }

  func finishFakeNetworkRequest() {
    self.followButton.finishAnimating(success: true)
  }
  
  
  // MARK: - Helpers -
  // MARK: UI Updates
  // ------------------------------------------------------------
  internal func drawGradientIn(view: UIView) {
    self.view.layoutIfNeeded()
    
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [FollowButtonColors.LightBlue.CGColor, FollowButtonColors.MediumBlue.CGColor]
    gradientLayer.locations = [0.0, 1.0] // even transition from light blue to medium blue
    gradientLayer.startPoint = CGPointMake(0.0, 0.0) // top-left corner
    gradientLayer.endPoint = CGPointMake(1.0, 1.0) // bottom-right corner
    
    view.layer.addSublayer(gradientLayer)
  }
  
  
  // MARK: - Lazy Instances -
  // ------------------------------------------------------------
  lazy var profileBackgroundView: UIView = {
    let view: UIView = UIView()
    view.layer.cornerRadius = 12.0
    view.clipsToBounds = true
    return view
  }()
  
  lazy var profileTopSectionView: UIView = {
    let view: UIView = UIView()
    view.backgroundColor = FollowButtonColors.LightBlue
    return view
  }()
  
  lazy var profileBottomSectionView: UIView = {
    let view: UIView = UIView()
    view.backgroundColor = FollowButtonColors.OffWhite
    return view
  }()
  
  lazy var followButton: FollowButton = FollowButton(withState: .NotFollowing)
}
