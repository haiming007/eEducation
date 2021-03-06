//
//  EEMessageView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EEMessageView.h"
#import "EEMessageViewCell.h"
#import "ReplayViewController.h"

@interface EEMessageView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UITableView *messageTableView;
@property (nonatomic, strong) NSMutableArray *messageArray;

@end

@implementation EEMessageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor yellowColor];
    UITableView *messageTableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
    messageTableView.delegate = self;
    messageTableView.dataSource =self;
    [self addSubview:messageTableView];
    self.messageTableView = messageTableView;
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageArray = [NSMutableArray array];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.messageTableView.frame = self.bounds;
}

- (void)updateTableView {
    [self.messageTableView reloadData];
}

- (void)checkMessageDataLink {
    
    for (SignalRoomModel *messageModel in self.messageArray) {
        
        if(messageModel.link == nil){
            continue;
        }
        
        NSString *regex = @"^/replay/*/*/*/*";
        NSError *error;
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matches = [regular matchesInString:messageModel.link options:0 range:NSMakeRange(0, messageModel.link.length)];
        if(matches != nil && matches.count == 1) {
            NSArray *componentsArray = [messageModel.link componentsSeparatedByString:@"/"];
            if(componentsArray != nil && componentsArray.count == 6) {
                messageModel.roomid = componentsArray[2];
                messageModel.startTime = componentsArray[3];
                messageModel.endTime = componentsArray[4];
                messageModel.content = @"replay recording";
            }
        }
    }
}

- (void)addMessageModel:(SignalRoomModel *)model {
    [self.messageArray addObject:model];
    [self checkMessageDataLink];
    
    [self.messageTableView reloadData];
    if (self.messageArray.count > 0) {
         [self.messageTableView scrollToRowAtIndexPath:
          [NSIndexPath indexPathForRow:[self.messageArray count] - 1 inSection:0] atScrollPosition: UITableViewScrollPositionBottom animated:NO];
     }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EEMessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EEMessageViewCell" owner:self options:nil] firstObject];
    }
    cell.cellWidth = self.bounds.size.width;
    cell.messageModel = self.messageArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SignalRoomModel *messageModel = self.messageArray[indexPath.row];
    if(messageModel.cellHeight > 0){
        return messageModel.cellHeight;
    }
    NSString *str = messageModel.content;
    if(str == nil){
        str = @"";
    }
    CGSize labelSize = [str boundingRectWithSize:CGSizeMake(self.messageTableView.frame.size.width - 38, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.f]} context:nil].size;
    messageModel.cellHeight = labelSize.height + 60;
    return labelSize.height + 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SignalRoomModel *messageModel = self.messageArray[indexPath.row];
    if(messageModel.roomid == nil){
        return;
    }
    
    ReplayViewController *vc = [[ReplayViewController alloc] initWithNibName:@"ReplayViewController" bundle:nil];
    vc.roomid = messageModel.roomid;
    vc.startTime = messageModel.startTime;
    vc.endTime = messageModel.endTime;
    vc.videoPath = messageModel.url;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    UINavigationController *nvc = (UINavigationController*)window.rootViewController;
    if(nvc != nil){
        [nvc.visibleViewController presentViewController:vc animated:YES completion:nil];
    }
    return;
}
@end
