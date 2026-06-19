import { router } from '@kit.ArkUI';
import { VideoPlayerView } from '../components/VideoPlayerView';

/**
 * 播放页面
 */
@Entry
@Component
struct PlayerPage {
  @State videoId: string = '';
  @State videoPath: string = '';
  @State videoTitle: string = '';
  @State seekTo: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string | number>;
    if (params) {
      this.videoId = (params['videoId'] as string) || '';
      this.videoPath = (params['videoPath'] as string) || '';
      this.videoTitle = (params['videoTitle'] as string) || '未知视频';
      this.seekTo = (params['seekTo'] as number) || 0;
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.ic_arrow_back'))
          .width(24)
          .height(24)
          .fillColor('#FFFFFF')
          .onClick(() => router.back())

        Text(this.videoTitle)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ left: 12 })
          .layoutWeight(1)
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#000000')

      // 视频播放区域
      VideoPlayerView({
        videoPath: this.videoPath,
        videoTitle: this.videoTitle,
        videoId: this.videoId,
        onBack: () => router.back()
      })
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}
