import { checkMaterailSupport, theUimaterail } from '../models/model'
import { uiMaterial } from '@kit.ArkUI'
import { courses } from '../rcpModles/rcpUtil'
import { todayDayOfWeek, weekDayCourses, weekSchedule } from '../rcpModles/schedule-utils'

@ComponentV2
export struct threeLego {
  @Consumer("isOpenUimat") isOpenUimat: boolean = checkMaterailSupport()
  @Consumer('localData') localData: courses[] = []
  @Consumer('weekNum') weekNum: number = 1
  private uiMaterialConfig: theUimaterail = new theUimaterail()
  private termStart: string = '2026-8-31'

  @Builder
  legoBlock(icon: ResourceStr, value: string, label: string) {
    Column({ space: 4 }) {
      Image(icon).width(25).height(25)
      Text(value).fontSize(15).fontColor('#ffcfcdcd').fontWeight(FontWeight.Bold)
      Text(label).fontSize(9).fontColor('#ffcfcdcd')
    }
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#1d929191')
    .width("28%")
    .height(85)
    .margin({ top: 5, bottom: 5 })
    .shadow({
      radius: 12,
      color: '#66d7e5f8',
    })
    .systemMaterial(this.isOpenUimat ? this.uiMaterialConfig.immersivemat : uiMaterial.ImmersiveMaterial.empty)
  }

  build() {
    Row({ space: 8 }) {
      this.legoBlock($r('app.media.book'), `${this.getWeekCourseCount()}`, '本周课程')
      this.legoBlock($r('app.media.kecheng'), `${this.getTodayCourseCount()}`, '今日课程')
      this.legoBlock($r('app.media.xiguazhi'), `${this.getRemainingCourseCount()}`, '本周剩余')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .padding({ left: 4, right: 4 })
  }

  // 本周课程数（去重统计）
  private getWeekCourseCount(): number {
    if (!this.localData || this.localData.length === 0) {
      return 0
    }
    const days = weekSchedule(this.localData, this.weekNum, this.termStart)
    const names = new Set<string>()
    for (const day of days) {
      for (const c of day) {
        names.add(c.courseName)
      }
    }
    return names.size
  }

  // 今日课程数
  private getTodayCourseCount(): number {
    if (!this.localData || this.localData.length === 0) {
      return 0
    }
    return weekDayCourses(this.localData, this.weekNum, todayDayOfWeek()).length
  }

  // 本周剩余课程数（明天到周日）
  private getRemainingCourseCount(): number {
    if (!this.localData || this.localData.length === 0) {
      return 0
    }
    const today = todayDayOfWeek()
    let count = 0
    for (let day = today + 1; day <= 7; day++) {
      count += weekDayCourses(this.localData, this.weekNum, day).length
    }
    return count
  }
}
