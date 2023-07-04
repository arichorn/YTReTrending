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

        BOOL notificationsTabExists = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FEnotifications"];
        }] != NSNotFound;
        
        if (!notificationsTabExists) {
            // Find the "Subscriptions" tab
            NSUInteger subscriptionsIndex = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
                return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FEsubscriptions"];
            }];
            
            if (subscriptionsIndex != NSNotFound) {
                YTIPivotBarSupportedRenderers *notificationsTab = [%c(YTIPivotBarRenderer) pivotSupportedRenderersWithBrowseId:@"FEnotifications" title:@"Notifications" iconType:0];
                [items insertObject:notificationsTab atIndex:subscriptionsIndex + 1];
            }
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
