import { courses } from './rcpUtil';

/**
 * ArkTS 课表数据整理工具:把后端返回的扁平课程列表整理成 App 可用的结构。
 *
 * ⚠️ 后端 /api/schedule 返回的是**整个学期**的课,要显示单周课表必须先按周过滤
 * (weekSchedule),再排成网格(buildTimetable)。
 *
 * 网格结构(课表视图用):
 *   顶部 = 周一~周日(7 列)
 *   左侧 = 节次 1..maxPeriod(每行一个节次)
 *   格子 = 该(节次, 星期)上课的课程数组(可能多门课重叠,如 5-11节 与 9-11节)
 *   一门 "1-4节" 的课会占据第 1~4 行
 */

// ================= 课表网格 =================

export interface Timetable {
  maxPeriod: number; // 最大节次(行数),如 11
  cells: courses[][][]; // cells[节次-1][星期-1] = courses[](可能为空;0=周一 ... 6=周日)
}

/**
 * 把一周的课排成网格(输入应是"某一周"的课,即 weekSchedule 过滤后的结果)。
 * 每门课按其节次范围占据对应行;同一格多门课时数组里都有,渲染时堆叠显示。
 */
export function buildTimetable(courses: courses[]): Timetable {
  let maxPeriod = 0;
  for (const c of courses) {
    const end = periodEnd(c);
    if (end > maxPeriod) {
      maxPeriod = end;
    }
  }
  if (maxPeriod === 0) {
    maxPeriod = 12; // 没课也给出 12 行,保持网格完整
  }

  const cells: courses[][][] = [];
  for (let p = 1; p <= maxPeriod; p++) {
    const row: courses[][] = [];
    for (let d = 0; d < 7; d++) {
      row.push([]);
    }
    cells.push(row);
  }

  for (const c of courses) {
    const day = parseInt(c.dayOfWeek, 10);
    if (!(day >= 1 && day <= 7)) {
      continue;
    }
    const s = periodStart(c);
    const e = periodEnd(c);
    for (let p = s; p <= e; p++) {
      if (p >= 1 && p <= maxPeriod) {
        cells[p - 1][day - 1].push(c);
      }
    }
  }

  // 每格内按起始节排序(重叠课显示顺序稳定)
  for (const row of cells) {
    for (const cell of row) {
      cell.sort((a: courses, b: courses) => periodStart(a) - periodStart(b));
    }
  }
  return { maxPeriod: maxPeriod, cells: cells };
}

/** 一步到位:第 N 周 -> 网格 */
export function buildWeekTimetable(courses: courses[], week: number, termStart: string): Timetable {
  const days = weekSchedule(courses, week, termStart);
  const flat: courses[] = [];
  for (const day of days) {
    for (const c of day) {
      flat.push(c);
    }
  }
  return buildTimetable(flat);
}

// ================= 按周过滤(上一版已有,核心) =================

/** 解析周次字符串,如 "1-16" → [1..16],"1-8,10-16" → [1..8,10..16] */
function parseWeeks(s: string): number[] {
  if (!s) return [];
  const result: number[] = [];
  for (const part of s.split(',')) {
    const trimmed = part.trim().replace('周', '');
    const range = trimmed.split('-');
    if (range.length === 2) {
      const start = parseInt(range[0], 10);
      const end = parseInt(range[1], 10);
      if (!isNaN(start) && !isNaN(end)) {
        for (let i = start; i <= end; i++) {
          result.push(i);
        }
      }
    } else {
      const n = parseInt(trimmed, 10);
      if (!isNaN(n)) result.push(n);
    }
  }
  return result;
}

/** 根据 weeks + dayOfWeek + termStart 为每门课生成 dates 数组 */
export function fillDates(courses: courses[], termStart: string): void {
  const start = parseDate(termStart);
  for (const c of courses) {
    const dates: string[] = [];
    const day = parseInt(c.dayOfWeek, 10); // 1=周一 ... 7=周日
    for (const w of parseWeeks(c.weeks)) {
      const d = new Date(start);
      d.setDate(start.getDate() + (w - 1) * 7 + (day - 1));
      dates.push(formatDate(d));
    }
    c.dates = dates;
  }
}

