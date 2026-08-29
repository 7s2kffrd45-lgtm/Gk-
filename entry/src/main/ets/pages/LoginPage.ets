import { theUimaterail } from '../models/model';
import { courses, getSchedule, loGin, loGinJson } from '../rcpModles/rcpUtil';
import { fillDates } from '../rcpModles/schedule-utils';
import { PromptAction } from '@kit.ArkUI';
import common from '@ohos.app.ability.common';
import preUtil from '../preferenceUtil/preUtil';


@Builder
function LoginPagebuilder() {
  LoginPage()
}

@Preview
@ComponentV2
export struct LoginPage {
  @Local studentId: string = '';
  @Local password: string = '';
  @Local isLogging: boolean = false;
  @Local lastTime: number = 0; //用于记录上次点击登陆时间
  @Local context: Context = getContext(this) as common.UIAbilityContext;
  @Consumer("pathStack") pathStack: NavPathStack = new NavPathStack();
  @Consumer("courseData") courseData: courses[] = [];
  @Consumer('loginDataFromRcp') loginDataFromRcp: loGinJson | null = null;
  promptAction: PromptAction = this.getUIContext().getPromptAction();
  private uimaterial: theUimaterail = new theUimaterail();

  build() {
    NavDestination() {
      Column() {
        Column() {
          Image($r('app.media.appicon'))
            .width(90)
            .height(90)
            .borderRadius(18)
          Text("GK课表").fontSize(35).fontColor('#ffcfcdcd')
        }.height(150).justifyContent(FlexAlign.SpaceBetween)

        Column() {
          Row({ space: 10 }) {
            Image($r("app.media.studenid"))
              .width(13)
              .height(13)
            Text('学号').width('70%')
              .fontColor('#ffcfcdcd')
              .fontSize(12)
          }.margin({ left: 10 }).height(15)

          TextInput({ placeholder: "学号" })
            .width("75%")
            .height(65)
            .borderRadius(18)
            .backgroundColor('#ffb7b7b7')
            .margin({ top: 10, bottom: 15 })
            .onChange((val) => {
              this.studentId = val;
            })

          Row({ space: 10 }) {
            Image($r("app.media.pass"))
              .width(13)
              .height(16)
            Text('密码').width('70%')
              .fontColor('#ffcfcdcd')
              .fontSize(12)
          }.margin({ left: 10 })


          TextInput({ placeholder: "密码" })
            .margin({ top: 10, bottom: 20 })
            .width("75%")
            .height(65)
            .borderRadius(18)
            .backgroundColor('#ffb7b7b7')

            // .systemMaterial(this.uimaterial)
            .onChange((val) => {
              this.password = val;
            })
          Button(this.isLogging ? '登录中...' : '登陆')
            .margin({ top: 10, bottom: 20 })
            .width("75%")
            .height(65)
            .fontColor(Color.Black)
            .borderRadius(18)
            .backgroundColor("#ff4f9cbf")
            // .systemMaterial(this.uimaterial)
            .enabled(!this.isLogging)
            .onClick(async () => {
              //计时器 限制五秒内只能点击一次
              const now = Date.now();
              if (now - this.lastTime < 5000) {
                this.promptAction.showToast(
                  { message: '五秒内只能点击一次登陆', duration: 900, systemMaterial: this.uimaterial })
                return
              }
              this.lastTime = now;

              // 校验学号
              if (this.studentId.length <= 7) {
                this.promptAction.showToast(
                  { message: '学号长度必须大于7位', duration: 900, systemMaterial: this.uimaterial })
                return
              }
              // 校验密码
              if (this.password.length <= 6) {
                this.promptAction.showToast(
                  { message: '密码长度必须大于6位', duration: 900, systemMaterial: this.uimaterial })
                return
              }
              // 防止重复提交
              this.isLogging = true
              try {
                this.loginDataFromRcp = await loGin(this.studentId, this.password)
                this.promptAction.showToast({
                  message: this.loginDataFromRcp.success ? '登录成功' : this.loginDataFromRcp.message,
                  duration: 1200,
                  systemMaterial: this.uimaterial
                })

                if (this.loginDataFromRcp.success && this.loginDataFromRcp.username) {
                  preUtil.loadCoursesData(this.context, this.loginDataFromRcp.username) //创建一个名为用户学号的实例来存储课表数据
                  preUtil.loginState(this.context, this.loginDataFromRcp.username + "loginSate") //创建一个名为用户登陆的实例来存登陆状态
                  preUtil.saveCurrentUser(this.context, this.loginDataFromRcp.username) //保存当前用户名,app重启后可读取
                  this.courseData = await getSchedule(this.loginDataFromRcp.token as string);
                  fillDates(this.courseData, '2026-08-31');
                  //写入课表数据
                  preUtil.writeInputCourseData(this.loginDataFromRcp.username, this.loginDataFromRcp.username,
                    this.courseData);
                  //写入登陆状态
                  preUtil.flushLoginState(this.loginDataFromRcp.username + "loginSate",
                    this.loginDataFromRcp.username + "loginSate", true)
                  this.pathStack.replacePathByName('classPage', null);
                }
              } finally {
                this.isLogging = false
              }
            })
          Text() {
            Span('该APP').fontColor('#ffcfcdcd')
            Span('不会').fontColor(Color.Red)
            Span('对账号 密码进行储存').fontColor('#ffcfcdcd')
            Span('请放心登陆').fontColor('#ffcfcdcd')
          }
          .fontSize(15)

        }
        .width("88%")
        .borderRadius(18)
        .height(360)
        .shadow({
          radius: 12, // 发光范围，越大越散
          color: '#60d7e5f8', // 发光颜色
        })
        .backgroundImage($r("app.media.black"))
        .justifyContent(FlexAlign.Center)
        .backgroundImageSize(ImageSize.Cover)
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .backgroundImage($r("app.media.black"))
      .backgroundImageSize(ImageSize.Cover)
      .width("100%")
      .height("100%")

    }
    .backgroundImage($r("app.media.black"))
    .backgroundImageSize(ImageSize.Cover)
  }
}