typedef enum {
	PullHeaderViewPulling = 0,
	PullHeaderViewNormal,
	PullHeaderViewLoading,	
} PullHeaderViewState;

@protocol PullHeaderViewDelegate;

@interface PullHeaderView : UIView
{
	PullHeaderViewState _state;

	id _delegate;
    NSDateFormatter *_dateFormatter;
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
    NSString *_pullString;
    NSString *_releaseString;
    NSString *_loadingString;
    NSString *_lastUpdateString;
}

@property(nonatomic, retain) id <PullHeaderViewDelegate> delegate;
@property(nonatomic, retain) NSDateFormatter *dateFormatter;
@property(nonatomic, retain) UILabel *lastUpdatedLabel;
@property(nonatomic, retain) UILabel *statusLabel;
@property(nonatomic, retain) CALayer *arrowImage;
@property(nonatomic, retain) UIActivityIndicatorView *activityView;
@property(nonatomic, retain) NSString *pullString;
@property(nonatomic, retain) NSString *releaseString;
@property(nonatomic, retain) NSString *loadingString;
@property(nonatomic, retain) NSString *lastUpdateString;

- (void)setLastUpdateDate:(NSDate *)date;
- (void)setImage:(UIImage *)image;
- (void)refreshLastUpdatedDate;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)scrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end

@interface PullHeaderView()

- (void)setState:(PullHeaderViewState)aState;

@end

@protocol PullHeaderViewDelegate

- (void)pullHeaderViewDidTriggerRefresh:(PullHeaderView *)view;
- (BOOL)pullHeaderViewDataSourceIsLoading:(PullHeaderView *)view;

@optional

- (NSDate*)pullHeaderViewDataSourceLastUpdated:(PullHeaderView *)view;

@end
