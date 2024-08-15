import {
  CityCodeInfoIntent,
  CityWeatherIntent,
  Failure,
  ObservedData,
  Success,
  WeatherViewModel,
  WeatherViewState
} from './viewmodel/WeatherViewModel';
import { CityCodeInfo, Forecast, Weather } from '../data/WeatherAPIModel';

export const ROUTE_NAME_MVI_V2 = "pages/mvi/v2/Index"


@Entry({ routeName: ROUTE_NAME_MVI_V2 })
@ComponentV2
struct Index {
  @Provider() weatherViewModel: WeatherViewModel = new WeatherViewModel()
  @Local cityCodeInfoViewState: ObservedData<WeatherViewState> =
    this.weatherViewModel.cityCodeInfoViewState
  @Local cityWeatherViewState: ObservedData<WeatherViewState> =
    this.weatherViewModel.cityWeatherViewState
  @Local private currentCityCode: string = ''

  aboutToAppear(): void {
    this.weatherViewModel.sendUIIntent(new CityCodeInfoIntent(getContext()))
  }

  aboutToDisappear(): void {
    this.weatherViewModel.onCleared()
  }

  @Monitor("cityCodeInfoViewState.value")
  onCityCodeInfo(monitor: IMonitor) {
    const value = this.cityCodeInfoViewState.value
    if (value instanceof Success) {
      const data = (value as Success).data as Array<CityCodeInfo>
      if (data.length > 0) {
        this.currentCityCode = data[0].city_code
        this.weatherViewModel.sendUIIntent(new CityWeatherIntent(data[0].city_code))
      }
    }
  }

  build() {
    Column() {
      this.titleBar()
      this.contentView()
    }
  }

  @Builder
  titleBar() {
    RelativeContainer() {
      Text('天气预报')
        .fontSize(18)
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Bold)
        .height('100%')
        .textAlign(TextAlign.Center)
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          right: { anchor: "__container__", align: HorizontalAlign.End },
        })
    }.width('100%').height(44)
  }

  @Builder
  contentView() {
    if (this.cityCodeInfoViewState.value instanceof Success) {
      SideBarContainer(SideBarContainerType.Embed) {
        this.cityCodeInfoView((this.cityCodeInfoViewState.value as Success).data as Array<CityCodeInfo>)
        if (this.cityWeatherViewState.value instanceof Success) {
          this.weatherDetailView((this.cityWeatherViewState.value as Success).data as Weather)
        } else if (this.cityWeatherViewState.value instanceof Failure) {
          this.errorView((this.cityWeatherViewState.value as Failure).message)
        } else {
          this.loadingView()
        }
      }
      .sideBarWidth(64)
      .minSideBarWidth(64)
      .showSideBar(true)
      .showControlButton(false)
    } else if (this.cityCodeInfoViewState.value instanceof Failure) {
      this.errorView((this.cityCodeInfoViewState.value as Failure).message)
    } else {
      this.loadingView()
    }
  }

  @Builder
  errorView(error: string) {
    Text(error)
      .fontSize(16)
      .fontColor(Color.Gray)
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
  }

  @Builder
  loadingView() {
    Text('加载中...')
      .fontSize(16)
      .fontColor(Color.Gray)
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
  }

  @Builder
  cityCodeInfoView(info: Array<CityCodeInfo>) {
    Column() {
      Text('城市')
        .height(60)
        .width("100%")
        .fontColor(Color.Blue)
        .fontWeight(FontWeight.Bold)
        .fontSize(16)
        .textAlign(TextAlign.Center)
      List() {
        ForEach(info,
          (item: CityCodeInfo, index: number) => {
            ListItem() {
              Text(item.city_name)
                .width("100%")
                .height(60)
                .fontSize(14)
                .fontColor(this.currentCityCode == item.city_code ? Color.Blue : Color.Orange)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .onClick(() => {
                  this.currentCityCode = item.city_code
                  this.weatherViewModel.sendUIIntent(new CityWeatherIntent(item.city_code))
                })
            }
          }, (item: CityCodeInfo) => item.city_code)
      }
      .listDirection(Axis.Vertical)
      .height('100%').width('100%')
      .divider({
        strokeWidth: 0.5,
        color: '#2F3134',
        startMargin: 4,
        endMargin: 4
      })
    }.height('100%')
  }

  @Builder
  weatherDetailView(weather: Weather) {
    Column() {
      Text(weather.cityInfo.city)
        .fontSize(24)

      Text(weather.data.wendu)
        .fontSize(32)
        .margin({ top: 12 })

      Text(weather.data.ganmao)
        .fontSize(16)
        .margin({ top: 12 })


      Text('未来几天天气情况').fontSize(16).margin({ top: 24 })

      List() {
        ForEach(weather.data.forecast, (item: Forecast, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Column() {
                  Text(item.week).fontSize(12).align(Alignment.Top)
                  Text(item.ymd).margin({ top: 12 }).fontSize(12).align(Alignment.Bottom)
                }.alignItems(HorizontalAlign.Start)

                Text(`${item.type}`).fontSize(11).margin({ left: 24 })

                Column() {
                  Text(`${item.low} ~ ${item.high}`)
                    .fontSize(11)
                    .textAlign(TextAlign.Center)
                  Text(item.notice).margin({ top: 12 }).fontSize(12).align(Alignment.Bottom)
                }.layoutWeight(1).alignItems(HorizontalAlign.End)
              }
            }.padding({ top: 12, bottom: 12 })
          }
        }, (item: Forecast) => item.date)
      }
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .width('100%')
      .divider({
        strokeWidth: 0.5,
        color: '#2F3134',
        startMargin: 4,
        endMargin: 4
      })
      .margin({ top: 6 })
    }.height('100%').layoutWeight(1).alignItems(HorizontalAlign.Center).padding({ left: 16, right: 16 })

  }
}