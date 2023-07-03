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

        // Find the index of the "Create" tab
        NSUInteger createIndex = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FEuploads"];
        }];

        // Find the index of the "Subscriptions" tab
        NSUInteger subscriptionsIndex = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FEsubscriptions"];
        }];

        if (createIndex != NSNotFound && subscriptionsIndex != NSNotFound) {
            // Remove the "Create" tab
            [items removeObjectAtIndex:createIndex];

            // Create the "Notifications" tab
            YTIPivotBarSupportedRenderers *notificationsTab = [%c(YTIPivotBarRenderer) pivotSupportedRenderersWithBrowseId:@"FEnotifications" title:@"Notifications" iconType:0];

            // Insert the "Notifications" tab at the index of the "Subscriptions" tab
            [items insertObject:notificationsTab atIndex:subscriptionsIndex + 1];
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
