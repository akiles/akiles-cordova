#import "AkilesPlugin.h"
#import <Cordova/CDVPlugin.h>

@implementation AkilesPlugin

- (void)pluginInitialize {
    [super pluginInitialize];

    if (@available(iOS 13.0, *)) {
        self.akilesSDK = [[Akiles alloc] init];
    }
    self.pendingCommands = [[NSMutableDictionary alloc] init];
    self.currentCard = nil;
}

#pragma mark - Session Management

- (void)get_session_ids:(CDVInvokedUrlCommand*)command {
    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK getSessionIDs:^(NSArray<NSString *> * _Nullable sessionIDs, NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVPluginResult* result;
        if (error) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[strongSelf errorToDict:error]];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:(sessionIDs ?: @[])];
        }
        [strongSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)add_session:(CDVInvokedUrlCommand*)command {
    NSString *token = [command.arguments objectAtIndex:0];
    if (!token || ![token isKindOfClass:[NSString class]]) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid token parameter"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK addSession:token completion:^(NSString * _Nullable sessionID, NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVPluginResult* result;
        if (error) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[strongSelf errorToDict:error]];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:sessionID];
        }
        [strongSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)remove_session:(CDVInvokedUrlCommand*)command {
    NSString *sessionID = [command.arguments objectAtIndex:0];
    if (!sessionID || ![sessionID isKindOfClass:[NSString class]]) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid sessionID parameter"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK removeSession:sessionID completion:^(NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVPluginResult* result;
        if (error) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[strongSelf errorToDict:error]];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        [strongSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)remove_all_sessions:(CDVInvokedUrlCommand*)command {
    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK removeAllSessions:^(NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVPluginResult* result;
        if (error) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[strongSelf errorToDict:error]];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        [strongSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)refresh_session:(CDVInvokedUrlCommand*)command {
    NSString *sessionID = [command.arguments objectAtIndex:0];
    if (!sessionID || ![sessionID isKindOfClass:[NSString class]]) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid sessionID parameter"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK refreshSession:sessionID completion:^(NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVPluginResult* result;
        if (error) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[strongSelf errorToDict:error]];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        [strongSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)refresh_all_sessions:(CDVInvokedUrlCommand*)command {
    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK refreshAllSessions:^(NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVPluginResult* result;
        if (error) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[strongSelf errorToDict:error]];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        [strongSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

#pragma mark - Gadgets and Hardware

- (void)get_gadgets:(CDVInvokedUrlCommand*)command {
    NSString *sessionID = [command.arguments objectAtIndex:0];
    if (!sessionID || ![sessionID isKindOfClass:[NSString class]]) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid sessionID parameter"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK getGadgets:sessionID completion:^(NSArray<Gadget *> * _Nullable gadgets, NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVPluginResult* result;
        if (error) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[strongSelf errorToDict:error]];
        } else {
            NSMutableArray *gadgetsArray = [[NSMutableArray alloc] init];
            for (Gadget *gadget in gadgets) {
                [gadgetsArray addObject:[strongSelf gadgetToDict:gadget]];
            }
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:gadgetsArray];
        }
        [strongSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)get_hardwares:(CDVInvokedUrlCommand*)command {
    NSString *sessionID = [command.arguments objectAtIndex:0];
    if (!sessionID || ![sessionID isKindOfClass:[NSString class]]) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid sessionID parameter"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK getHardwares:sessionID completion:^(NSArray<Hardware *> * _Nullable hardwares, NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVPluginResult* result;
        if (error) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[strongSelf errorToDict:error]];
        } else {
            NSMutableArray *hardwaresArray = [[NSMutableArray alloc] init];
            for (Hardware *hardware in hardwares) {
                [hardwaresArray addObject:[strongSelf hardwareToDict:hardware]];
            }
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:hardwaresArray];
        }
        [strongSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

#pragma mark - Actions

- (void)action:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count < 5) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid parameters"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    NSString *opId = [command.arguments objectAtIndex:0];
    NSString *sessionID = [command.arguments objectAtIndex:1];
    NSString *gadgetID = [command.arguments objectAtIndex:2];
    NSString *actionID = [command.arguments objectAtIndex:3];
    NSDictionary *optionsDict = [command.arguments objectAtIndex:4];

    if (!opId || !sessionID || !gadgetID || !actionID) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid parameters"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    ActionOptions *options = [ActionOptions initWithDefaults];
    if (optionsDict && [optionsDict isKindOfClass:[NSDictionary class]]) {
        if (optionsDict[@"requestBluetoothPermission"] != nil) {
            options.requestBluetoothPermission = [optionsDict[@"requestBluetoothPermission"] boolValue];
        }
        if (optionsDict[@"requestLocationPermission"] != nil) {
            options.requestLocationPermission = [optionsDict[@"requestLocationPermission"] boolValue];
        }
        if (optionsDict[@"useInternet"] != nil) {
            options.useInternet = [optionsDict[@"useInternet"] boolValue];
        }
        if (optionsDict[@"useBluetooth"] != nil) {
            options.useBluetooth = [optionsDict[@"useBluetooth"] boolValue];
        }
    }

    [self.pendingCommands setObject:command forKey:opId];

    AkilesActionCallback *callback = [[AkilesActionCallback alloc] initWithPlugin:self opId:opId];

    [self.akilesSDK action:sessionID gadgetID:gadgetID actionID:actionID options:options callback:callback completion:^{
        // Completion handler - action is done
    }];
}

