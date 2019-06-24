//
//  customerInfoCell.m
//  swy
//
//  Created by panyuwen on 2019/6/11.
//  Copyright © 2019 panyuwen. All rights reserved.
//

#import "customerInfoCell.h"

@implementation customerInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _industoryName.numberOfLines = 0;
    _industoryName.font = [UIFont systemFontOfSize:13];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
