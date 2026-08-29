import { theUimaterail } from '../models/model';

@Builder
function cPagebuilder() {
  cPage()
}

@Entry
@ComponentV2
export struct cPage {
  @Consumer("pathStack") pathStack: NavPathStack = new NavPathStack();
  @Consumer("isOpenUimat") isOpenUimat: boolean = false;
  @Local pixMap: string = '开发中.....(也可能不开发，嗯。';
  @Local isLoading: boolean = false;
  private uimaterial: theUimaterail = new theUimaterail();

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Text(this.isLoading ? "识别中..." : "选择文件")
            .fontColor(Color.Black)
            .width(248)
            .height(56)
            .borderRadius(28)


          TextArea({ text: this.pixMap })
            .width(250)
            .height(100)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .backgroundColor("#ffd3f0fd")
  }
}
