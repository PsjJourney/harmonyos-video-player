/**
 * 时间工具类
 */
export class TimeUtils {
  /**
   * 格式化时间（毫秒 -> HH:MM:SS 或 MM:SS）
   * @param timeMs 毫秒
   * @returns 格式化的时间字符串
   */
  static formatTime(timeMs: number): string {
    if (timeMs < 0) timeMs = 0;
    const totalSeconds = Math.floor(timeMs / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    if (hours > 0) {
      return `${this.padZero(hours)}:${this.padZero(minutes)}:${this.padZero(seconds)}`;
    }
    return `${this.padZero(minutes)}:${this.padZero(seconds)}`;
  }

  /**
   * 格式化时长（友好显示）
   * @param durationMs 毫秒
   * @returns 如 "1小时23分钟" 或 "45分钟"
   */
  static formatDuration(durationMs: number): string {
    const totalMinutes = Math.floor(durationMs / 60000);
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;

    if (hours > 0) {
      return `${hours}小时${minutes > 0 ? minutes + '分钟' : ''}`;
    }
    return `${minutes}分钟`;
  }

  /**
   * 格式化相对时间
   * @param timestamp 时间戳
   * @returns 如 "刚刚"、"5分钟前"、"昨天"
   */
  static formatRelativeTime(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;

    if (diff < 60000) return '刚刚';
    if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`;
    if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`;
    if (diff < 172800000) return '昨天';
    if (diff < 604800000) return `${Math.floor(diff / 86400000)}天前`;

    const date = new Date(timestamp);
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  /**
   * 数字补零
   */
  private static padZero(num: number): string {
    return num < 10 ? `0${num}` : `${num}`;
  }
}
