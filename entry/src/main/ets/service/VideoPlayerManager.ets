import { media } from '@kit.MediaKit';
import { fileIo } from '@kit.CoreFileKit';
import { PlayerState, PlaybackSpeed } from '../common/Enums';
import { Constants } from '../common/Constants';

/**
 * 播放器事件回调接口
 */
export interface PlayerCallback {
  onStateChange?: (state: PlayerState) => void;
  onTimeUpdate?: (currentTime: number) => void;
  onDurationUpdate?: (duration: number) => void;
  onBufferingUpdate?: (isBuffering: boolean) => void;
  onError?: (errorCode: number, errorMsg: string) => void;
  onCompleted?: () => void;
}

/**
 * 视频播放器管理类
 * 封装 AVPlayer，提供简洁的播放控制接口
 */
export class VideoPlayerManager {
  private avPlayer: media.AVPlayer | null = null;
  private callback: PlayerCallback | null = null;
  private _state: PlayerState = PlayerState.IDLE;
  private _currentTime: number = 0;
  private _duration: number = 0;
  private _isBuffering: boolean = false;
  private _speed: PlaybackSpeed = PlaybackSpeed.SPEED_1_0;
  private _volume: number = 1.0;
  private _isMuted: boolean = false;
  private openedFd: number = -1;

  // ========== 公开属性 ==========

  get state(): PlayerState {
    return this._state;
  }

  get currentTime(): number {
    return this._currentTime;
  }

  get duration(): number {
    return this._duration;
  }

  get isBuffering(): boolean {
    return this._isBuffering;
  }

  get speed(): PlaybackSpeed {
    return this._speed;
  }

  get volume(): number {
    return this._volume;
  }

  get isMuted(): boolean {
    return this._isMuted;
  }

  get isPlaying(): boolean {
    return this._state === PlayerState.PLAYING;
  }

  // ========== 生命周期 ==========

  /**
   * 初始化播放器
   */
  async init(callback?: PlayerCallback): Promise<void> {
    if (this.avPlayer) {
      await this.release();
    }
    this.avPlayer = await media.createAVPlayer();
    this.callback = callback || null;
    this.setupListeners();
    this._state = PlayerState.INITIALIZED;
  }

  /**
   * 释放播放器资源
   */
  async release(): Promise<void> {
    if (this.avPlayer) {
      this.removeListeners();
      await this.avPlayer.release();
      this.avPlayer = null;
    }
    this.closeFd();
    this._state = PlayerState.IDLE;
    this._currentTime = 0;
    this._duration = 0;
    this._isBuffering = false;
  }

  // ========== 播放源设置 ==========

  /**
   * 设置本地文件播放源
   * @param filePath 本地文件路径
   */
  async setSource(filePath: string): Promise<void> {
    if (!this.avPlayer) {
      throw new Error('Player not initialized');
    }
    this.closeFd();
    const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
    this.openedFd = file.fd;
    this.avPlayer.fdSrc = {
      fd: file.fd,
      offset: 0,
      length: 0
    };
  }

  /**
   * 设置网络URL播放源
   * @param url 视频URL
   */
  async setUrlSource(url: string): Promise<void> {
    if (!this.avPlayer) {
      throw new Error('Player not initialized');
    }
    this.closeFd();
    this.avPlayer.url = url;
  }

  // ========== 播放控制 ==========

  /**
   * 播放
   */
  async play(): Promise<void> {
    await this.avPlayer?.play();
  }

  /**
   * 暂停
   */
  async pause(): Promise<void> {
    await this.avPlayer?.pause();
  }

  /**
   * 停止
   */
  async stop(): Promise<void> {
    await this.avPlayer?.stop();
  }

  /**
   * 切换播放/暂停
   */
  async togglePlayPause(): Promise<void> {
    if (this.isPlaying) {
      await this.pause();
    } else {
      await this.play();
    }
  }

  /**
   * 跳转到指定位置
   * @param timeMs 目标时间（毫秒）
   */
  async seekTo(timeMs: number): Promise<void> {
    if (this.avPlayer) {
      const clampedTime = Math.max(0, Math.min(timeMs, this._duration));
      this.avPlayer.seek(clampedTime);
    }
  }

  /**
   * 快进
   * @param stepMs 步长（毫秒），默认 10s
   */
  async seekForward(stepMs: number = Constants.DEFAULT_SEEK_STEP): Promise<void> {
    await this.seekTo(this._currentTime + stepMs);
  }

