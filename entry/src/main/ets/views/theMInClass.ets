import { courses } from '../rcpModles/rcpUtil';
import { weekDayCourses, currentWeek, todayDayOfWeek } from '../rcpModles/schedule-utils';

@Preview
@ComponentV2
export struct theMinClass {
  @Consumer('localData') localData: courses[] = [];

  private getList(): courses[] {
    if (!this.localData || this.localData.length === 0) return [];
    return weekDayCourses(this.localData, currentWeek('2026-08-31'), todayDayOfWeek());
  }

  build() {
    Column() {
      if (this.getList().length > 0) {
        List({ space: 8 }) {
          ForEach(this.getList(), (item: courses, index: number) => {
            ListItem() {
              this.theRow(item.courseName, item.classroom, index + 1)
            }.margin({ left: 25 })
          })
        }
      } else {
        Text('今天没有课，摸了！')
          .fontSize(18).fontColor('#ffcfcdcd')
      }
    }
  }

  @Builder
  theRow(name: string, classroom: string, num: number) {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.jieci'))
          .width(35).height(45).margin({ left: 10 })
        Text(num.toString()).fontSize(18).margin({ left: 10, bottom: 5 })
      }
      .width(45).height(45)

      Column() {
        Text(name).fontSize(15).width("40%").fontColor('#ffcfcdcd')
        Text(classroom).fontSize(12).fontColor('#ffcfcdcd')
      }
    }
    .backgroundColor('#75cfcdcd')
    .height(50)
    .justifyContent(FlexAlign.Start)
    .width("90%")
    .borderRadius(18)
  }
}
