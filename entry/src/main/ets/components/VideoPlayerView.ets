import { media } from '@kit.MediaKit';
import { VideoPlayerManager, PlayerCallback } from '../service/VideoPlayerManager';
import { ControlPanel } from './ControlPanel';
import { PlayerState, PlaybackSpeed } from '../common/Enums';
import { PlayHistoryService } from '../service/PlayHistoryService';
import { TimeUtils } from '../utils/TimeUtils';

/**
 * 视频播放视图组件
 * 包含 Video 组件和控制面板
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
      onError: (code: number, msg: string) => {
        console.error(`Playback error [${code}]: ${msg}`);
      },
      onCompleted: () => {
        this.saveProgress();
      }
    });

    // 设置播放源并开始播放
    if (this.videoPath.startsWith('http')) {
      await this.playerManager.setUrlSource(this.videoPath);
    } else {
      await this.playerManager.setSource(this.videoPath);
    }
    await this.playerManager.play();
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}