  /**
   * 快退
   * @param stepMs 步长（毫秒），默认 10s
   */
  async seekBackward(stepMs: number = Constants.DEFAULT_SEEK_STEP): Promise<void> {
    await this.seekTo(this._currentTime - stepMs);
  }

  /**
   * 设置播放速度
   * @param speed 播放速度
   */
  async setSpeed(speed: PlaybackSpeed): Promise<void> {
    if (this.avPlayer) {
      this.avPlayer.setSpeed(speed as media.PlaybackSpeed);
      this._speed = speed;
    }
  }

  /**
   * 循环播放速度
   */
  async cycleSpeed(): Promise<void> {
    const speeds = [
      PlaybackSpeed.SPEED_0_5,
      PlaybackSpeed.SPEED_0_75,
      PlaybackSpeed.SPEED_1_0,
      PlaybackSpeed.SPEED_1_25,
      PlaybackSpeed.SPEED_1_5,
      PlaybackSpeed.SPEED_2_0
    ];
    const currentIdx = speeds.indexOf(this._speed);
    const nextIdx = (currentIdx + 1) % speeds.length;
    await this.setSpeed(speeds[nextIdx]);
  }

  /**
   * 设置音量
   * @param vol 音量 0.0 - 1.0
   */
  async setVolume(vol: number): Promise<void> {
    if (this.avPlayer) {
      this._volume = Math.max(0, Math.min(1, vol));
      this.avPlayer.setVolume(this._isMuted ? 0 : this._volume);
    }
  }

  /**
   * 静音/取消静音
   */
  async toggleMute(): Promise<void> {
    this._isMuted = !this._isMuted;
    if (this.avPlayer) {
      this.avPlayer.setVolume(this._isMuted ? 0 : this._volume);
    }
  }

  /**
   * 增加音量
   */
  async volumeUp(step: number = Constants.DEFAULT_VOLUME_STEP): Promise<void> {
    await this.setVolume(this._volume + step);
  }

  /**
   * 降低音量
   */
  async volumeDown(step: number = Constants.DEFAULT_VOLUME_STEP): Promise<void> {
    await this.setVolume(this._volume - step);
  }

  // ========== 私有方法 ==========

  private setupListeners(): void {
    if (!this.avPlayer) return;

    this.avPlayer.on('stateChange', (state: string) => {
      const mapped = this.mapState(state);
      this._state = mapped;
      this.callback?.onStateChange?.(mapped);

      // 自动释放完成状态的资源（可选，根据需求决定）
      if (mapped === PlayerState.COMPLETED) {
        this.callback?.onCompleted?.();
      }
    });

    this.avPlayer.on('timeUpdate', (timeMs: number) => {
      this._currentTime = timeMs;
      this.callback?.onTimeUpdate?.(timeMs);
    });

    this.avPlayer.on('durationUpdate', (duration: number) => {
      this._duration = duration;
      this.callback?.onDurationUpdate?.(duration);
    });

    this.avPlayer.on('bufferingUpdate', (type: media.BufferingInfoType) => {
      this._isBuffering = (type === media.BufferingInfoType.BUFFERING_START ||
        type === media.BufferingInfoType.BUFFERING_LOADING);
      this.callback?.onBufferingUpdate?.(this._isBuffering);
    });

    this.avPlayer.on('error', (err) => {
      console.error(`Player error: ${err.code} - ${err.message}`);
      this._state = PlayerState.ERROR;
      this.callback?.onError?.(err.code, err.message);
    });
  }

  private removeListeners(): void {
    if (!this.avPlayer) return;
    this.avPlayer.off('stateChange');
    this.avPlayer.off('timeUpdate');
    this.avPlayer.off('durationUpdate');
    this.avPlayer.off('bufferingUpdate');
    this.avPlayer.off('error');
  }

  private closeFd(): void {
    if (this.openedFd >= 0) {
      try {
        fileIo.closeSync(this.openedFd);
      } catch (e) {
        // ignore
      }
      this.openedFd = -1;
    }
  }

  private mapState(state: string): PlayerState {
    const stateMap: Record<string, PlayerState> = {
      'idle': PlayerState.IDLE,
      'initialized': PlayerState.INITIALIZED,
      'preparing': PlayerState.PREPARING,
      'prepared': PlayerState.PREPARED,
      'playing': PlayerState.PLAYING,
      'paused': PlayerState.PAUSED,
      'stopped': PlayerState.STOPPED,
      'completed': PlayerState.COMPLETED,
      'error': PlayerState.ERROR,
      'released': PlayerState.IDLE
    };
    return stateMap[state] || PlayerState.IDLE;
  }
}
