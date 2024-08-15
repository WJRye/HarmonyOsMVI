import { WeatherData } from '../../data/WeatherAPIModel';
import { WeatherRepository } from '../../data/WeatherRepository';
import { Context } from '@kit.AbilityKit';
import { Subscription } from 'rxjs';

class ViewIntent {
}

/**
 * 城市码 Intent
 */
export class CityCodeInfoIntent extends ViewIntent {
  readonly context: Context

  constructor(context: Context) {
    super()
    this.context = context;
  }
}

/**
 * 城市天气 Intent
 */
export class CityWeatherIntent extends ViewIntent {
  readonly cityCode: string

  constructor(cityCode: string) {
    super()
    this.cityCode = cityCode
  }
}

@ObservedV2
export class ViewState<T> {
  readonly data: T | undefined

  constructor(data: T | undefined = undefined) {
    this.data = data
  }
}

@ObservedV2
export class Init extends ViewState<WeatherData> {
}

@ObservedV2
export class Loading extends ViewState<WeatherData> {
}

@ObservedV2
export class Success extends ViewState<WeatherData> {
  constructor(data: WeatherData) {
    super(data)
  }
}

@ObservedV2
export class Failure extends ViewState<WeatherData> {
  readonly code: number
  readonly message: string

  constructor(code: number, message: string) {
    super()
    this.code = code
    this.message = message
  }
}

/*限制 ViewState 类型*/
export type WeatherViewState = Success | Failure | Init | Loading

/*限制 Intent 类型*/
export type WeatherViewIntent = CityCodeInfoIntent | CityWeatherIntent


@ObservedV2
export abstract class ObservedData<T> {
  /*View 只有读取 ViewModel 返回的状态权限*/
  @Trace private _value: T

  protected constructor(value: T) {
    this._value = value;
  }

  /*提供给 View 可读状态*/
  get value(): T {
    return this._value
  }

  /*只能 ViewModel 内部更改状态*/
  protected updateValue(value: T) {
    this._value = value
  }
}

/**
 * 可观察的天气状态
 */
@ObservedV2
class WeatherObservedData extends ObservedData<WeatherViewState> {
  constructor(value: WeatherViewState) {
    super(value)
  }

  public updateValue(value: WeatherViewState): void {
    super.updateValue(value);
  }
}

export class WeatherViewModel {
  private readonly weatherRepository = WeatherRepository.newInstance()
  /*城市码状态，ViewModel 写状态*/
  private readonly _cityCodeInfoViewState: WeatherObservedData = new WeatherObservedData(new Init())
  /*城市码状态，View 读状态*/
  readonly cityCodeInfoViewState: ObservedData<WeatherViewState> = this._cityCodeInfoViewState
  /**/
  private cityCodeInfoSubscription: Subscription | undefined = undefined
  /*城市天气状态，ViewModel 写状态*/
  private readonly _cityWeatherViewState: WeatherObservedData = new WeatherObservedData(new Init())
  /*城市天气状态，View 读状态*/
  readonly cityWeatherViewState: ObservedData<WeatherViewState> = this._cityWeatherViewState
  /**/
  private cityWeatherSubscription: Subscription | undefined = undefined

  sendUIIntent(intent: WeatherViewIntent) {
    if (intent instanceof CityCodeInfoIntent) {
      this.handleCityCodeInfoIntent(intent)
    } else if (intent instanceof CityWeatherIntent) {
      this.handleCityWeatherIntent(intent)
    }
  }

  private handleCityCodeInfoIntent(intent: CityCodeInfoIntent) {
    this._cityCodeInfoViewState.updateValue(new Loading())
    this.cityCodeInfoSubscription = this.weatherRepository.loadCityCodeInfo(intent.context).subscribe({
      next: (value) => {
        this._cityCodeInfoViewState.updateValue(new Success(value))
      }, error: (msg: string) => {
        this._cityCodeInfoViewState.updateValue(new Failure(0, msg))
      }
    })
  }

  private handleCityWeatherIntent(intent: CityWeatherIntent) {
    this._cityWeatherViewState.updateValue(new Loading())
    this.cityWeatherSubscription = this.weatherRepository.fetchWeather(intent.cityCode).subscribe({
      next: (value) => {
        this._cityWeatherViewState.updateValue(new Success(value))
      }, error: (msg: string) => {
        this._cityWeatherViewState.updateValue(new Failure(0, msg))
      }
    })
  }

  onCleared() {
    this.cityCodeInfoSubscription?.unsubscribe()
    this.cityWeatherSubscription?.unsubscribe()
  }
}