import { checkMaterailSupport, theUimaterail } from '../models/model';
import { PromptAction, uiMaterial } from '@kit.ArkUI';

@ComponentV2
export struct theBottomBar {
  @Consumer("pathStack") pathStack: NavPathStack = new NavPathStack();
  @Consumer("isOpenUimat") isOpenUimat: boolean = checkMaterailSupport() //识别设备是否支持沉浸光感
  promptAction: PromptAction = this.getUIContext().getPromptAction();
  private uiMaterialConfig: theUimaterail = new theUimaterail()

  build() {
    // 自定义底部导航栏
    Row() {
      Column({ space: 4 }) {
        // Image($r("app.media.")).width(24).height(24)
        Text("首页")
          .fontWeight(FontWeight.Bold)
          .fontSize(18)
          .fontColor('#ffcfcdcd')
          .border({ width: { bottom: 1 } })
          .borderColor('#ffcfcdcd')
          .padding({ bottom: 5 })
      }
      .margin({ left: 10 })
      .width(90)
      .height(47)
      .borderRadius(22)
      .backgroundColor(Color.Transparent)
      .systemMaterial(this.isOpenUimat ? this.uiMaterialConfig.immersivemat : uiMaterial.ImmersiveMaterial.empty)
      .justifyContent(FlexAlign.Center)

      // .onClick(() => this.pathStack.pushPathByName('Index', null))

      Column({ space: 4 }) {
        // Image($r("app.media.book")).width(24).height(24)
        Text("课程").fontWeight(FontWeight.Bold).fontSize(18).fontColor('#ffcfcdcd')
      }
      .width(90)
      .height(47)
      .borderRadius(22)
      .backgroundColor(Color.Transparent)
      .systemMaterial(this.isOpenUimat ? this.uiMaterialConfig.immersivemat : uiMaterial.ImmersiveMaterial.empty)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.pathStack.pushPathByName('classPage', null))

      Column({ space: 4 }) {
        // Image($r("app.media.studenid")).width(24).height(24)
        Text("我的").fontWeight(FontWeight.Bold).fontSize(18).fontColor('#ffcfcdcd')

      }
      .onClick(() => {
        this.pathStack.pushPathByName('homePage', null);
      })
      .margin({ right: 10 })
      .width(90)
      .height(47)
      .borderRadius(22)
      .backgroundColor(Color.Transparent)
      .systemMaterial(this.isOpenUimat ? this.uiMaterialConfig.immersivemat : uiMaterial.ImmersiveMaterial.empty)
      .justifyContent(FlexAlign.Center)
    }
    .margin({ bottom: 15 })
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(18)
    .width("90%")
    .height(66)
    .backgroundColor('#1dffffff')
    .systemMaterial(this.isOpenUimat ? this.uiMaterialConfig.immersivemat : uiMaterial.ImmersiveMaterial.empty)
  }
}