/** 某一天有哪些课(任意日期,格式 YYYY-MM-DD) */
/** 第 N 周第 D 天的课（D: 1=周一 ... 7=周日），直接用 weeks + dayOfWeek 过滤 */
export function weekDayCourses(courses: courses[] | undefined, week: number, day: number): courses[] {
  if (courses === undefined || courses === null) return [];
  if (courses.length === 0) return [];
  const result: courses[] = [];
  for (let i = 0; i < courses.length; i++) {
    const c = courses[i];
    if (!c.weeks || !c.dayOfWeek) continue;
    if (!parseWeeks(c.weeks).includes(week)) continue;
    if (parseInt(c.dayOfWeek, 10) !== day) continue;
    result.push(c);
  }
  result.sort((a, b) => periodStart(a) - periodStart(b));
  return result;
}

export function coursesOnDate(courses: courses[], date: string): courses[] {
  const list: courses[] = [];
  for (const c of courses) {
    if (c.dates !== undefined && c.dates.indexOf(date) >= 0) {
      list.push(c);
    }
  }
  console.log('hailist ' + list)
  return list;
}

/** 第 N 周周一的日期(termStart = 开学第1周周一的日期) */
export function mondayOfWeek(week: number, termStart: string): string {
  const d = parseDate(termStart);
  d.setDate(d.getDate() + (week - 1) * 7);
  return formatDate(d);
}

/** 第 N 周完整课表:长度 7 的数组(0=周一 ... 6=周日),每组只含当周确实有课的课 */
export function weekSchedule(courses: courses[], week: number, termStart: string): courses[][] {
  const days: courses[][] = [[], [], [], [], [], [], []];
  const monday = parseDate(mondayOfWeek(week, termStart));
  for (let i = 0; i < 7; i++) {
    const d = new Date(monday);
    d.setDate(monday.getDate() + i);
    days[i] = coursesOnDate(courses, formatDate(d));
    days[i].sort((a: courses, b: courses) => periodStart(a) - periodStart(b));
  }
  return days;
}

/** 今天是第几周 */
export function currentWeek(termStart: string): number {
  const start = parseDate(termStart);
  const now = new Date();
  const diffDays = Math.floor((now.getTime() - start.getTime()) / 86400000);
  return Math.max(1, Math.floor(diffDays / 7) + 1);
}

// ================= 其它整理 =================

/** 按日期分组:Map<"2026-09-07", courses[]>(日历视图用) */
export function groupByDate(courses: courses[]): Map<string, courses[]> {
  const map = new Map<string, courses[]>();
  for (const c of courses) {
    if (c.dates === undefined) {
      continue;
    }
    for (const d of c.dates) {
      let list = map.get(d);
      if (list === undefined) {
        list = [];
        map.set(d, list);
      }
      list.push(c);
    }
  }
  return map;
}

/** 今天有哪些课 */
export function todayCourses(courses: courses[]): courses[] {
  return coursesOnDate(courses, todayStr());
}

/** 某门课在 fromDate(含)之后的下一次上课日期;没有则返回空串 */
export function nextClassDate(course: courses, fromDate: string): string {
  if (course.dates === undefined) {
    return '';
  }
  for (const d of course.dates) {
    if (d >= fromDate) {
      return d;
    }
  }
  return '';
}

// ================= 日期与节次工具 =================

export function todayStr(): string {
  return formatDate(new Date());
}

/** 今天星期几(1=周一 ... 7=周日) */
export function todayDayOfWeek(): number {
  const day = new Date().getDay(); // 0=周日 ... 6=周六
  return day === 0 ? 7 : day;
}

export function parseDate(s: string): Date {
  const parts = s.split('-');
  return new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10));
}

function formatDate(d: Date): string {
  const m = d.getMonth() + 1;
  const day = d.getDate();
  return `${d.getFullYear()}-${m < 10 ? '0' + m : m}-${day < 10 ? '0' + day : day}`;
}

/** 起始节,如 "5-11节" -> 5 */
export function periodStart(c: courses): number {
  const s = c.periods.split('-')[0].replace('节', '');
  const n = parseInt(s, 10);
  return Number.isNaN(n) ? 0 : n;
}

