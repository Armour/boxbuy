//
//  AccountTableViewCell.h
//  YunGeZi
//
//  Created by Armour on 8/29/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tableViewCellTitle;
@property (weak, nonatomic) IBOutlet UIImageView *tableViewSegueImageView;
@property (weak, nonatomic) IBOutlet UILabel *tableViewInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tableViewNotiIficationImageView;

@end
