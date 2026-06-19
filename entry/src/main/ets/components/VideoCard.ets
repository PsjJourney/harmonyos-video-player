import { VideoItem } from '../model/VideoItem';
import { TimeUtils } from '../utils/TimeUtils';
import { FileUtils } from '../utils/FileUtils';

/**
 * 视频卡片组件
 * 用于列表页展示视频信息
 */
@Component
export struct VideoCard {
  @ObjectLink video: VideoItemObserved;
  @Prop showDuration: boolean = true;
  @Prop showSize: boolean = true;
  @Prop showDate: boolean = false;

  onClicked: (video: VideoItem) => void = () => {};

  build() {
    Row({ space: 12 }) {
      // 缩略图
      Stack({ alignContent: Alignment.BottomEnd }) {
        // 使用默认背景色代替缩略图（实际项目中加载真实缩略图）
        Column() {
          Image($r('app.media.ic_video_placeholder'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
        }
        .width(200)
        .height(120)
        .borderRadius(8)
        .backgroundColor('#1A1A2E')

        // 时长标签
        if (this.showDuration && this.video.duration > 0) {
          Text(TimeUtils.formatTime(this.video.duration))
            .fontSize(11)
            .fontColor('#FFFFFF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .backgroundColor('rgba(0,0,0,0.7)')
            .margin({ right: 6, bottom: 6 })
        }
      }

      // 视频信息
      Column({ space: 6 }) {
        Text(this.video.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(22)

        if (this.showSize) {
          Text(FileUtils.formatSize(this.video.size))
            .fontSize(13)
            .fontColor('#999999')
        }

        if (this.showDate) {
          Text(TimeUtils.formatRelativeTime(this.video.dateModified))
            .fontSize(12)
            .fontColor('#BBBBBB')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .height(120)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.onClicked(this.video);
    })
  }
}

/**
 * 可观察的视频数据对象
 */
@Observed
export class VideoItemObserved implements VideoItem {
  id: string = '';
  title: string = '';
  duration: number = 0;
  path: string = '';
  size: number = 0;
  dateModified: number = 0;
  mimeType?: string;
  width?: number;
  height?: number;
  thumbnailPath?: string;
  source: VideoSource = VideoSource.LOCAL;
  isFavorite?: boolean;

  constructor(item?: VideoItem) {
    if (item) {
      Object.assign(this, item);
    }
  }
}

import { VideoSource } from '../common/Enums';
