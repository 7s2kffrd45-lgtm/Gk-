import { weekItem } from '../models/datahead';
import { currentWeek, weekHeader } from '../rcpModles/schedule-utils';
import { checkMaterailSupport, theUimaterail } from '../models/model';
import { uiMaterial } from '@kit.ArkUI';

@ComponentV2
export struct theHead {
  @Consumer('weekNum') weekNum: number = 1 //当前周数
  @Local weekItems: weekItem[] = [] //表头数据:周一~周日 + 日期 + 是否今天
  @Provider("isOpenUimat") isOpenUimat: boolean = checkMaterailSupport() //识别设备是否支持沉浸光感
  private uimaterial: theUimaterail = new theUimaterail();
  private termStart: string = '2026-8-31'; //开学第1周周一(按数据反推:第2周周一=9月7日)

  aboutToAppear(): void {
    this.weekNum = currentWeek(this.termStart);
    this.weekItems = weekHeader(this.weekNum, this.termStart);
  }

  changeWeek(delta: number): void {
    const next = this.weekNum + delta;
    if (next < 1 || next > 22) {
      return;
    }
    this.weekNum = next;
    this.weekItems = weekHeader(this.weekNum, this.termStart);
  }

  build() {
    Column({ space: 4 }) {
      Row({ space: 10 }) {
        Text('<')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.changeWeek(-1)
          })

        Text(`第${this.weekNum}周`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffcfcdcd')

        Text('>')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.changeWeek(1)
          })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')

      Row({ space: 5 }) {
        Text("")
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .margin({ right: 10, left: 10 })
          .width(30)
          .textAlign(TextAlign.Center)

        // 表头遍历 weekHeader 生成的 weekItem[](周一~周日+日期+是否今天)
        ForEach(this.weekItems, (item: weekItem, index: number) => {
          Column({ space: 2 }) {
            Text(item.weekday)
              .fontSize(12)
              .fontWeight(item.istoday ? FontWeight.Bold : FontWeight.Normal)
              .fontColor('#ffcfcdcd')
            Text(item.day)
              .fontSize(11)
              .fontColor(item.istoday ? '#FF6B6B' : '#666666')
          }
          .borderRadius(8)
          .backgroundColor(item.istoday ? '#FFE8E8' : Color.Transparent)
          .width(40)
          .height(42)
          .justifyContent(FlexAlign.Center)
        }, (item: weekItem, index: number) => index.toString())
      }
      .justifyContent(FlexAlign.Center)
      .width("98%")
    }
    .systemMaterial(this.isOpenUimat ? this.uimaterial.immersivemat : uiMaterial.ImmersiveMaterial.empty)
    .justifyContent(FlexAlign.Center)
    .width("98%")
    .margin({ left: 4 })
    .border({
      width: 1,
      color: 'rgba(176, 176, 176, 0.35)',
      radius: 12
    })
  }
}
