import { media } from '@kit.MediaKit';
import { VideoPlayerManager, PlayerCallback, PlaybackEngine } from '../service/VideoPlayerManager';
import { ControlPanel } from './ControlPanel';
import { ErrorDialog, ErrorToast } from './ErrorDialog';
import { PlayerState, PlaybackSpeed } from '../common/Enums';
import { PlayerError, PlayerErrorCode, createPlayerError, mapFFmpegError } from '../common/PlayerError';
import { PlayHistoryService } from '../service/PlayHistoryService';

/**
 * 视频播放视图组件
 * 包含 Video 组件、控制面板和错误处理
 */
@Component
export struct VideoPlayerView {
  @Link videoPath: string;
  @Link videoTitle: string;
  @Link videoId: string;

  onBack: () => void = () => {};
  onNext: () => void = () => {};
  onPrevious: () => void = () => {};

  @State playerManager: VideoPlayerManager = new VideoPlayerManager();
  @State playerState: PlayerState = PlayerState.IDLE;
  @State currentTime: number = 0;
  @State duration: number = 0;
  @State isPlaying: boolean = false;
  @State isBuffering: boolean = false;
  @State currentSpeed: PlaybackSpeed = PlaybackSpeed.SPEED_1_0;
  @State isMuted: boolean = false;
  @State isFullscreen: boolean = false;

  // 错误状态
  @State showErrorDialog: boolean = false;
  @State showErrorToast: boolean = false;
  @State currentError: PlayerError | null = null;
  @State toastMessage: string = '';

  // 引擎信息
  @State engineType: string = '';

  private surfaceId: string = '';
  private saveTimerId: number = -1;

  async aboutToAppear(): Promise<void> {
    await this.playerManager.init({
      onStateChange: (state: PlayerState) => {
        this.playerState = state;
        this.isPlaying = state === PlayerState.PLAYING;
      },
      onTimeUpdate: (timeMs: number) => {
        this.currentTime = timeMs;
        // 定期保存播放进度（每5秒）
        if (this.saveTimerId < 0) {
          this.saveTimerId = setInterval(() => {
            this.saveProgress();
          }, 5000) as unknown as number;
        }
      },
      onDurationUpdate: (dur: number) => {
        this.duration = dur;
      },
      onBufferingUpdate: (buffering: boolean) => {
        this.isBuffering = buffering;
      },
      onError: (error: PlayerError) => {
        this.handleError(error);
      },
      onCompleted: () => {
        this.saveProgress();
      }
    });

    // 设置播放源并开始播放
    try {
      if (this.videoPath.startsWith('http')) {
        await this.playerManager.setUrlSource(this.videoPath);
      } else {
        await this.playerManager.setSource(this.videoPath);
      }
      this.engineType = this.playerManager.engineType;
      await this.playerManager.play();
    } catch (e) {
      const errMsg = (e as Error).message || '未知错误';
      const error = createPlayerError(PlayerErrorCode.UNKNOWN, errMsg);
      this.handleError(error);
    }
  }

  async aboutToDisappear(): Promise<void> {
    if (this.saveTimerId >= 0) {
      clearInterval(this.saveTimerId);
      this.saveTimerId = -1;
    }
    await this.saveProgress();
    await this.playerManager.release();
  }

  /**
   * 处理错误
   */
  private handleError(error: PlayerError): void {
    console.error(`播放错误 [${error.code}]: ${error.message}`);

    // 某些错误用 Toast（非阻断式）
    if (error.code === PlayerErrorCode.FILE_NO_AUDIO_STREAM ||
        error.code === PlayerErrorCode.AUDIO_OUTPUT_ERROR) {
      this.toastMessage = error.message;
      this.showErrorToast = true;
      // Toast 5秒后自动消失
      setTimeout(() => {
        this.showErrorToast = false;
      }, 5000) as unknown as number;
      return;
    }

    // 其他错误用弹窗
    this.currentError = error;
    this.showErrorDialog = true;
  }

  /**
   * 重试播放
   */
  private async retryPlay(): Promise<void> {
    this.currentError = null;
    this.showErrorDialog = false;

    try {
      // 重新初始化播放器
      await this.playerManager.release();
      await this.playerManager.init();

      if (this.videoPath.startsWith('http')) {
        await this.playerManager.setUrlSource(this.videoPath);
      } else {
        await this.playerManager.setSource(this.videoPath);
      }
      this.engineType = this.playerManager.engineType;
      await this.playerManager.play();
    } catch (e) {
      const errMsg = (e as Error).message || '重试失败';
      const error = createPlayerError(PlayerErrorCode.UNKNOWN, `重试失败: ${errMsg}`);
      this.handleError(error);
    }
  }

  /**
   * 保存播放进度
   */
  private async saveProgress(): Promise<void> {
    if (this.duration <= 0) return;
    try {
      await PlayHistoryService.getInstance().saveRecord({
        videoId: this.videoId,
        title: this.videoTitle,
        path: this.videoPath,
        lastPosition: this.currentTime,
        duration: this.duration,
        timestamp: Date.now()
      });
    } catch (e) {
      console.warn('Save progress failed:', e);
    }
  }

