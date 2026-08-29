export interface weekItem {
  weekday: string,
  day: string,
  istoday: boolean
}

@ObservedV2
export class classNumitem {
  num: string;
  time: string;
  @Trace isClick: boolean = false;

  constructor(num: string, time: string) {
    this.num = num;
    this.time = time;
  }
}

export function getclassNumitem(): classNumitem[] {
  return [
    new classNumitem("一", "8:10-8:55"),
    new classNumitem("二", "9:05-9:50"),
    new classNumitem("三", "10:05-10:50"),
    new classNumitem("四", "11:00-11:45"),
    new classNumitem("五", "14:10-14:55"),
    new classNumitem("六", "15:05-15:50"),
    new classNumitem("七", "16:10-16:55"),
    new classNumitem("八", "17:05-17:50"),
    new classNumitem("九", "19:10-19:55"),
    new classNumitem("十", "20:05-20:50"),
    new classNumitem("十一", "21:00-21:45"),
    new classNumitem("十二", "21:50-22:35"),
  ];
}