- (void)start_card_emulation:(CDVInvokedUrlCommand*)command {
    NSString *language = [command argumentAtIndex:0];

    [self.akilesSDK startCardEmulation:language completion:^(BOOL success, NSError * _Nullable error) {
        CDVPluginResult *pluginResult = nil;
        if (error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark - Scanning

- (void)scan:(CDVInvokedUrlCommand*)command {
    NSString *opId = [command.arguments objectAtIndex:0];
    if (!opId || ![opId isKindOfClass:[NSString class]]) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid opId parameter"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    [self.pendingCommands setObject:command forKey:opId];

    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK scan:^(Hardware * _Nonnull hardware) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        NSDictionary *event = @{
            @"type": @"discover",
            @"hardware": [strongSelf hardwareToDict:hardware]
        };

        CDVInvokedUrlCommand *cmd = [strongSelf.pendingCommands objectForKey:opId];
        if (cmd) {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:event];
            [result setKeepCallbackAsBool:YES];
            [strongSelf.commandDelegate sendPluginResult:result callbackId:cmd.callbackId];
        }
    } completion:^(NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVInvokedUrlCommand *cmd = [strongSelf.pendingCommands objectForKey:opId];
        if (cmd) {
            [strongSelf.pendingCommands removeObjectForKey:opId];

            NSDictionary *event;
            if (error) {
                event = @{
                    @"type": @"error",
                    @"error": [strongSelf errorToDict:error]
                };
            } else {
                event = @{@"type": @"success"};
            }

            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:event];
            [result setKeepCallbackAsBool:NO];
            [strongSelf.commandDelegate sendPluginResult:result callbackId:cmd.callbackId];
        }
    }];
}

#pragma mark - Sync

- (void)sync:(CDVInvokedUrlCommand*)command {
    if (command.arguments.count < 3) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid parameters"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    NSString *opId = [command.arguments objectAtIndex:0];
    NSString *sessionID = [command.arguments objectAtIndex:1];
    NSString *hardwareID = [command.arguments objectAtIndex:2];

    if (!opId || !sessionID || !hardwareID) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid parameters"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    [self.pendingCommands setObject:command forKey:opId];

    AkilesSyncCallback *callback = [[AkilesSyncCallback alloc] initWithPlugin:self opId:opId];

    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK sync:sessionID hardwareID:hardwareID callback:callback completion:^(NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVInvokedUrlCommand *cmd = [strongSelf.pendingCommands objectForKey:opId];
        if (cmd) {
            [strongSelf.pendingCommands removeObjectForKey:opId];

            NSDictionary *event;
            if (error) {
                event = @{
                    @"type": @"error",
                    @"error": [strongSelf errorToDict:error]
                };
            } else {
                event = @{@"type": @"success"};
            }

            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:event];
            [result setKeepCallbackAsBool:NO];
            [strongSelf.commandDelegate sendPluginResult:result callbackId:cmd.callbackId];
        }
    }];
}

#pragma mark - Card Operations

- (void)scan_card:(CDVInvokedUrlCommand*)command {
    NSString *opId = [command.arguments objectAtIndex:0];
    if (!opId || ![opId isKindOfClass:[NSString class]]) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid opId parameter"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    [self.pendingCommands setObject:command forKey:opId];

    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK scanCard:^(Card * _Nullable card, NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVInvokedUrlCommand *cmd = [strongSelf.pendingCommands objectForKey:opId];
        if (cmd) {
            [strongSelf.pendingCommands removeObjectForKey:opId];

            CDVPluginResult* result;
            if (error) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[strongSelf errorToDict:error]];
            } else if (card) {
                strongSelf.currentCard = card;
                NSData *uidData = [card getUid];
                NSString *uidHex = [strongSelf dataToHexString:uidData];

                NSDictionary *cardDict = @{
                    @"isAkilesCard": @([card isAkilesCard]),
                    @"uid": uidHex
                };
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:cardDict];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No card scanned"];
            }
            [strongSelf.commandDelegate sendPluginResult:result callbackId:cmd.callbackId];
        }
    }];
}

