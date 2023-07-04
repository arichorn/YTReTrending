#import "../YouTubeHeader/YTIGuideResponse.h"
#import "../YouTubeHeader/YTIGuideResponseSupportedRenderers.h"
#import "../YouTubeHeader/YTIPivotBarSupportedRenderers.h"
#import "../YouTubeHeader/YTIPivotBarRenderer.h"
#import "../YouTubeHeader/YTIBrowseRequest.h"

static void replaceTab(YTIGuideResponse *response) {
    NSMutableArray<YTIGuideResponseSupportedRenderers *> *renderers = [response itemsArray];
    for (YTIGuideResponseSupportedRenderers *guideRenderers in renderers) {
        YTIPivotBarRenderer *pivotBarRenderer = [guideRenderers pivotBarRenderer];
        NSMutableArray<YTIPivotBarSupportedRenderers *> *items = [pivotBarRenderer itemsArray];
        NSUInteger shortIndex = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FEshorts"];
        }];
        if (shortIndex != NSNotFound) {
            [items removeObjectAtIndex:shortIndex];
            NSUInteger trendingIndex = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
                return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:[%c(YTIBrowseRequest) browseIDForTrendingTab]];
            }];
            if (trendingIndex == NSNotFound) {
                YTIPivotBarSupportedRenderers *trendingTab = [%c(YTIPivotBarRenderer) pivotSupportedRenderersWithBrowseId:[%c(YTIBrowseRequest) browseIDForTrendingTab] title:@"Trending" iconType:36];
                [items insertObject:trendingTab atIndex:1];
            }
        }
    }
}

%hook YTGuideServiceCoordinator

- (void)handleResponse:(YTIGuideResponse *)response withCompletion:(id)completion {
    replaceTab(response);
    %orig(response, completion);
}

- (void)handleResponse:(YTIGuideResponse *)response error:(id)error completion:(id)completion {
    replaceTab(response);
    %orig(response, error, completion);
}

%end
