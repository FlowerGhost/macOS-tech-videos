//
//  ViewController.m
//  AVPlayer
//
//  Created by mac on 2018/8/7.
//  Copyright © 2018年 石彪. All rights reserved.
//

#import "ViewController.h"
#import "SBTool.h"
#import <AVFoundation/AVFoundation.h>
#import "DragAcceptView.h"
#define WEAKSELF __weak typeof(self) weakSelf = self;
#define KCurrentURLPath @"KCurrentURLPath"
@interface ViewController()<DragAcceptViewDelegate>{
    id playbackTimerObserver;
}
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *item;
//封面图片
//@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSButton *imageButton;

//进度条
@property (weak) IBOutlet NSSlider *processSlider;

@property (weak) IBOutlet NSTextField *currentTimeLabel;

@property (weak) IBOutlet NSTextField *totalTimeLabel;
@property (weak) IBOutlet NSButton *playOrPauseBtn;
@property (weak) IBOutlet NSButton *statusPayOrPauseBtn;

@property (weak) IBOutlet NSTextField *nameLabel;

@property (nonatomic,assign) BOOL  canAutoPlay;

@property (nonatomic,strong) NSURL *currentPlayingURL;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.stringValue = NSLocalizedString(@"Music Player", nil);
//    [[NSFileManager defaultManager]removeItemAtURL:[RLMRealmConfiguration defaultConfiguration].fileURL error:nil];
    self.dataArr = [NSMutableArray array];
    RLMResults *results = [VideoURLModel allObjects];
    if (results.count > 0 ) {
        for (VideoURLModel *model in results) {
            NSURL *url = [self urlForBookmark:model.urlData];
            if (url) {
                [self.dataArr addObject:url];
            }
            
        }
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:KCurrentURLPath]) {
        NSNumber *currentNumber = [[NSUserDefaults standardUserDefaults]objectForKey:KCurrentURLPath];
        if (self.dataArr.count == 0) {
            return;
        }
        if (![self.dataArr objectAtIndex:currentNumber.integerValue]) {
            return;
        }
        if (self.dataArr.count-1 >= currentNumber.integerValue) {
            self.currentPlayingURL = self.dataArr[currentNumber.integerValue];
        }
        
    }
    DragAcceptView *acceptView = (DragAcceptView *)self.view;
    acceptView.delegate = self;
//    NSString *path = [[NSBundle mainBundle]pathForResource:@"阿里郎-隔壁泰山" ofType:@"mp3"];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        NSURL *url = [NSURL fileURLWithPath:path];
//        [self createAudioPlayerWithURL:url];
//    }
    
}
-(void)createAudioPlayerWithURL:(NSURL *)url {
    //开始安全域资源
    [url startAccessingSecurityScopedResource];
    _currentPlayingURL = url;
    NSInteger index = [self.dataArr indexOfObject:_currentPlayingURL];
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:index] forKey:KCurrentURLPath];
    if (self.item) {
        [self removeObserver];
        self.item = nil;
        self.player = nil;
    }
    [self initImageView];
    //创建AVPlayerItem
    self.item = [[AVPlayerItem alloc]initWithAsset:[self assetWithURL:url]];
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.item];
    [self initProcessSlider];
    [self addKVO];
    [self addNotificationCenter];
}
//初始化进度条
-(void)initProcessSlider {
    self.processSlider.minValue = 0;
    self.processSlider.integerValue = 0;
    
}
//初始化封面图片
-(void)initImageView {
    [self.imageButton setImage:[NSImage imageNamed:@"1"]];
}
//创建AVURLAsset
-(AVURLAsset *)assetWithURL:(NSURL *)url {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
//    NSMutableDictionary *assetDic = [[NSMutableDictionary alloc]init];
    for (NSString *format in asset.availableMetadataFormats) {
        for (AVMetadataItem *metaDataItem in [asset metadataForFormat:format]) {
            NSLog(@"%@-----%@",metaDataItem.commonKey,metaDataItem.value);
            if ([metaDataItem.commonKey isEqualToString:AVMetadataCommonKeyArtwork]) {
                NSImage *image = [[NSImage alloc]initWithData:(NSData *)metaDataItem.value];
                [self.imageButton setImage:image];
            }
            if ([metaDataItem.commonKey isEqualToString:AVMetadataCommonKeyTitle]) {
                self.titleLabel.stringValue = (NSString *)metaDataItem.value;
            }
        }
    }
    return asset;
}
- (IBAction)playOrPause:(NSButton *)sender {
    if (sender.state == NSControlStateValueOn) {
        self.playOrPauseBtn.state = NSControlStateValueOn;
        self.statusPayOrPauseBtn.state = NSControlStateValueOn;
        [self.player play];
    }else {
        self.playOrPauseBtn.state = NSControlStateValueOff;
        self.statusPayOrPauseBtn.state = NSControlStateValueOff;
        [self.player pause];
    }
}
- (IBAction)handlePreviewOrNextButton:(NSButton *)sender {
    //停止安全域资源
    [_currentPlayingURL stopAccessingSecurityScopedResource];
    if (self.dataArr.count > 0) {
        NSInteger currentIndex = [self.dataArr indexOfObject:_currentPlayingURL];
        if (sender.tag == 1000) {//上一曲
            if (currentIndex - 1 >= 0) {
                self.selectedFileURL = self.dataArr[currentIndex - 1];
            }
        }else {//下一曲
            if (currentIndex + 1 < self.dataArr.count) {
                self.selectedFileURL = self.dataArr[currentIndex + 1];
            }
            
        }
    }
    
}

