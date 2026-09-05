import { theHead } from '../views/theHead';
import { theLeft } from '../views/theLeft';
import { theGrid } from '../views/theGrid';
import { courses, loGinJson } from '../rcpModles/rcpUtil';
import preUtil from '../preferenceUtil/preUtil';
import { JSON } from '@kit.ArkTS';
import { SafeAreaInfo } from '../models/model';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
function classPageBuilder() {
  classPage()
}

@Preview
@ComponentV2
struct classPage {
  @Consumer('safeArea') safeArea: SafeAreaInfo =
    AppStorageV2.connect(SafeAreaInfo, 'safeArea', () => new SafeAreaInfo())!
  @Consumer("pathStack") pathStack: NavPathStack = new NavPathStack();
  @Consumer('loginDataFromRcp') loginDataFromRcp: loGinJson | null = null;
  @Consumer('loginSate') loginSate: boolean = false;
  @Consumer('weekNum') weekNum: number = 1 //当前周数
  @Consumer('weekDays') weekDays: courses[][] = [] //将数据以周为单位归类
  @Consumer('localData') localData: courses[] = [] //储存从实例中拿到的数据

  async aboutToAppear(): Promise<void> {
    // 仅首次登录后跳转时加载(此时 loginDataFromRcp 有值)
    // 重进 app 时 loginDataFromRcp 为 null,不覆盖 @Consumer 传来的数据
    const username = this.loginDataFromRcp?.username ?? ''
    if (username) {
      const data = await preUtil.getData(username, username, '') as courses[]
      this.localData = Array.isArray(data) ? data : []
      console.log('hai 一周为一个单位：' + JSON.stringify(this.localData))
      const result = await preUtil.getData(username + "loginSate", username + "loginSate", false)
      this.loginSate = result === true
      console.log('hai 读取到的登陆状态:', result, 'loginSate:', this.loginSate)
    }
  }

  build() {
    NavDestination() {
      Column({ space: 5 }) {
        theHead()

        Row() {
          theLeft()
          // 中间网格:与 theLeft 对齐,格子内容 = 该节次该星期有课的课

          if (!this.loginSate) {
            Column() {
              Text('还没登陆哦,')
                .fontColor('#ffcfcdcd')
                .fontSize(25)
              Text('点我去登陆')
                .fontColor('#ffcfcdcd')
                .fontColor(Color.Blue)
                .onClick(() => {
                  this.pathStack.replacePathByName('LoginPage', null)
                })
            }.position({ x: '50%', y: '50%' })
            .markAnchor({ x: '50%', y: '50%' })
          } else {
            theGrid()
          }

        }
        .margin({ left: 5 })
        .layoutWeight(1)
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }
      .height('100%')
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        top: this.getUIContext().px2vp(this.safeArea.topHeight),
      })
    }
    .hideBackButton(true)
    .backgroundImage($r('app.media.black'))
    .backgroundImageSize(ImageSize.Cover)
  }
}
