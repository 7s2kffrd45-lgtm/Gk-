import { checkMaterailSupport, theUimaterail } from '../models/model'
import { uiMaterial } from '@kit.ArkUI'

@ComponentV2
export struct threeLego {
  @Consumer("isOpenUimat") isOpenUimat: boolean = checkMaterailSupport() //识别设备是否支持沉浸光感
  private uiMaterialConfig: theUimaterail = new theUimaterail()

  build() {
    Row() {
      Column({ space: 4 }) {
        Image($r('app.media.xiguazhi')).width(25).height(25)
        Text("12").fontSize(15).fontColor('#ffcfcdcd').fontWeight(FontWeight.Bold)
        Text("本周课程").fontSize(9).fontColor('#ffcfcdcd')
      }
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#1d929191')
      .width("25%")
      .height(85)
      .shadow({
        radius: 12, // 发光范围，越大越散
        color: '#66d7e5f8', // 发光颜色
      })
      .systemMaterial(this.isOpenUimat ? this.uiMaterialConfig : uiMaterial.ImmersiveMaterial.empty)

      Column({ space: 4 }) {
        Image($r('app.media.xiguazhi')).width(25).height(25)
        Text("12").fontSize(15).fontColor('#ffcfcdcd').fontWeight(FontWeight.Bold)
        Text("本周课程").fontSize(9).fontColor('#ffcfcdcd')
      }
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#1d929191')
      .width("25%")
      .height(85)
      .shadow({
        radius: 12, // 发光范围，越大越散
        color: '#66d7e5f8', // 发光颜色
      })
      .systemMaterial(this.isOpenUimat ? this.uiMaterialConfig : uiMaterial.ImmersiveMaterial.empty)

      Column({ space: 4 }) {
        Image($r('app.media.xiguazhi')).width(25).height(25)
        Text("12").fontSize(15).fontColor('#ffcfcdcd').fontWeight(FontWeight.Bold)
        Text("本周课程").fontSize(9).fontColor('#ffcfcdcd')
      }
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#1d929191')
      .width("25%")
      .height(85)
      .shadow({
        radius: 12, // 发光范围，越大越散
        color: '#66d7e5f8', // 发光颜色
      })
      .systemMaterial(this.isOpenUimat ? this.uiMaterialConfig : uiMaterial.ImmersiveMaterial.empty)

    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width("95%")
    .height(100)
  }
}