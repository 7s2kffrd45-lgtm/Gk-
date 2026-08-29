import { classNumitem, getclassNumitem } from '../models/datahead';
import { theUimaterail } from '../models/model';
import { uiMaterial } from '@kit.ArkUI';

@ComponentV2
export struct theLeft {
  @Consumer("isOpenUimat") isOpenUimat: boolean = false;
  @Local classItem: classNumitem[] = getclassNumitem();
  private uimaterial: theUimaterail = new theUimaterail();
  private cellHeight: number = 55;

  build() {
    Column({ space: 4 }) {
      ForEach(this.classItem, (item: classNumitem) => {
        Column({ space: 4 }) {
          Text(item.isClick ? item.time : item.num)
            .fontColor('#ffcfcdcd')
            .fontSize(item.isClick ? 9 : 12)
            .fontWeight(FontWeight.Bold)
            .scale(item.isClick ? { x: 0.9, y: 0.9 } : { x: 0.7, y: 0.7 })
            .animation({ duration: 600, curve: Curve.Ease })
        }
        .systemMaterial(this.isOpenUimat ? this.uimaterial.immersivemat : uiMaterial.ImmersiveMaterial.empty)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .borderRadius(8)
        .height(this.cellHeight)
        .width(item.isClick ? 60 : 40)
        .onClick(() => {
          item.isClick = !item.isClick;
        })
        .animation({
          duration: 700,
          curve: Curve.Ease
        })
      })
    }
    .borderRadius(8)
    .width(60)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .height("100%")
  }
}
