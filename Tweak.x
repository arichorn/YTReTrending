#import "../YouTubeHeader/YTIGuideResponse.h"
#import "../YouTubeHeader/YTIGuideResponseSupportedRenderers.h"
#import "../YouTubeHeader/YTIPivotBarSupportedRenderers.h"
#import "../YouTubeHeader/YTIPivotBarRenderer.h"
#import "../YouTubeHeader/YTIBrowseRequest.h"

static void replaceNotificationsTab(YTIGuideResponse *response) {
    NSMutableArray<YTIGuideResponseSupportedRenderers *> *renderers = [response itemsArray];
    for (YTIGuideResponseSupportedRenderers *guideRenderers in renderers) {
        YTIPivotBarRenderer *pivotBarRenderer = [guideRenderers pivotBarRenderer];
        NSMutableArray<YTIPivotBarSupportedRenderers *> *items = [pivotBarRenderer itemsArray];
        NSUInteger createIndex = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FEuploads"];
        }];
        NSUInteger subscriptionsIndex = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FEsubscriptions"];
        }];
        
        if (createIndex != NSNotFound && subscriptionsIndex != NSNotFound) {
            [items removeObjectAtIndex:createIndex];
            YTIPivotBarSupportedRenderers *notificationsTab = [%c(YTIPivotBarRenderer) pivotSupportedRenderersWithBrowseId:@"FEnotifications" title:@"Notifications" iconType:0];
            [items insertObject:notificationsTab atIndex:createIndex];
            YTIPivotBarSupportedRenderers *subscriptionsTab = [items objectAtIndex:subscriptionsIndex];
            [items removeObjectAtIndex:subscriptionsIndex];
            [items insertObject:subscriptionsTab atIndex:createIndex];
        }
    }
}

%hook YTGuideServiceCoordinator

- (void)handleResponse:(YTIGuideResponse *)response withCompletion:(id)completion {
    replaceNotificationsTab(response);
    %orig(response, completion);
}

- (void)handleResponse:(YTIGuideResponse *)response error:(id)error completion:(id)completion {
    replaceNotificationsTab(response);
    %orig(response, error, completion);
}

%end
