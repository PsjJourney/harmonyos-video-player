import { photoAccessHelper } from '@kit.CoreFileKit';
import { VideoItem } from '../model/VideoItem';
import { VideoSource, SortType } from '../common/Enums';
import { Constants } from '../common/Constants';
import { FileUtils } from '../utils/FileUtils';

/**
 * 媒体扫描服务
 * 负责扫描设备中的视频文件
 */
export class MediaScanner {
  private static instance: MediaScanner | null = null;
  private cachedVideos: VideoItem[] = [];

  static getInstance(): MediaScanner {
    if (!this.instance) {
      this.instance = new MediaScanner();
    }
    return this.instance;
  }

  /**
   * 扫描设备所有视频
   * @param forceRefresh 是否强制刷新缓存
   * @returns 视频列表
   */
  async scanVideos(forceRefresh: boolean = false): Promise<VideoItem[]> {
    if (!forceRefresh && this.cachedVideos.length > 0) {
      return this.cachedVideos;
    }

    const videos: VideoItem[] = [];

    try {
      const context = getContext(this);
      const helper = photoAccessHelper.getPhotoAccessHelper(context);

      const fetchResult = await helper.getAssets({
        fileMediaType: photoAccessHelper.PhotoType.VIDEO,
        order: {
          type: photoAccessHelper.PhotoKeys.DATE_MODIFIED,
          orderType: photoAccessHelper.OrderByType.DESC
        }
      });

      const count = fetchResult.getCount();
      console.info(`Found ${count} videos`);

      for (let i = 0; i < count; i++) {
        try {
          const asset = await fetchResult.getObject(i);

          // 过滤不支持的格式
          if (!FileUtils.isSupportedVideo(asset.displayName)) {
            continue;
          }

          const videoItem: VideoItem = {
            id: asset.uri,
            title: FileUtils.getFileName(asset.displayName),
            duration: (asset.duration || 0) * 1000,
            path: asset.uri,
            size: asset.size || 0,
            dateModified: asset.dateModified * 1000,
            mimeType: asset.mimeType,
            width: asset.width,
            height: asset.height,
            source: VideoSource.LOCAL
          };
          videos.push(videoItem);
        } catch (err) {
          console.warn(`Failed to read video asset at index ${i}:`, err);
        }
      }

      fetchResult.close();
    } catch (error) {
      console.error('Scan videos failed:', error);
    }

    this.cachedVideos = videos;
    return videos;
  }

  /**
   * 搜索视频
   * @param keyword 关键词
   * @returns 匹配的视频列表
   */
  async searchVideos(keyword: string): Promise<VideoItem[]> {
    const videos = await this.scanVideos();
    const lowerKeyword = keyword.toLowerCase();
    return videos.filter(v => v.title.toLowerCase().includes(lowerKeyword));
  }

  /**
   * 排序视频列表
   * @param videos 视频列表
   * @param sortType 排序方式
   * @param ascending 是否升序
   * @returns 排序后的列表
   */
  sortVideos(videos: VideoItem[], sortType: SortType, ascending: boolean = false): VideoItem[] {
    const sorted = [...videos];
    const multiplier = ascending ? 1 : -1;

    switch (sortType) {
      case SortType.NAME:
        sorted.sort((a, b) => multiplier * a.title.localeCompare(b.title));
        break;
      case SortType.DATE_MODIFIED:
        sorted.sort((a, b) => multiplier * (a.dateModified - b.dateModified));
        break;
      case SortType.SIZE:
        sorted.sort((a, b) => multiplier * (a.size - b.size));
        break;
      case SortType.DURATION:
        sorted.sort((a, b) => multiplier * (a.duration - b.duration));
        break;
    }

    return sorted;
  }

  /**
   * 清除缓存
   */
  clearCache(): void {
    this.cachedVideos = [];
  }
}
