import { checkMaterailSupport, theUimaterail } from '../models/model';
import { uiMaterial } from '@kit.ArkUI';

function getTodayWeekNum(): number {
  let day = new Date().getDay();
  day = 0 ? 7 : day;
  return day
}

@Preview
@ComponentV2
export struct weekViews {
  @Consumer("pathStack") pathStack: NavPathStack = new NavPathStack();
  @Consumer("isOpenUimat") isOpenUimat: boolean = checkMaterailSupport() //识别设备是否支持沉浸光感
  @Local todayWeekNum: number = 0;
  private uiMaterialConfig: theUimaterail = new theUimaterail()

  aboutToAppear(): void {
    this.todayWeekNum = getTodayWeekNum();
  }

  build() {
    Row() {
      Column() {
        Text(`本周还剩：${((1 - this.todayWeekNum / 7) * 100).toFixed(0)} ％`)
          .fontSize(22)
          .margin({ top: 8 })
          .fontColor('#ffcfcdcd')
          .fontWeight(FontWeight.Regular)
        Text('- 昨 天 变 成 了 今 天 -')
          .fontColor('#ffcfcdcd')
          .fontWeight(FontWeight.Regular)
          .fontStyle(FontStyle.Italic)
          .margin({ top: 20 })
          .width(170)

        Text('——《 才二十三 》')
          .fontColor('#ffcfcdcd')
          .fontWeight(FontWeight.Regular)
          .fontStyle(FontStyle.Italic)
          .margin({ top: 20 })
          .width(150)
          .fontSize(10)
          .textAlign(TextAlign.End)
      }.height(140).justifyContent(FlexAlign.Start)

      Progress({ value: this.todayWeekNum, total: 7, type: ProgressType.Ring })
        .style({ strokeWidth: 10 })
        .width(100)
        .height(100)
        .backgroundColor(
          '#a82f2e2e')
    }
    .justifyContent(FlexAlign.SpaceAround)
    .backgroundImage($r("app.media.black"))
    .backgroundImageSize(ImageSize.Cover)
    .width("95%")
    .height(150)
    .borderRadius(20)
    .backgroundColor('#9c7c7c7c')
    .shadow({
      radius: 12, // 发光范围，越大越散
      color: '#8fd7e5f8', // 发光颜色
    })
    .systemMaterial(this.isOpenUimat ? this.uiMaterialConfig : uiMaterial.ImmersiveMaterial.empty)

  }
}