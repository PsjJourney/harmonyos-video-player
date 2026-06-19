/**
 * 播放器错误码定义
 * 统一管理所有错误类型和对应的用户友好提示
 */

export enum PlayerErrorCode {
  // 通用错误
  UNKNOWN = 0,
  INIT_FAILED = 1001,
  ALREADY_RELEASED = 1002,

  // 文件错误
  FILE_NOT_FOUND = 2001,
  FILE_READ_ERROR = 2002,
  FILE_FORMAT_UNKNOWN = 2003,
  FILE_CORRUPTED = 2004,
  FILE_NO_STREAM = 2005,
  FILE_NO_VIDEO_STREAM = 2006,
  FILE_NO_AUDIO_STREAM = 2007,

  // 解码错误
  DECODER_NOT_FOUND = 3001,
  DECODER_OPEN_FAILED = 3002,
  DECODER_INIT_FAILED = 3003,
  DECODE_ERROR = 3004,
  UNSUPPORTED_CODEC = 3005,

  // 网络错误
  NETWORK_UNAVAILABLE = 4001,
  NETWORK_TIMEOUT = 4002,
  NETWORK_DNS_ERROR = 4003,
  NETWORK_CONNECTION_CLOSED = 4004,
  STREAM_NOT_FOUND = 4005,
  STREAM_FORBIDDEN = 4006,

  // 渲染错误
  RENDERER_INIT_FAILED = 5001,
  RENDERER_SURFACE_ERROR = 5002,
  RENDERER_FORMAT_ERROR = 5003,

  // 音频错误
  AUDIO_INIT_FAILED = 6001,
  AUDIO_OUTPUT_ERROR = 6002,

  // 权限错误
  PERMISSION_DENIED = 7001,
}

/**
 * 错误详情
 */
export interface PlayerError {
  code: PlayerErrorCode;
  title: string;           // 错误标题
  message: string;         // 用户友好提示
  detail: string;          // 技术详情（可展开）
  suggestion: string;      // 建议操作
  recoverable: boolean;    // 是否可恢复
  retryable: boolean;      // 是否可重试
}

/**
 * 错误信息映射表
 */
