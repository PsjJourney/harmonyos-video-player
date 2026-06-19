import { PlayerError, formatErrorMessage } from '../common/PlayerError';

/**
 * 播放错误弹窗组件
 * 显示详细的错误信息、建议操作，支持重试
 */
@Component
export struct ErrorDialog {
  @Link visible: boolean;
  @Link error: PlayerError | null;

  onRetry: () => void = () => {};
  onDismiss: () => void = () => {};

  @State showDetail: boolean = false;

  build() {
    if (!this.visible || !this.error) {
      return;
    }

    Column() {
      // 半透明背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .position({ x: 0, y: 0 })

      // 弹窗内容
      Column({ space: 0 }) {
        // 头部图标 + 标题
        Column({ space: 12 }) {
          // 错误图标
          Stack() {
            Circle()
              .width(64)
              .height(64)
              .fillColor('#FFF3E0')
            Text('⚠')
              .fontSize(32)
          }

          // 标题
          Text(this.error?.title || '播放失败')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: 24, bottom: 16 })

        // 错误码标签
        Row() {
          Text(`错误码: ${this.error?.code || 0}`)
            .fontSize(11)
            .fontColor('#999999')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 16 })

        // 分割线
        Divider()
          .color('#F0F0F0')
          .height(1)

        // 错误消息
        Column({ space: 8 }) {
          Text(this.error?.message || '发生未知错误')
            .fontSize(15)
            .fontColor('#555555')
            .textAlign(TextAlign.Center)
            .padding({ top: 16 })

          // 💡 建议
          if (this.error?.suggestion) {
            Row({ space: 6 }) {
              Text('💡')
                .fontSize(14)
              Text(this.error?.suggestion || '')
                .fontSize(13)
                .fontColor('#888888')
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: 24, right: 24, top: 8 })
            .alignItems(VerticalAlign.Top)
          }

          // 技术详情（可展开）
          if (this.error?.detail) {
            Column() {
              Row() {
                Text(this.showDetail ? '收起详情 ▲' : '查看技术详情 ▼')
                  .fontSize(12)
                  .fontColor('#2196F3')
              }
              .width('100%')
              .onClick(() => {
                this.showDetail = !this.showDetail;
              })

              if (this.showDetail) {
                Text(this.error?.detail || '')
                  .fontSize(11)
                  .fontColor('#AAAAAA')
                  .fontFamily('monospace')
                  .padding(12)
                  .width('100%')
                  .backgroundColor('#FAFAFA')
                  .borderRadius(8)
                  .margin({ top: 8 })
                  .copyOption(CopyOptions.LocalDevice)
              }
            }
            .width('100%')
            .padding({ left: 24, right: 24, top: 12 })
          }
        }
        .padding({ bottom: 20 })

        // 分割线
        Divider()
          .color('#F0F0F0')
          .height(1)

        // 按钮栏
        Row({ space: 0 }) {
          // 关闭按钮
          Button('关闭')
            .fontSize(15)
            .fontColor('#999999')
            .backgroundColor('#FFFFFF')
            .layoutWeight(1)
            .height(48)
            .borderRadius(0)
            .onClick(() => {
              this.visible = false;
              this.showDetail = false;
              this.onDismiss();
            })

          // 分割线
          Divider()
            .vertical(true)
            .color('#F0F0F0')
            .height(32)

          // 重试按钮
          if (this.error?.retryable) {
            Button('重试')
              .fontSize(15)
              .fontColor('#FF4081')
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#FFFFFF')
              .layoutWeight(1)
              .height(48)
              .borderRadius(0)
              .onClick(() => {
                this.visible = false;
                this.showDetail = false;
                this.onRetry();
              })
          }
        }
        .width('100%')
        .height(48)
      }
      .width('85%')
      .maxWidth(400)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({
        radius: 20,
        color: 'rgba(0,0,0,0.15)',
        offsetX: 0,
        offsetY: 8
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

/**
 * 简易错误提示条（非阻断式，不影响播放区域）
 */
@Component
export struct ErrorToast {
  @Prop visible: boolean = false;
  @Prop message: string = '';
  @Prop retryable: boolean = false;

  onRetry: () => void = () => {};
  onDismiss: () => void = () => {};

  private timerId: number = -1;

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearTimeout(this.timerId);
    }
  }

  build() {
    if (!this.visible) return;

    Row({ space: 8 }) {
      Text('⚠')
        .fontSize(16)

      Text(this.message)
        .fontSize(13)
        .fontColor('#FFFFFF')
        .layoutWeight(1)
        .maxLines(2)

      if (this.retryable) {
        Text('重试')
          .fontSize(13)
          .fontColor('#FFD740')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
          .backgroundColor('rgba(255,255,255,0.15)')
          .onClick(() => {
            this.onRetry();
          })
      }

      Text('✕')
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.7)')
        .onClick(() => {
          this.onDismiss();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#D32F2F')
    .translate({ y: 0 })
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
  }
}
