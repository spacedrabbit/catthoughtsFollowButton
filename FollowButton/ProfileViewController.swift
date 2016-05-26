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
  
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupViewHierarchy()
    self.configureConstraints()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  
  // MARK: - Layout
  internal func configureConstraints() {
    
  }
  
  internal func setupViewHierarchy() {
    self.view.backgroundColor = UIColor.grayColor()
    self.view.addSubview(profileBackgroundView)
    self.profileBackgroundView.addSubview(self.profileTopSectionView)
    self.profileBackgroundView.addSubview(self.profileBottomSectionView)
  }
  
  
  // MARK: - Lazy Instances
  lazy var profileBackgroundView: UIView = {
    let view: UIView = UIView()
    view.layer.cornerRadius = 12.0
    view.clipsToBounds = true
    return view
  }()
  
  lazy var profileTopSectionView: UIView = {
    let view: UIView = UIView()
    return view
  }()
  
  lazy var profileBottomSectionView: UIView = {
    let view: UIView = UIView()
    view.backgroundColor = ConceptColors.OffWhite
    return view
  }()
  
}
