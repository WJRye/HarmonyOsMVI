/**
 * 天气信息
 */
export interface Weather {
  readonly message: string
  readonly status: number
  readonly date: string
  readonly time: string
  readonly cityInfo: CityInfo
  readonly data: Data
}

export interface CityInfo {
  readonly city: string
  readonly citykey: string
  readonly parent: string
  readonly updateTime: string
}

export interface Data {
  readonly shidu: string
  readonly pm25: number
  readonly pm10: number
  readonly quality: string
  readonly wendu: string
  readonly ganmao: string
  readonly forecast: Array<Forecast>
  readonly yesterday: Forecast
}

export interface Forecast {
  readonly date: string
  readonly high: string
  readonly low: string
  readonly ymd: string
  readonly week: string
  readonly sunrise: string
  readonly sunset: string
  readonly aqi: number
  readonly fx: string
  readonly fl: string
  readonly type: string
  readonly notice: string
}

/**
 * 城市码信息
 */
export interface CityCodeInfo {
  city_code: string
  city_name: string
}

/**
 * 限制 Model 层的数据结果类型
 */
export type WeatherData = Array<CityCodeInfo> | Weather