  build() {
    Stack() {
      // 视频渲染区域
      Video({
        src: this.videoPath,
        surfaceId: this.surfaceId
      })
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .onStart(() => {
          this.isPlaying = true;
        })
        .onPause(() => {
          this.isPlaying = false;
        })
        .onFinish(() => {
          this.isPlaying = false;
        })
        .onError(() => {
          this.isPlaying = false;
          // Video 组件的 error 回调信息有限，提示用户
          if (!this.currentError) {
            const error = createPlayerError(
              PlayerErrorCode.DECODE_ERROR,
              '系统 Video 组件播放出错，可尝试切换到软解码模式'
            );
            this.handleError(error);
          }
        })

      // 控制面板覆盖层
      ControlPanel({
        currentTime: this.currentTime,
        duration: this.duration,
        isPlaying: this.isPlaying,
        playerState: this.playerState,
        currentSpeed: this.currentSpeed,
        isMuted: this.isMuted,
        isBuffering: this.isBuffering,
        onPlayPause: async () => {
          await this.playerManager.togglePlayPause();
        },
        onSeek: async (timeMs: number) => {
          await this.playerManager.seekTo(timeMs);
        },
        onSeekForward: async () => {
          await this.playerManager.seekForward();
        },
        onSeekBackward: async () => {
          await this.playerManager.seekBackward();
        },
        onSpeedChange: async () => {
          await this.playerManager.cycleSpeed();
          this.currentSpeed = this.playerManager.speed;
        },
        onToggleMute: async () => {
          await this.playerManager.toggleMute();
          this.isMuted = this.playerManager.isMuted;
        },
        onPrevious: () => this.onPrevious(),
        onNext: () => this.onNext(),
        onFullscreen: () => {
          this.isFullscreen = !this.isFullscreen;
        }
      })

      // 引擎类型标签（调试用，可移除）
      if (this.engineType) {
        Row() {
          Text(this.engineType)
            .fontSize(10)
            .fontColor('#66FFFFFF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('rgba(0,0,0,0.4)')
            .borderRadius(4)
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .padding({ right: 8, top: 4 })
      }

      // 错误提示条（非阻断式）
      ErrorToast({
        visible: this.showErrorToast,
        message: this.toastMessage,
        retryable: true,
        onRetry: () => this.retryPlay(),
        onDismiss: () => { this.showErrorToast = false; }
      })
        .width('100%')
        .position({ x: 0, y: 48 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .bindSheet($$this.showErrorDialog, this.ErrorSheetBuilder(), {
      height: SheetSize.AUTO,
      preferType: SheetType.CENTER,
      maskColor: 'rgba(0,0,0,0.6)',
      showClose: false
    })
  }

  @Builder
  ErrorSheetBuilder() {
    Column({ space: 0 }) {
      // 头部图标 + 标题
      Column({ space: 12 }) {
        Stack() {
          Circle()
            .width(64)
            .height(64)
            .fillColor('#FFF3E0')
          Text('⚠')
            .fontSize(32)
        }

        Text(this.currentError?.title || '播放失败')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ top: 24, bottom: 16 })

      // 错误码
      Row() {
        Text(`错误码: ${this.currentError?.code || 0}`)
          .fontSize(11)
          .fontColor('#999999')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ bottom: 16 })

      Divider().color('#F0F0F0').height(1)

      // 错误消息
      Column({ space: 8 }) {
        Text(this.currentError?.message || '发生未知错误')
          .fontSize(15)
          .fontColor('#555555')
          .textAlign(TextAlign.Center)
          .padding({ top: 16 })

        if (this.currentError?.suggestion) {
          Row({ space: 6 }) {
            Text('💡')
              .fontSize(14)
            Text(this.currentError?.suggestion || '')
              .fontSize(13)
              .fontColor('#888888')
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 8 })
          .alignItems(VerticalAlign.Top)
        }

        // 技术详情
        if (this.currentError?.detail) {
          Text(this.currentError?.detail || '')
            .fontSize(11)
            .fontColor('#AAAAAA')
            .fontFamily('monospace')
            .padding(12)
            .width('100%')
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ left: 24, right: 24, top: 8 })
            .copyOption(CopyOptions.LocalDevice)
        }
      }
      .padding({ bottom: 20 })

      Divider().color('#F0F0F0').height(1)

      // 按钮栏
      Row({ space: 0 }) {
        Button('关闭')
          .fontSize(15)
          .fontColor('#999999')
          .backgroundColor('#FFFFFF')
          .layoutWeight(1)
          .height(48)
          .type(ButtonType.Normal)
          .borderRadius(0)
          .onClick(() => {
            this.showErrorDialog = false;
          })

        Divider().vertical(true).color('#F0F0F0').height(32)

        if (this.currentError?.retryable) {
          Button('重试')
            .fontSize(15)
            .fontColor('#FF4081')
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#FFFFFF')
            .layoutWeight(1)
            .height(48)
            .type(ButtonType.Normal)
            .borderRadius(0)
            .onClick(() => {
              this.showErrorDialog = false;
              this.retryPlay();
            })
        }
      }
      .width('100%')
      .height(48)
    }
    .width('100%')
  }
}
