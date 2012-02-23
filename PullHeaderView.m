#import "PullHeaderView.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation PullHeaderView

@synthesize delegate = _delegate, dateFormatter = _dateFormatter, lastUpdatedLabel = _lastUpdatedLabel, statusLabel = _statusLabel, arrowImage = _arrowImage, activityView = _activityView, pullString = _pullString, releaseString = _releaseString, loadingString = _loadingString, lastUpdateString = _lastUpdateString;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        UIColor *color = [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0];

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];

        // create the text
        _pullString = NSLocalizedString(@"Pull down to refresh...", nil);
        _releaseString = NSLocalizedString(@"Release to refresh...", nil);
        _loadingString = NSLocalizedString(@"Loading...", nil);
        _lastUpdateString = NSLocalizedString(@"Last Updated: %@", nil);
        
        // create the date formatter
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        // create the update label
        _lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
        _lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
        _lastUpdatedLabel.textColor = color;
        _lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        _lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        _lastUpdatedLabel.backgroundColor = [UIColor clearColor];
        _lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:_lastUpdatedLabel];
        
        // create the text label
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
        _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _statusLabel.textColor = color;
        _statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        _statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:_statusLabel];
        
        // create the image
        _arrowImage = [CALayer layer];
        _arrowImage.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
        _arrowImage.contentsGravity = kCAGravityResizeAspect;
        _arrowImage.contents = (id)[UIImage imageNamed:@"blueArrow.png"].CGImage;

        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        {
            _arrowImage.contentsScale = [[UIScreen mainScreen] scale];
        }

        [[self layer] addSublayer:_arrowImage];

        // create the activity
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
        [self addSubview:_activityView];

        // set the normal state
        [self setState:PullHeaderViewNormal];
    }

    return self;
}

- (void)setLastUpdateDate:(NSDate *)date
{
    _lastUpdatedLabel.text = [NSString stringWithFormat:_lastUpdateString, [_dateFormatter stringFromDate:date]];
}

- (void)setImage:(UIImage *)image
{
    _arrowImage.contents = (id)image.CGImage;
}

- (void)refreshLastUpdatedDate
{
    if ([_delegate respondsToSelector:@selector(PullHeaderViewDataSourceLastUpdated:)])
    {
        NSDate *date = [_delegate pullHeaderViewDataSourceLastUpdated:self];
        [self setLastUpdateDate:date];
    }
    else
    {
        _lastUpdatedLabel.text = nil;
    }
}

- (void)setState:(PullHeaderViewState)aState
{
    switch (aState)
    {
        case PullHeaderViewPulling:
            _statusLabel.text = _releaseString;

            [CATransaction begin];
            [CATransaction setAnimationDuration:0.18f];
            _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            [CATransaction commit];

            break;

        case PullHeaderViewNormal:
            if (_state == PullHeaderViewPulling)
            {
                [CATransaction begin];
                [CATransaction setAnimationDuration:0.18f];
                _arrowImage.transform = CATransform3DIdentity;
                [CATransaction commit];
            }

            _statusLabel.text = _pullString;

            [_activityView stopAnimating];

            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
            _arrowImage.hidden = NO;
            _arrowImage.transform = CATransform3DIdentity;
            [CATransaction commit];

            [self refreshLastUpdatedDate];

            break;

        case PullHeaderViewLoading:
            _statusLabel.text = _loadingString;

            [_activityView startAnimating];

            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
            _arrowImage.hidden = YES;
            [CATransaction commit];

            break;

        default:
            break;
    }

    _state = aState;
}

#pragma mark ScrollView Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_state == PullHeaderViewLoading)
    {
        CGFloat offset = MIN(MAX(scrollView.contentOffset.y * -1, 0), 60);
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
    }
    else
    {
        if (scrollView.isDragging)
        {
            BOOL _loading = NO;

            if ([_delegate respondsToSelector:@selector(pullHeaderViewDataSourceIsLoading:)])
            {
                _loading = [_delegate pullHeaderViewDataSourceIsLoading:self];
            }

            if (_state == PullHeaderViewPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading)
            {
                [self setState:PullHeaderViewNormal];
            }
            else
            {
                if (_state == PullHeaderViewNormal && scrollView.contentOffset.y < -65.0f && !_loading)
                {
                    [self setState:PullHeaderViewPulling];
                }
            }

            if (scrollView.contentInset.top != 0)
            {
                scrollView.contentInset = UIEdgeInsetsZero;
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
{
    BOOL _loading = NO;

    if ([_delegate respondsToSelector:@selector(pullHeaderViewDataSourceIsLoading:)])
    {
        _loading = [_delegate pullHeaderViewDataSourceIsLoading:self];
    }

    if (scrollView.contentOffset.y <= - 65.0f && !_loading)
    {
        if ([_delegate respondsToSelector:@selector(pullHeaderViewDidTriggerRefresh:)])
        {
            [_delegate pullHeaderViewDidTriggerRefresh:self];
        }

        [self setState:PullHeaderViewLoading];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
    }
}

- (void)scrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];

    [self setState:PullHeaderViewNormal];
}

@end