const ERROR_MAP: Record<number, Omit<PlayerError, 'code' | 'detail'>> = {
  // 通用
  [PlayerErrorCode.UNKNOWN]: {
    title: '播放失败',
    message: '发生未知错误',
    suggestion: '请尝试重新播放，或播放其他视频',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.INIT_FAILED]: {
    title: '初始化失败',
    message: '播放器初始化失败',
    suggestion: '请重启应用后重试',
    recoverable: false,
    retryable: true,
  },
  [PlayerErrorCode.ALREADY_RELEASED]: {
    title: '播放器已释放',
    message: '播放器资源已被释放',
    suggestion: '请重新打开视频',
    recoverable: false,
    retryable: true,
  },

  // 文件错误
  [PlayerErrorCode.FILE_NOT_FOUND]: {
    title: '文件不存在',
    message: '找不到指定的视频文件',
    suggestion: '文件可能已被删除或移动，请检查文件路径',
    recoverable: false,
    retryable: false,
  },
  [PlayerErrorCode.FILE_READ_ERROR]: {
    title: '读取失败',
    message: '无法读取视频文件',
    suggestion: '文件可能被其他应用占用，或存储设备异常',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.FILE_FORMAT_UNKNOWN]: {
    title: '格式不支持',
    message: '无法识别该视频文件的格式',
    suggestion: '请确认文件是否为有效的视频文件，或尝试转换格式',
    recoverable: false,
    retryable: false,
  },
  [PlayerErrorCode.FILE_CORRUPTED]: {
    title: '文件损坏',
    message: '视频文件已损坏或不完整',
    suggestion: '请重新下载或获取完整的视频文件',
    recoverable: false,
    retryable: false,
  },
  [PlayerErrorCode.FILE_NO_STREAM]: {
    title: '无媒体流',
    message: '文件中未找到音视频流',
    suggestion: '请确认这是一个有效的视频文件',
    recoverable: false,
    retryable: false,
  },
  [PlayerErrorCode.FILE_NO_VIDEO_STREAM]: {
    title: '无视频流',
    message: '文件中未找到视频流（可能是纯音频文件）',
    suggestion: '该文件可能是音频文件，请使用音乐播放器打开',
    recoverable: false,
    retryable: false,
  },
  [PlayerErrorCode.FILE_NO_AUDIO_STREAM]: {
    title: '无音频流',
    message: '视频文件中没有音频轨道',
    suggestion: '该视频没有声音，将以静音模式播放',
    recoverable: true,
    retryable: false,
  },

  // 解码错误
  [PlayerErrorCode.DECODER_NOT_FOUND]: {
    title: '解码器缺失',
    message: '未找到该视频格式对应的解码器',
    suggestion: '该编码格式暂不支持，请尝试将视频转换为 H.264/H.265 格式',
    recoverable: false,
    retryable: false,
  },
  [PlayerErrorCode.DECODER_OPEN_FAILED]: {
    title: '解码器启动失败',
    message: '无法初始化视频解码器',
    suggestion: '设备可能不支持该编码的硬件加速，正在尝试软件解码...',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.DECODER_INIT_FAILED]: {
    title: '解码器初始化失败',
    message: '解码器初始化过程中出错',
    suggestion: '请尝试重新播放，或播放其他视频',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.DECODE_ERROR]: {
    title: '解码出错',
    message: '视频解码过程中发生错误',
    suggestion: '可能是视频帧数据异常，尝试跳过当前片段',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.UNSUPPORTED_CODEC]: {
    title: '编码不支持',
    message: '该视频使用的编码格式暂不支持',
    suggestion: '请将视频转换为 H.264 (MP4) 格式后重试',
    recoverable: false,
    retryable: false,
  },

  // 网络错误
  [PlayerErrorCode.NETWORK_UNAVAILABLE]: {
    title: '网络不可用',
    message: '当前无法连接到网络',
    suggestion: '请检查 WiFi 或移动数据连接后重试',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.NETWORK_TIMEOUT]: {
    title: '网络超时',
    message: '网络连接超时',
    suggestion: '网络信号可能较弱，请切换到更好的网络环境后重试',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.NETWORK_DNS_ERROR]: {
    title: 'DNS 解析失败',
    message: '无法解析服务器地址',
    suggestion: '请检查网络设置，或稍后重试',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.NETWORK_CONNECTION_CLOSED]: {
    title: '连接中断',
    message: '与服务器的连接被中断',
    suggestion: '请检查网络稳定性后重试',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.STREAM_NOT_FOUND]: {
    title: '资源不存在',
    message: '服务器上未找到该视频资源',
    suggestion: '视频可能已被删除，请确认链接是否有效',
    recoverable: false,
    retryable: false,
  },
  [PlayerErrorCode.STREAM_FORBIDDEN]: {
    title: '访问被拒绝',
    message: '服务器拒绝访问该视频资源',
    suggestion: '视频可能需要登录或权限，请确认后重试',
    recoverable: false,
    retryable: false,
  },

  // 渲染错误
  [PlayerErrorCode.RENDERER_INIT_FAILED]: {
    title: '渲染器初始化失败',
    message: '无法初始化视频渲染器',
    suggestion: '请尝试退出全屏后重新播放',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.RENDERER_SURFACE_ERROR]: {
    title: '渲染表面异常',
    message: '视频渲染表面不可用',
    suggestion: '请尝试退出并重新进入播放页面',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.RENDERER_FORMAT_ERROR]: {
    title: '像素格式异常',
    message: '视频像素格式无法转换',
    suggestion: '请尝试使用软件解码模式播放',
    recoverable: true,
    retryable: true,
  },

  // 音频错误
  [PlayerErrorCode.AUDIO_INIT_FAILED]: {
    title: '音频初始化失败',
    message: '无法初始化音频输出设备',
    suggestion: '请检查音频设备是否被占用，或静音后播放',
    recoverable: true,
    retryable: true,
  },
  [PlayerErrorCode.AUDIO_OUTPUT_ERROR]: {
    title: '音频输出异常',
    message: '音频播放过程中出错',
    suggestion: '音频将被静音，视频继续播放',
    recoverable: true,
    retryable: false,
  },

  // 权限错误
  [PlayerErrorCode.PERMISSION_DENIED]: {
    title: '权限不足',
    message: '没有访问该文件的权限',
    suggestion: '请在系统设置中授予应用存储权限',
    recoverable: false,
    retryable: false,
  },
};

