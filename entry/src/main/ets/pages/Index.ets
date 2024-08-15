import { router } from '@kit.ArkUI';
import { ROUTE_NAME_MVI_V1 } from './mvi/v1/Index';
import { ROUTE_NAME_MVI_V2 } from './mvi/v2/Index';

@Entry
@Component
struct Index {
  build() {
    Column() {

      Column() {
        Text('天气预报V1')
          .id('mvi.v1')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Brown)
          .onClick(() => {
            router.pushUrl({ url: ROUTE_NAME_MVI_V1 })
          })
        Text('天气预报V2')
          .id('mvi.v2')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Orange)
          .onClick(() => {
            router.pushUrl({ url: ROUTE_NAME_MVI_V2 })
          })
          .margin({ top: 16 })
      }
    }
    .height('100%')
    .width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
  }
}