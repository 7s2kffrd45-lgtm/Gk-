/**
 * 课表网格主体:7 列(周一~周日),每列内按节次从上到下排列。
 * 用 Stack 布局:底层 12 个固定行(与 theLeft 完全一致),
 * 上层每个课程格子用 margin top 绝对定位到对应节次。
 */
import { weekDayCourses, periodStart, periodEnd } from '../rcpModles/schedule-utils';
import { courses } from '../rcpModles/rcpUtil';

interface CourseBlock {
  name: string
  room: string
  startPeriod: number  // 起始节(1-based)
  span: number         // 跨越几节
}

@ComponentV2
export struct theGrid {
  @Consumer('weekNum') weekNum: number = 1
  @Consumer('localData') localData: courses[] = []
  private cellHeight: number = 55
  private cellSpace: number = 4   // 与 theLeft 的 Column({ space: 4 }) 一致
  private maxPeriod: number = 12

  // 每节占用的垂直步长(55 + 4 = 59)
  private rowUnit: number = 59

  private getDayBlocks(day: number): CourseBlock[] {
    if (!this.localData || this.localData.length === 0) return []
    const dayCourses = weekDayCourses(this.localData, this.weekNum, day)
    const blocks: CourseBlock[] = []
    for (let i = 0; i < dayCourses.length; i++) {
      const c = dayCourses[i]
      const start = periodStart(c)
      const end = periodEnd(c)
      blocks.push({
        name: c.courseName,
        room: c.classroom,
        startPeriod: start,
        span: end - start + 1
      })
    }
    return blocks
  }

  // 课程格子高度: span * 55 + (span-1) * 4
  private blockHeight(span: number): number {
    return span * this.cellHeight + (span - 1) * this.cellSpace
  }

  build() {
    Row() {
      ForEach([1, 2, 3, 4, 5, 6, 7], (day: number) => {
        Stack({ alignContent: Alignment.TopStart }) {
          // 底层:12 个固定行,与 theLeft 的 Column({ space: 4 }) 完全一致
          Column({ space: this.cellSpace }) {
            ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], (p: number) => {
              Column()
                .width('100%')
                .height(this.cellHeight)
            }, (p: number) => `p${p}`)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          // 上层:每个课程格子用 margin top 定位到 (startPeriod-1) * 59
          ForEach(this.getDayBlocks(day), (block: CourseBlock, idx: number) => {
            Column() {
              Text(block.name)
                .fontSize(10)
                .fontColor('#333333')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(block.room)
                .fontSize(8)
                .fontColor('#999999')
                .margin({ top: 2 })
            }
            .width('90%')
            .height(this.blockHeight(block.span))
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#E8F0FE')
            .borderRadius(6)
            .margin({ top: (block.startPeriod - 1) * this.rowUnit })
          }, (block: CourseBlock, idx: number) => `${day}-${idx}-${block.name}`)
        }
        .layoutWeight(1)
        .height('100%')
      }, (day: number) => `day${day}`)
    }
    .width('100%')
    .height(this.maxPeriod * this.cellHeight + (this.maxPeriod - 1) * this.cellSpace)
  }
}