/**
 * 根据 FFmpeg 错误码映射到播放器错误码
 */
export function mapFFmpegError(ffmpegErrorCode: number, ffmpegErrorMsg: string): PlayerErrorCode {
  // AVERROR 常见错误码
  const ETIMEDOUT = -110;
  const ECONNREFUSED = -111;
  const EHOSTUNREACH = -113;
  const ENOENT = -2;
  const EACCES = -13;
  const EIO = -5;
  const ENOMEM = -12;
  const ENOSPC = -28;
  const ENODATA = -61;
  const ENOEXEC = -8;

  if (ffmpegErrorCode === ETIMEDOUT) return PlayerErrorCode.NETWORK_TIMEOUT;
  if (ffmpegErrorCode === ECONNREFUSED) return PlayerErrorCode.NETWORK_CONNECTION_CLOSED;
  if (ffmpegErrorCode === EHOSTUNREACH) return PlayerErrorCode.NETWORK_UNAVAILABLE;
  if (ffmpegErrorCode === ENOENT) return PlayerErrorCode.FILE_NOT_FOUND;
  if (ffmpegErrorCode === EACCES) return PlayerErrorCode.PERMISSION_DENIED;
  if (ffmpegErrorCode === EIO) return PlayerErrorCode.FILE_READ_ERROR;
  if (ffmpegErrorCode === ENOMEM) return PlayerErrorCode.DECODER_INIT_FAILED;

  // 根据错误消息关键词匹配
  const msg = ffmpegErrorMsg.toLowerCase();
  if (msg.includes('timeout')) return PlayerErrorCode.NETWORK_TIMEOUT;
  if (msg.includes('connection') && msg.includes('refused')) return PlayerErrorCode.NETWORK_CONNECTION_CLOSED;
  if (msg.includes('no such file')) return PlayerErrorCode.FILE_NOT_FOUND;
  if (msg.includes('permission')) return PlayerErrorCode.PERMISSION_DENIED;
  if (msg.includes('codec') && msg.includes('not found')) return PlayerErrorCode.DECODER_NOT_FOUND;
  if (msg.includes('invalid data') || msg.includes('corrupt')) return PlayerErrorCode.FILE_CORRUPTED;
  if (msg.includes('format') && msg.includes('not supported')) return PlayerErrorCode.FILE_FORMAT_UNKNOWN;
  if (msg.includes('no stream')) return PlayerErrorCode.FILE_NO_STREAM;
  if (msg.includes('http') && msg.includes('404')) return PlayerErrorCode.STREAM_NOT_FOUND;
  if (msg.includes('http') && msg.includes('403')) return PlayerErrorCode.STREAM_FORBIDDEN;

  return PlayerErrorCode.UNKNOWN;
}

/**
 * 构建完整的 PlayerError 对象
 */
export function createPlayerError(
  code: PlayerErrorCode,
  detail?: string
): PlayerError {
  const template = ERROR_MAP[code] || ERROR_MAP[PlayerErrorCode.UNKNOWN];
  return {
    code,
    ...template,
    detail: detail || `错误码: ${code}`,
  };
}

/**
 * 构建用户友好的错误提示文本
 */
export function formatErrorMessage(error: PlayerError): string {
  let text = error.message;
  if (error.suggestion) {
    text += `\n💡 ${error.suggestion}`;
  }
  return text;
}
