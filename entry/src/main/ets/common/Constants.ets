/**
 * 全局常量
 */
export class Constants {
  // 播放器默认配置
  static readonly DEFAULT_SEEK_STEP = 10000;       // 默认快进/快退步长 10s
  static readonly DEFAULT_VOLUME_STEP = 0.1;       // 音量调节步长
  static readonly DEFAULT_BRIGHTNESS_STEP = 0.1;   // 亮度调节步长
  static readonly CONTROL_HIDE_DELAY = 5000;       // 控制栏自动隐藏延迟 5s
  static readonly MAX_HISTORY_COUNT = 100;          // 最大历史记录数
  static readonly MAX_RECENT_COUNT = 20;            // 最大最近播放数
  static readonly THUMBNAIL_WIDTH = 320;            // 缩略图宽度
  static readonly THUMBNAIL_HEIGHT = 180;           // 缩略图高度

  // 响应式断点
  static readonly BREAKPOINT_COMPACT = 600;
  static readonly BREAKPOINT_MEDIUM = 840;
  static readonly BREAKPOINT_EXPANDED = 1200;

  // SharedPreferences 名称
  static readonly PREFS_HISTORY = 'play_history';
  static readonly PREFS_SETTINGS = 'user_settings';
  static readonly PREFS_FAVORITES = 'favorites';

  // 支持的视频格式
  static readonly SUPPORTED_FORMATS = [
    '.mp4', '.mkv', '.avi', '.mov', '.flv', '.wmv',
    '.webm', '.ts', '.m4v', '.3gp', '.mpg', '.mpeg'
  ];
}