- (void)update_card:(CDVInvokedUrlCommand*)command {
    if (!self.currentCard) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No card available"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    __weak __typeof__(self) weakSelf = self;
    [self.currentCard update:^(NSError * _Nullable error) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVPluginResult* result;
        if (error) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:[strongSelf errorToDict:error]];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        [strongSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)close_card:(CDVInvokedUrlCommand*)command {
    self.currentCard = nil;
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark - Cancel

- (void)cancel:(CDVInvokedUrlCommand*)command {
    NSString *opId = [command.arguments objectAtIndex:0];
    if (!opId || ![opId isKindOfClass:[NSString class]]) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid opId parameter"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    [self.pendingCommands removeObjectForKey:opId];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark - Support Methods

- (void)is_bluetooth_supported:(CDVInvokedUrlCommand*)command {
    BOOL isSupported = [self.akilesSDK isBluetoothSupported];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isSupported];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)is_secure_nfc_supported:(CDVInvokedUrlCommand*)command {
    BOOL isSupported = true;
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isSupported];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)is_card_emulation_supported:(CDVInvokedUrlCommand*)command {
    __weak __typeof__(self) weakSelf = self;
    [self.akilesSDK isCardEmulationSupported:^(BOOL isSupported) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isSupported];
        [strongSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

#pragma mark - Helper Methods

- (NSDictionary *)errorToDict:(NSError *)error {
    return NSDictionaryFromNSError(error);
}


- (NSDictionary *)gadgetToDict:(Gadget *)gadget {
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (Action *action in gadget.actions) {
        [actions addObject:@{
            @"id": action.id,
            @"name": action.name
        }];
    }

    return @{
        @"id": gadget.id,
        @"name": gadget.name,
        @"actions": actions
    };
}

- (NSDictionary *)hardwareToDict:(Hardware *)hardware {
    return @{
        @"id": hardware.id,
        @"name": hardware.name,
        @"productId": hardware.productId,
        @"revisionId": hardware.revisionId,
        @"sessions": hardware.sessions
    };
}

- (void)sendEvent:(CDVInvokedUrlCommand *)command event:(NSDictionary *)event keepCallback:(BOOL)keepCallback {
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:event];
    [result setKeepCallbackAsBool:keepCallback];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (NSString *)dataToHexString:(NSData *)data {
    const unsigned char *bytes = (const unsigned char *)[data bytes];
    NSMutableString *hex = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < [data length]; i++) {
        [hex appendFormat:@"%02X", bytes[i]];
    }
    return [hex copy];
}

@end

#pragma mark - Action Callback Implementation

@implementation AkilesActionCallback

- (instancetype)initWithPlugin:(AkilesPlugin *)plugin opId:(NSString *)opId {
    self = [super init];
    if (self) {
        self.plugin = plugin;
        self.opId = opId;
    }
    return self;
}

- (void)onSuccess {
    CDVInvokedUrlCommand *command = [self.plugin.pendingCommands objectForKey:self.opId];
    if (command) {
        NSDictionary *event = @{@"type": @"success"};
        [self.plugin sendEvent:command event:event keepCallback:YES];
    }
}

- (void)onError:(NSError *)error {
    CDVInvokedUrlCommand *command = [self.plugin.pendingCommands objectForKey:self.opId];
    if (command) {
        NSDictionary *event = @{
            @"type": @"error",
            @"error": [self.plugin errorToDict:error]
        };
        [self.plugin sendEvent:command event:event keepCallback:YES];
    }
}

- (void)onInternetStatus:(ActionInternetStatus)status {
    CDVInvokedUrlCommand *command = [self.plugin.pendingCommands objectForKey:self.opId];
    if (command) {
        NSString *statusString = NSStringFromActionInternetStatus(status);
        NSDictionary *event = @{
            @"type": @"internet_status",
            @"status": statusString
        };
        [self.plugin sendEvent:command event:event keepCallback:YES];
    }
}

- (void)onInternetSuccess {
    CDVInvokedUrlCommand *command = [self.plugin.pendingCommands objectForKey:self.opId];
    if (command) {
        NSDictionary *event = @{@"type": @"internet_success"};
        [self.plugin sendEvent:command event:event keepCallback:YES];
    }
}

- (void)onInternetError:(NSError *)error {
    CDVInvokedUrlCommand *command = [self.plugin.pendingCommands objectForKey:self.opId];
    if (command) {
        NSDictionary *event = @{
            @"type": @"internet_error",
            @"error": [self.plugin errorToDict:error]
        };
        [self.plugin sendEvent:command event:event keepCallback:YES];
    }
}

- (void)onBluetoothStatus:(ActionBluetoothStatus)status {
    CDVInvokedUrlCommand *command = [self.plugin.pendingCommands objectForKey:self.opId];
    if (command) {
        NSString *statusString = NSStringFromActionBluetoothStatus(status);
        NSDictionary *event = @{
            @"type": @"bluetooth_status",
            @"status": statusString
        };
        [self.plugin sendEvent:command event:event keepCallback:YES];
    }
}

- (void)onBluetoothStatusProgress:(float)percent {
    CDVInvokedUrlCommand *command = [self.plugin.pendingCommands objectForKey:self.opId];
    if (command) {
        NSDictionary *event = @{
            @"type": @"bluetooth_status_progress",
            @"percent": @(percent)
        };
        [self.plugin sendEvent:command event:event keepCallback:YES];
    }
}

- (void)onBluetoothSuccess {
    CDVInvokedUrlCommand *command = [self.plugin.pendingCommands objectForKey:self.opId];
    if (command) {
        NSDictionary *event = @{@"type": @"bluetooth_success"};
        [self.plugin sendEvent:command event:event keepCallback:YES];
    }
}

- (void)onBluetoothError:(NSError *)error {
    CDVInvokedUrlCommand *command = [self.plugin.pendingCommands objectForKey:self.opId];
    if (command) {
        NSDictionary *event = @{
            @"type": @"bluetooth_error",
            @"error": [self.plugin errorToDict:error]
        };
        [self.plugin sendEvent:command event:event keepCallback:YES];
    }
}

- (NSString *)internetStatusToString:(ActionInternetStatus)status {
    switch (status) {
        case ActionInternetStatusExecutingAction:
            return @"EXECUTING_ACTION";
        case ActionInternetStatusAcquiringLocation:
            return @"ACQUIRING_LOCATION";
        case ActionInternetStatusWaitingForLocationInRadius:
            return @"WAITING_FOR_LOCATION_IN_RADIUS";
        default:
            return @"UNKNOWN";
    }
}

- (NSString *)bluetoothStatusToString:(ActionBluetoothStatus)status {
    switch (status) {
        case ActionBluetoothStatusScanning:
            return @"SCANNING";
        case ActionBluetoothStatusConnecting:
            return @"CONNECTING";
        case ActionBluetoothStatusSyncingDevice:
            return @"SYNCING_DEVICE";
        case ActionBluetoothStatusSyncingServer:
            return @"SYNCING_SERVER";
        case ActionBluetoothStatusExecutingAction:
            return @"EXECUTING_ACTION";
        default:
            return @"UNKNOWN";
    }
}

@end

#pragma mark - Sync Callback Implementation

@implementation AkilesSyncCallback

- (instancetype)initWithPlugin:(AkilesPlugin *)plugin opId:(NSString *)opId {
    self = [super init];
    if (self) {
        self.plugin = plugin;
        self.opId = opId;
    }
    return self;
}

- (void)onStatus:(SyncStatus)status {
    CDVInvokedUrlCommand *command = [self.plugin.pendingCommands objectForKey:self.opId];
    if (command) {
        NSString *statusString = NSStringFromSyncStatus(status);
        NSDictionary *event = @{
            @"type": @"status",
            @"status": statusString
        };
        [self.plugin sendEvent:command event:event keepCallback:YES];
    }
}

- (void)onStatusProgress:(float)percent {
    CDVInvokedUrlCommand *command = [self.plugin.pendingCommands objectForKey:self.opId];
    if (command) {
        NSDictionary *event = @{
            @"type": @"status_progress",
            @"percent": @(percent)
        };
        [self.plugin sendEvent:command event:event keepCallback:YES];
    }
}

- (NSString *)syncStatusToString:(SyncStatus)status {
    switch (status) {
        case SyncStatusScanning:
            return @"SCANNING";
        case SyncStatusConnecting:
            return @"CONNECTING";
        case SyncStatusSyncingDevice:
            return @"SYNCING_DEVICE";
        case SyncStatusSyncingServer:
            return @"SYNCING_SERVER";
        default:
            return @"UNKNOWN";
    }
}

@end
