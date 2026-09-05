import { SafeAreaInfo } from '../models/model';
import { AppStorageV2 } from '@kit.ArkUI';
import { loGinJson } from '../rcpModles/rcpUtil';

@Builder
function homePageBuilder() {
  home()
}

@Preview
@ComponentV2
export struct home {
  @Consumer("pathStack") pathStack: NavPathStack = new NavPathStack();
  @Consumer('safeArea') safeArea: SafeAreaInfo =
    AppStorageV2.connect(SafeAreaInfo, 'safeArea', () => new SafeAreaInfo())!
  @Consumer('loginDataFromRcp') loginDataFromRcp: loGinJson | null = null;
  @Consumer('userName') userName: string = '';

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r("app.media.usericon")).width(55).height(55)
            .margin({ left: 10, right: 10 })
          Column() {
            Text('0122041282').fontColor('#ffcb4040').fontSize(15)
          }
        }
        .borderRadius(33)
        .borderColor('#ffcfcdcd')
        .justifyContent(FlexAlign.Start)
        .width("85%")
        .height(105)
        .backgroundImage($r("app.media.black"))
        .backgroundImageSize(ImageSize.Cover)
        .shadow({
          radius: 12, // 发光范围，越大越散
          color: '#8fd7e5f8', // 发光颜色
        })

        Text('该页面完善中').fontColor('#ffcb4040').fontSize(35)
        Row() {
          Text('退出登录').fontColor('#ffcb4040').fontSize(15)
        }
        .border({ width: 1 })
        .borderRadius(18)
        .borderColor('#ffcb4040')
        .justifyContent(FlexAlign.Center)
        .width("85%")
        .height(75)
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .backgroundImage($r("app.media.black"))
      .backgroundImageSize(ImageSize.Cover)
      .width("100%")
      .height("100%")
      .padding({
        top: this.getUIContext().px2vp(this.safeArea.topHeight),
      })
    }
    .hideBackButton(true)
    .backgroundImage($r("app.media.black"))
    .backgroundImageSize(ImageSize.Cover)
  }
}