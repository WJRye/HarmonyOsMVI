import { router } from '@kit.ArkUI';
import { ROUTE_NAME_MVI } from './mvi/Index';

@Entry
@Component
struct Index {
  build() {
    RelativeContainer() {
      Text('天气预报')
        .id('mvi')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Brown)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          router.pushUrl({ url: ROUTE_NAME_MVI })
        })
    }
    .height('100%')
    .width('100%')
  }
}