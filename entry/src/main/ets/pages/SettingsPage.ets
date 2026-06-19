import { router } from '@kit.ArkUI';
import { PlayHistoryService } from '../service/PlayHistoryService';
import { PlaybackSpeed, ScreenOrientation } from '../common/Enums';

/**
 * 设置页面
 */
@Entry
@Component
struct SettingsPage {
  @State defaultSpeed: PlaybackSpeed = PlaybackSpeed.SPEED_1_0;
  @State autoPlayNext: boolean = true;
  @State hwAcceleration: boolean = true;
  @State backgroundPlay: boolean = false;
  @State orientation: ScreenOrientation = ScreenOrientation.AUTO;
  @State showSubtitle: boolean = true;
  @State wifiOnly: boolean = true;
  @State historyCount: number = 0;

  private historyService: PlayHistoryService = PlayHistoryService.getInstance();

  async aboutToAppear(): Promise<void> {
    try {
      const history = await this.historyService.getHistory();
      this.historyCount = history.length;
    } catch (e) {
      console.error('Load settings failed:', e);
    }
  }

  /**
   * 清空播放历史
   */
  private async clearHistory(): Promise<void> {
    await this.historyService.clearHistory();
    this.historyCount = 0;
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.ic_arrow_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => router.back())

        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 12 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      List({ space: 0 }) {
        // 播放设置
        ListItem() {
          this.SectionHeader('播放设置')
        }

        ListItem() {
          this.SwitchItem('自动播放下一集', this.autoPlayNext, (val: boolean) => {
            this.autoPlayNext = val;
          })
        }

        ListItem() {
          this.SwitchItem('硬件加速', this.hwAcceleration, (val: boolean) => {
            this.hwAcceleration = val;
          })
        }

        ListItem() {
          this.SwitchItem('后台播放', this.backgroundPlay, (val: boolean) => {
            this.backgroundPlay = val;
          })
        }

        ListItem() {
          this.SelectItem('默认播放速度', this.getSpeedLabel(this.defaultSpeed), () => {
            this.cycleSpeed();
          })
        }

        // 显示设置
        ListItem() {
          this.SectionHeader('显示设置')
        }

        ListItem() {
          this.SelectItem('屏幕方向', this.getOrientationLabel(this.orientation), () => {
            this.cycleOrientation();
          })
        }

        ListItem() {
          this.SwitchItem('显示字幕', this.showSubtitle, (val: boolean) => {
            this.showSubtitle = val;
          })
        }

        // 网络设置
        ListItem() {
          this.SectionHeader('网络设置')
        }

        ListItem() {
          this.SwitchItem('仅在 WiFi 下播放在线视频', this.wifiOnly, (val: boolean) => {
            this.wifiOnly = val;
          })
        }

        // 数据管理
        ListItem() {
          this.SectionHeader('数据管理')
        }

        ListItem() {
          Row() {
            Text('播放历史')
              .fontSize(15)
              .fontColor('#333333')
              .layoutWeight(1)

            Text(`${this.historyCount} 条记录`)
              .fontSize(13)
              .fontColor('#999999')

            Text('清空')
              .fontSize(14)
              .fontColor('#FF4081')
              .margin({ left: 12 })
              .onClick(() => this.clearHistory())
          }
          .width('100%')
          .height(52)
          .padding({ left: 24, right: 16 })
          .backgroundColor('#FFFFFF')
        }

        // 关于
        ListItem() {
          this.SectionHeader('关于')
        }

        ListItem() {
          Row() {
            Text('版本')
              .fontSize(15)
              .fontColor('#333333')
              .layoutWeight(1)

            Text('v1.0.0')
              .fontSize(13)
              .fontColor('#999999')
          }
          .width('100%')
          .height(52)
          .padding({ left: 24, right: 16 })
          .backgroundColor('#FFFFFF')
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .divider({ color: '#F0F0F0', height: 0.5 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // ========== Builder 组件 ==========

  @Builder
  SectionHeader(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor('#999999')
      .padding({ left: 24, top: 20, bottom: 8 })
      .width('100%')
      .backgroundColor('#F5F5F5')
  }

  @Builder
  SwitchItem(title: string, value: boolean, onChange: (val: boolean) => void) {
    Row() {
      Text(title)
        .fontSize(15)
        .fontColor('#333333')
        .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: value })
        .onChange((isOn: boolean) => onChange(isOn))
    }
    .width('100%')
    .height(52)
    .padding({ left: 24, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  SelectItem(title: string, value: string, onClick: () => void) {
    Row() {
      Text(title)
        .fontSize(15)
        .fontColor('#333333')
        .layoutWeight(1)

      Text(value)
        .fontSize(13)
        .fontColor('#999999')

      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC')
        .margin({ left: 4 })
    }
    .width('100%')
    .height(52)
    .padding({ left: 24, right: 16 })
    .backgroundColor('#FFFFFF')
    .onClick(() => onClick())
  }

  // ========== 辅助方法 ==========

  private getSpeedLabel(speed: PlaybackSpeed): string {
    const labels: Record<number, string> = {
      0.5: '0.5x',
      0.75: '0.75x',
      1.0: '1.0x（正常）',
      1.25: '1.25x',
      1.5: '1.5x',
      2.0: '2.0x'
    };
    return labels[speed as number] || '1.0x';
  }

  private cycleSpeed(): void {
    const speeds = [
      PlaybackSpeed.SPEED_0_5,
      PlaybackSpeed.SPEED_0_75,
      PlaybackSpeed.SPEED_1_0,
      PlaybackSpeed.SPEED_1_25,
      PlaybackSpeed.SPEED_1_5,
      PlaybackSpeed.SPEED_2_0
    ];
    const idx = speeds.indexOf(this.defaultSpeed);
    this.defaultSpeed = speeds[(idx + 1) % speeds.length];
  }

  private getOrientationLabel(orientation: ScreenOrientation): string {
    const labels: Record<string, string> = {
      'auto': '自动',
      'landscape': '横屏',
      'portrait': '竖屏'
    };
    return labels[orientation] || '自动';
  }

  private cycleOrientation(): void {
    const orientations = [ScreenOrientation.AUTO, ScreenOrientation.LANDSCAPE, ScreenOrientation.PORTRAIT];
    const idx = orientations.indexOf(this.orientation);
    this.orientation = orientations[(idx + 1) % orientations.length];
  }
}