//MARK: 创建时间监听器
-(void)createTimerObserver {
    if (playbackTimerObserver != nil) {return;}
    WEAKSELF
    playbackTimerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.f, 1.f) queue:NULL usingBlock:^(CMTime time) {
        weakSelf.processSlider.integerValue = [SBTool convertCMTime:time];
        weakSelf.currentTimeLabel.stringValue = [SBTool convertTime:[SBTool convertCMTime:time]];
        if (weakSelf.processSlider.integerValue >= weakSelf.processSlider.maxValue) {
            weakSelf.currentTimeLabel.stringValue = weakSelf.totalTimeLabel.stringValue;
        }
    }];
}
//MARK: 添加KVO
-(void)addKVO {
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)addNotificationCenter {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(avplayerDidEndPlay:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
//MARK: 音乐播放完成走此方法
-(void)avplayerDidEndPlay:(NSNotification *)noti {
    self.playOrPauseBtn.state = NSControlStateValueOff;
    self.statusPayOrPauseBtn.state = NSControlStateValueOff;
    NSInteger currentIndex = [self.dataArr indexOfObject:_currentPlayingURL];
    if (currentIndex + 1 < self.dataArr.count) {
        self.selectedFileURL = self.dataArr[currentIndex + 1];
    }
    //停止安全域资源
    [_currentPlayingURL stopAccessingSecurityScopedResource];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus itemStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (itemStatus) {
            case AVPlayerItemStatusUnknown:
                NSLog(@"AVPlayerItemStatusUnknown");
                break;
            case AVPlayerItemStatusReadyToPlay:
                self.processSlider.maxValue = [SBTool convertCMTime:self.item.duration];
                self.totalTimeLabel.stringValue = [SBTool convertTime:self.processSlider.maxValue];
                [self createTimerObserver];
                if (_canAutoPlay) {
                    _canAutoPlay = NO;
                    [self.player play];
                    self.playOrPauseBtn.state = NSControlStateValueOn;
                    self.statusPayOrPauseBtn.state = NSControlStateValueOn;
                }
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"AVPlayerItemStatusFailed");
                break;
            default:
                break;
        }
    }
}
- (IBAction)changeMusicPlayPosisiton:(NSSlider *)sender {
    [self.player seekToTime:CMTimeMake(sender.doubleValue, 1.0) toleranceBefore:CMTimeMake(1.f, 1.f) toleranceAfter:CMTimeMake(1.f, 1.f)];
    self.playOrPauseBtn.state = NSControlStateValueOn;
    [self.player play];
}

-(void)mouseUp:(NSEvent *)event {
    [super mouseUp:event];
    if (event.clickCount >= 2) {
        [self openFile];
    }
}
//MARK: 打开文件
-(void)openFile {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.canResolveUbiquitousConflicts = YES;
    openPanel.allowsMultipleSelection = YES;
    NSInteger result = [openPanel runModal];
    if (result == NSModalResponseOK) {
        [self.dataArr addObjectsFromArray:openPanel.URLs];;
        self.selectedFileURL = openPanel.URLs.firstObject;
        for (NSURL *url in openPanel.URLs) {
            [self saveURLToDataBaseWithURL:url];
        }
    }
}
//MARK: Setter
-(void)setSelectedFileURL:(NSURL *)selectedFileURL {
    _selectedFileURL = selectedFileURL;
    [self createAudioPlayerWithURL:selectedFileURL];
    _canAutoPlay = YES;
}
-(void)setCurrentPlayingURL:(NSURL *)currentPlayingURL {
    _currentPlayingURL = currentPlayingURL;
    [self createAudioPlayerWithURL:currentPlayingURL];
}
//MARK: 移出监听
-(void)removeObserver {
    [self.item removeObserver:self forKeyPath:@"status"];
    [self.player removeTimeObserver:playbackTimerObserver];
    playbackTimerObserver = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
//MARK: DragAcceptViewDelegate
-(void)dragAcceptView:(DragAcceptView *)dragView draggedFilesWithURLs:(NSArray *)urlArr{
    [self.dataArr addObjectsFromArray:urlArr];
    self.selectedFileURL = urlArr.firstObject;
     for (NSURL *url in urlArr) {
         [self saveURLToDataBaseWithURL:url];
     }
}
-(void)saveURLToDataBaseWithURL:(NSURL *)url {
    RLMResults *results = [VideoURLModel objectsWhere:@"urlPath = %@",url.path];
    if (results.count == 0) {
        [KDefaultRealm transactionWithBlock:^{
            VideoURLModel *model = [[VideoURLModel alloc]init];
            model.urlPath = url.path;
            model.urlData = [self bookmarkForURL:url];
            [KDefaultRealm addObject:model];
        }];
    }
}
 //MARK: 将URL转换成书签数据
 - (NSData*)bookmarkForURL:(NSURL*)url {
     NSError* theError = nil;
     NSData* bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                      includingResourceValuesForKeys:nil
                                       relativeToURL:nil
                                               error:&theError];
     if (theError || (bookmark == nil)) {
         // Handle any errors.
         return nil;
     }
     return bookmark;
 }
//MARK: 将bookmark数据转换成URL
- (NSURL*)urlForBookmark:(NSData*)bookmark {
    BOOL bookmarkIsStale = NO;
    NSError* theError = nil;
    NSURL* bookmarkURL = [NSURL URLByResolvingBookmarkData:bookmark
                                                   options:NSURLBookmarkResolutionWithoutUI | NSURLBookmarkResolutionWithSecurityScope
                                             relativeToURL:nil
                                       bookmarkDataIsStale:&bookmarkIsStale
                                                     error:&theError];
    
    if (bookmarkIsStale || (theError != nil)) {
        // Handle any errors
        return nil;
    }
    return bookmarkURL;
}
-(void)dealloc {
    [self removeObserver];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
