#import "CTInboxSimpleMessageCell.h"

@implementation CTInboxSimpleMessageCell

- (void)setup {
    self.avPlayerContainerView.hidden = YES;
    self.actionView.hidden = YES;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnMessageTapGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.cellImageView sd_cancelCurrentAnimationImagesLoad];
    self.cellImageView.animatedImage = nil;
}

- (void)doLayoutForMessage:(CleverTapInboxMessage *)message {
    if (!message.content || message.content.count < 0) {
        return;
    }
    CleverTapInboxMessageContent *content = message.content[0];
    self.cellImageView.hidden = YES;
    self.avPlayerControlsView.alpha = 0.0;
    self.avPlayerContainerView.hidden = YES;
    self.activityIndicator.hidden = YES;
    if (content.mediaUrl == nil || [content.mediaUrl isEqual: @""]) {
        self.imageViewHeightContraint.priority = 999;
        self.imageViewLRatioContraint.priority = 750;
        self.imageViewPRatioContraint.priority = 750;
    } else if ([message.orientation.uppercaseString isEqualToString:@"P"] || message.orientation == nil ) {
        self.imageViewPRatioContraint.priority = 999;
        self.imageViewLRatioContraint.priority = 750;
        self.imageViewHeightContraint.priority = 750;
    } else {
        self.imageViewHeightContraint.priority = 750;
        self.imageViewPRatioContraint.priority = 750;
        self.imageViewLRatioContraint.priority = 999;
    }
    [self configureActionView:!content.actionHasLinks];
    self.playButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.playButton.layer.borderWidth = 2.0;
    self.titleLabel.textColor = [CTInAppUtils ct_colorWithHexString:content.titleColor];
    self.bodyLabel.textColor = [CTInAppUtils ct_colorWithHexString:content.messageColor];
    self.dateLabel.textColor = [CTInAppUtils ct_colorWithHexString:content.titleColor];
    [self layoutSubviews];
    [self layoutIfNeeded];
}

- (void)setupMessage:(CleverTapInboxMessage *)message {
    self.message = message;
    if (!message.content || message.content.count < 0) {
        self.cellImageView.image = nil;
        self.cellImageView.animatedImage = nil;
        self.titleLabel.text = nil;
        self.bodyLabel.text = nil;
        self.dateLabel.text = nil;
        return;
    }
    
    CleverTapInboxMessageContent *content = message.content[0];
    self.cellImageView.image = nil;
    self.cellImageView.animatedImage = nil;
    self.cellImageView.clipsToBounds = YES;
    self.titleLabel.text = content.title;
    self.bodyLabel.text = content.message;
    self.dateLabel.text = message.relativeDate;
    self.readView.hidden = message.isRead;
    self.readViewWidthContraint.constant = message.isRead ? 0 : 16;
    [self setupInboxMessageActions:content];
    self.cellImageView.contentMode = content.mediaIsGif ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
    if (content.mediaUrl && !content.mediaIsVideo && !content.mediaIsAudio) {
        self.cellImageView.hidden = NO;
        [self.cellImageView sd_setImageWithURL:[NSURL URLWithString:content.mediaUrl]
                              placeholderImage:nil
                                       options:self.sdWebImageOptions];
    } else if (content.mediaIsVideo || content.mediaIsAudio) {
        [self setupMediaPlayer];
    }
}

@end