/** 结束节,如 "5-11节" -> 11;单独 "3节" -> 3 */
export function periodEnd(c: courses): number {
  const parts = c.periods.split('-');
  const e = (parts.length > 1 ? parts[1] : parts[0]).replace('节', '');
  const n = parseInt(e, 10);
  return Number.isNaN(n) ? periodStart(c) : n;
}

// ================= 表头数据(顶部"周几+日期") =================

export interface WeekItem {
  weekday: string; // "周一" ~ "周日"
  day: string; // 如 "9/14"
  istoday: boolean; // 是否是今天(高亮用)
}

/** 第 N 周的表头:周一~周日的星期名 + 日期 + 是否今天 */
export function weekHeader(week: number, termStart: string): WeekItem[] {
  const items: WeekItem[] = [];
  const monday = parseDate(mondayOfWeek(week, termStart));
  const today = todayStr();
  const names: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  for (let i = 0; i < 7; i++) {
    const d = new Date(monday);
    d.setDate(monday.getDate() + i);
    const ds = formatDate(d);
    const item: WeekItem = {
      weekday: names[i],
      day: `${d.getMonth() + 1}/${d.getDate()}`,
      istoday: ds === today,
    };
    items.push(item);
  }
  return items;
}

// ================= ArkUI 网格课表示例 =================
/*
import { courses, Timetable, buildWeekTimetable, currentWeek } from '../common/schedule-utils';
import { getSchedule } from './app-demo';

const DAYS: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

@Entry
@Component
struct TimetablePage {
  @State week: number = 1;
  @State tt: Timetable = { maxPeriod: 12, cells: [] };
  @State termStart: string = '2026-08-31'; // 开学第1周周一,从校历确认
  @State token: string = '';

  async aboutToAppear() {
    this.token = await login('你的学号', '你的密码');
    this.week = currentWeek(this.termStart);
    await this.loadWeek();
  }

  async loadWeek() {
    const courses: courses[] = await getSchedule(this.token, '1', this.termStart);
    this.tt = buildWeekTimetable(courses, this.week, this.termStart);
  }

  changeWeek(delta: number) {
    this.week += delta;
    if (this.week < 1) this.week = 1;
    this.loadWeek();
  }

  build() {
    Column() {
      // ---------- 顶部:周数 ----------
      Row() {
        Button('‹').onClick(() => this.changeWeek(-1))
        Text(`第 ${this.week} 周`).fontSize(18).fontWeight(FontWeight.Bold)
        Button('›').onClick(() => this.changeWeek(1))
      }.width('100%').justifyContent(FlexAlign.Center).padding(8)

      // ---------- 表头:节次占位 + 周一~周日 ----------
      Row() {
        Text('节次').width(44).fontSize(12).textAlign(TextAlign.Center)
        ForEach(DAYS, (name: string) => {
          Text(name).layoutWeight(1).fontSize(12).textAlign(TextAlign.Center)
        }, (name: string) => name)
      }.width('100%').padding({ top: 4, bottom: 4 }).backgroundColor('#EEEEEE')

      // ---------- 主体:每行一个节次 ----------
      Scroll() {
        Column() {
          ForEach(Array.from({ length: this.tt.maxPeriod }, (_, i) => i + 1), (p: number) => {
            Row() {
              // 左侧节次号
              Text(`${p}`).width(44).fontSize(12).textAlign(TextAlign.Center)

              // 右侧 7 个格子(该节次 × 周几)
              ForEach(this.tt.cells[p - 1], (cell: courses[], d: number) => {
                Column() {
                  ForEach(cell, (c: courses) => {
                    Text(`${c.courseName}\n${c.teacher}\n${c.classroom}`)
                      .fontSize(10)
                      .width('100%')
                      .textAlign(TextAlign.Center)
                  }, (c: courses) => c.courseName + c.periods + c.teacher)
                }
                .layoutWeight(1)
                .height(64)
                .border({ width: 0.5, color: '#DDDDDD' })
                .backgroundColor(cell.length > 0 ? '#E8F0FE' : '#FFFFFF')
              }, (cell: courses[], d: number) => 'cell' + p + '-' + d)
            }
            .width('100%')
          }, (p: number) => 'row' + p)
        }
      }.layoutWeight(1)
    }
  }
}
*/
