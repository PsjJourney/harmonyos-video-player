import { Constants } from '../common/Constants';

/**
 * 文件工具类
 */
export class FileUtils {
  /**
   * 格式化文件大小
   * @param bytes 字节数
   * @returns 如 "1.5 GB"、"230 MB"
   */
  static formatSize(bytes: number): string {
    if (bytes === 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    const k = 1024;
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    const size = bytes / Math.pow(k, i);

    return `${size.toFixed(i > 0 ? 1 : 0)} ${units[i]}`;
  }

  /**
   * 获取文件扩展名
   * @param filePath 文件路径
   * @returns 扩展名（小写，含点号）
   */
  static getExtension(filePath: string): string {
    const lastDot = filePath.lastIndexOf('.');
    if (lastDot === -1) return '';
    return filePath.substring(lastDot).toLowerCase();
  }

  /**
   * 获取文件名（不含路径和扩展名）
   * @param filePath 文件路径
   * @returns 文件名
   */
  static getFileName(filePath: string): string {
    const lastSlash = Math.max(filePath.lastIndexOf('/'), filePath.lastIndexOf('\\'));
    const name = lastSlash === -1 ? filePath : filePath.substring(lastSlash + 1);
    const lastDot = name.lastIndexOf('.');
    return lastDot === -1 ? name : name.substring(0, lastDot);
  }

  /**
   * 判断是否为支持的视频格式
   * @param filePath 文件路径
   * @returns 是否支持
   */
  static isSupportedVideo(filePath: string): boolean {
    const ext = this.getExtension(filePath);
    return Constants.SUPPORTED_FORMATS.includes(ext);
  }

  /**
   * 计算播放进度百分比
   * @param currentTime 当前时间（毫秒）
   * @param duration 总时长（毫秒）
   * @returns 百分比 0-100
   */
  static getProgress(currentTime: number, duration: number): number {
    if (duration <= 0) return 0;
    return Math.min(100, Math.max(0, (currentTime / duration) * 100));
  }
}
