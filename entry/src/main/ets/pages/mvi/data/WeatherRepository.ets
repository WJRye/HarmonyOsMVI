import { AxiosResponse } from '@ohos/axios'
import { AxiosHelper } from './AxiosHelper'
import { CityCodeInfo, Weather } from './WeatherAPIModel'
import { delay, Observable } from 'rxjs'
import { util } from '@kit.ArkTS'

export class WeatherRepository {
  /**
   * 缓存天气
   */
  private cachedWeather: Map<string, Weather> = new Map()

  private constructor() {
  }

  static newInstance(): WeatherRepository {
    return new WeatherRepository()
  }

  /**
   * 根据城市码请求城市天气
   * @param code 城市码
   * @returns 城市天气
   */
  fetchWeather(code: string): Observable<Weather> {
    return new Observable<Weather>((subscribe) => {
      if (this.cachedWeather.has(code)) {
        subscribe.next(this.cachedWeather.get(code))
        subscribe.complete()
        return
      }
      AxiosHelper.getAxiosInstance().get(`api/weather/city/${code}`).then((resp: AxiosResponse<Weather>) => {
        if (resp.status === 200) {
          subscribe.next(resp.data)
          this.cachedWeather.set(code, resp.data)
          subscribe.complete()
        } else {
          subscribe.error(resp.statusText)
        }
      }).catch((e: Error) => {
        subscribe.error(e.message)
      })
    }).pipe(delay(16))//Observed的数据更新过快，会导致观察不到。具体原因还没有来得及查找。所以这里delay 16毫秒
  }

  /**
   * 加载 raw 文件中城市码
   */
  loadCityCodeInfo(context: Context): Observable<Array<CityCodeInfo>> {
    return new Observable<Array<CityCodeInfo>>((subscribe) => {
      context.resourceManager.getRawFileContent('city_code.json').then((rawFile) => {
        const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true })
        const rawFileString = textDecoder.decodeWithStream(rawFile, { stream: false })
        const data: Array<CityCodeInfo> = JSON.parse(rawFileString)
        subscribe.next(data.filter((value) => value.city_code.length > 0))
        subscribe.complete()
      }).catch((e: Error) => {
        subscribe.error(e.message)
      })
    })
  }
}