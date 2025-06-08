#import <Cordova/CDVPlugin.h>
#import <AkilesSDK/AkilesSDK.h>

@interface AkilesPlugin : CDVPlugin

@property (nonatomic, strong) Akiles *akilesSDK;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CDVInvokedUrlCommand *> *pendingCommands;
@property (nonatomic, strong) Card *currentCard;

- (void)get_session_ids:(CDVInvokedUrlCommand*)command;
- (void)add_session:(CDVInvokedUrlCommand*)command;
- (void)remove_session:(CDVInvokedUrlCommand*)command;
- (void)remove_all_sessions:(CDVInvokedUrlCommand*)command;
- (void)refresh_session:(CDVInvokedUrlCommand*)command;
- (void)refresh_all_sessions:(CDVInvokedUrlCommand*)command;
- (void)get_gadgets:(CDVInvokedUrlCommand*)command;
- (void)get_hardwares:(CDVInvokedUrlCommand*)command;
- (void)action:(CDVInvokedUrlCommand*)command;
- (void)scan:(CDVInvokedUrlCommand*)command;
- (void)sync:(CDVInvokedUrlCommand*)command;
- (void)scan_card:(CDVInvokedUrlCommand*)command;
- (void)update_card:(CDVInvokedUrlCommand*)command;
- (void)close_card:(CDVInvokedUrlCommand*)command;
- (void)cancel:(CDVInvokedUrlCommand*)command;
- (void)is_bluetooth_supported:(CDVInvokedUrlCommand*)command;
- (void)is_card_emulation_supported:(CDVInvokedUrlCommand*)command;
- (void)start_card_emulation:(CDVInvokedUrlCommand *)command;

@end

@interface AkilesActionCallback : NSObject <ActionCallback>

@property (nonatomic, weak) AkilesPlugin *plugin;
@property (nonatomic, strong) NSString *opId;

- (instancetype)initWithPlugin:(AkilesPlugin *)plugin opId:(NSString *)opId;

@end

@interface AkilesSyncCallback : NSObject <SyncCallback>

@property (nonatomic, weak) AkilesPlugin *plugin;
@property (nonatomic, strong) NSString *opId;

- (instancetype)initWithPlugin:(AkilesPlugin *)plugin opId:(NSString *)opId;

@end
