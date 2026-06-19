/**
 * 视频数据模型
 */
export interface VideoItem {
  id: string;              // 唯一标识
  title: string;           // 视频标题
  duration: number;        // 时长（毫秒）
  path: string;            // 文件路径或URL
  size: number;            // 文件大小（字节）
  dateModified: number;    // 修改时间（时间戳）
  mimeType?: string;       // MIME类型
  width?: number;          // 视频宽度
  height?: number;         // 视频高度
  thumbnailPath?: string;  // 缩略图路径
  source: VideoSource;     // 来源：本地/网络
  isFavorite?: boolean;    // 是否收藏
}

import { VideoSource } from '../common/Enums';

/**
 * 播放记录模型
 */
export interface PlayRecord {
  videoId: string;         // 视频ID
  title: string;           // 视频标题
  path: string;            // 文件路径
  lastPosition: number;    // 上次播放位置（毫秒）
  duration: number;        // 视频总时长（毫秒）
  timestamp: number;       // 记录时间
  thumbnailPath?: string;  // 缩略图路径
}

/**
 * 播放列表模型
 */
export interface Playlist {
  id: string;              // 列表ID
  name: string;            // 列表名称
  videos: VideoItem[];     // 视频列表
  createdAt: number;       // 创建时间
  updatedAt: number;       // 更新时间
}
