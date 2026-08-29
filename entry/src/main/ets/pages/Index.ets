import { checkMaterailSupport, getGreetingInfo, SafeAreaInfo, theUimaterail } from '../models/model';
import { AppStorageV2, uiMaterial } from '@kit.ArkUI';
import { courses, loGinJson } from '../rcpModles/rcpUtil';
import preUtil from '../preferenceUtil/preUtil';
import { threeLego } from '../views/threeLego';
import { theBottomBar } from '../views/theBottomBar';
import { weekViews } from '../views/weekViews';
import { theMinClass } from '../views/theMInClass';
import { currentWeek } from '../rcpModles/schedule-utils';

const info = getGreetingInfo();

@Entry
@ComponentV2
struct Index {
  @Provider('safeArea') safeArea: SafeAreaInfo =
    AppStorageV2.connect(SafeAreaInfo, 'safeArea', () => new SafeAreaInfo())!
  @Provider("pathStack") pathStack: NavPathStack = new NavPathStack();
  @Provider('loginDataFromRcp') loginDataFromRcp: loGinJson | null = null;
  // @Provider("courseData") courseData: courses[] = [];
  @Provider("isOpenUimat") isOpenUimat: boolean = checkMaterailSupport() //识别设备是否支持沉浸光感
  @Local isShow: boolean = false;
  @Local theWith: string = "15%";
  @Local theHeight: string = "10%";
  @Local theRadius: number = 40;
  @Local clickStep: number = 0; // 点击步骤：0→1→2→0 循环
  @Provider('loginSate') loginSate: boolean = false;
  @Provider('weekNum') weekNum: number = 1 //当前周数
  @Provider('localData') localData: courses[] = [] //储存从实例中拿到的数据
  @Provider('weekDays') weekDays: courses[][] = []
  //创建材质配置实例
  private uiMaterialConfig: theUimaterail = new theUimaterail()

  async aboutToAppear(): Promise<void> {
    this.weekNum = currentWeek('2026-9-7')
    // 从偏好存储恢复登录状态和课表数据(杀后台重进不丢数据)
    const username = await preUtil.getCurrentUser(getContext(this))
    if (username) {
      await preUtil.loadCoursesData(getContext(this), username)
      const data = await preUtil.getData(username, username, '') as courses[]
      this.localData = Array.isArray(data) ? data : []
      await preUtil.loginState(getContext(this), username + "loginSate")
      const result = await preUtil.getData(username + "loginSate", username + "loginSate", false)
      this.loginSate = result === true
    }
  }

  build() {
    Navigation(this.pathStack) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column({ space: 5 }) {
          Text(info.greeting)
            .fontSize(35)
            .width("100%")
            .fontColor('#ffcfcdcd')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 10 })
          Text(` ${info.month} 月 ${info.day} 日 ${info.week}`).margin({ left: 10, bottom: 15 })
            .fontSize(15)
            .width("100%")
            .fontColor('#ffcfcdcd')
          //本周进度条
          weekViews()
          //本周课程、剩余周数等
          threeLego()
          //今日课程
          Column() {
            Text('今日课程')
              .fontColor('#ffcfcdcd')
              .fontWeight(FontWeight.Bold)
              .width("90%")
              .fontSize(20)
              .margin({ left: 8, top: 5, bottom: 5 })
            theMinClass()
          }
          .width("95%")
          .height(320)
          .borderRadius(20)
          .backgroundColor('#1d929191')
          .systemMaterial(this.isOpenUimat ? this.uiMaterialConfig : uiMaterial.ImmersiveMaterial.empty)

          // .onClick(() => {
          //   this.pathStack.pushPathByName("classPage", null)
          // })

          if (!this.loginSate) {
            Text('无课表数据，点击前往登陆！')
              .fontColor('#ffcfcdcd')
              .onClick(() => {
                this.pathStack.pushPathByName("LoginPage", null)
              })
          }

        }
        .width("92%")
        .height("100%")
        .justifyContent(FlexAlign.Start)
        .padding({
          top: this.getUIContext().px2vp(this.safeArea.topHeight),
        })

        // 自定义底部导航栏
        theBottomBar()
      }

      .width("100%")
      .height("100%")
      .backgroundImage($r("app.media.black"))
      .backgroundImageSize(ImageSize.Cover)

    }
    .width("100%")
    .height("100%")
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}
