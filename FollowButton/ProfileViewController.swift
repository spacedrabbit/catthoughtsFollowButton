//
//  ProfileViewController.swift
//  FollowButton
//
//  Created by Louis Tur on 5/26/16.
//  Copyright © 2016 cat.thoughts. All rights reserved.
//

import UIKit
import SnapKit

/**
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 Design Idea Found @ http://www.ios.uplabs.com/posts/profile-page-interaction-and-animation
 Designer: Malik, @iOfficialBlack (http://www.ios.uplabs.com/iOfficialBlack)
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 */


class ProfileViewController: UIViewController {
  
  
  // MARK: - Lifecycle -
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupViewHierarchy()
    self.configureConstraints()
    
    self.drawGradientIn(self.profileTopSectionView)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    // You don't need to include self.view.layoutIfNeeded() if you call this draw from here
    // self.drawGradientIn(self.profileTopSectionView)
  }
  
  
  // MARK: - Layout -
  internal func configureConstraints() {
    
    self.profileBackgroundView.snp_makeConstraints { (make) -> Void in
//      make.top.equalTo(self.view).offset(60.0)
//      make.left.equalTo(self.view).offset(22.0)
//      make.right.equalTo(self.view).offset(-22.0)
//      make.bottom.equalTo(self.view).offset(-60.0)

      // the above is equivalent to just this:
      make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(60.0, 22.0, 60.0, 22.0))
    }
    
    self.profileTopSectionView.snp_makeConstraints { (make) -> Void in
      make.top.left.right.equalTo(self.profileBackgroundView) // really get some savings here
      make.bottom.equalTo(self.profileBottomSectionView.snp_top)
    }
    
    self.profileBottomSectionView.snp_makeConstraints { (make) -> Void in
      make.left.right.bottom.equalTo(self.profileBackgroundView)
      make.top.equalTo(self.profileBackgroundView.snp_centerY).multipliedBy(1.30)
    }
    
  }
  
  internal func setupViewHierarchy() {
    self.view.backgroundColor = UIColor.grayColor()
    self.view.addSubview(profileBackgroundView)
    self.profileBackgroundView.addSubview(self.profileTopSectionView)
    self.profileBackgroundView.addSubview(self.profileBottomSectionView)
  }
  
  
  // MARK: - Helpers -
  // MARK: UI Updates
  // ------------------------------------------------------------
  internal func drawGradientIn(view: UIView) {
    self.view.layoutIfNeeded() // call this just before UI updates that utilize frames
    
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [ConceptColors.LightBlue.CGColor, ConceptColors.MediumBlue.CGColor]
    gradientLayer.locations = [0.0, 1.0] // even transition from light blue to medium blue
    gradientLayer.startPoint = CGPointMake(0.0, 0.0) // top-left corner
    gradientLayer.endPoint = CGPointMake(1.0, 1.0) // bottom-right corner
    
    view.layer.addSublayer(gradientLayer)
  }
  
  
  // MARK: - Lazy Instances -
  lazy var profileBackgroundView: UIView = {
    let view: UIView = UIView()
    view.layer.cornerRadius = 12.0
    view.clipsToBounds = true
    return view
  }()
  
  lazy var profileTopSectionView: UIView = {
    let view: UIView = UIView()
    view.backgroundColor = ConceptColors.LightBlue
    return view
  }()
  
  lazy var profileBottomSectionView: UIView = {
    let view: UIView = UIView()
    view.backgroundColor = ConceptColors.OffWhite
    return view
  }()
  
}
