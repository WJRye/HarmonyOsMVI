import axios, { AxiosInstance } from '@ohos/axios'


const BASE_URL = "http://t.weather.sojson.com/"
const TIMEOUT = 10 * 1000

export class AxiosHelper {
  private static INSTANCE: AxiosHelper = new AxiosHelper()
  private axiosInstance: AxiosInstance

  constructor() {
    this.axiosInstance = axios.create({ baseURL: BASE_URL, timeout: TIMEOUT })
  }

  static getAxiosInstance(): AxiosInstance {
    return AxiosHelper.INSTANCE.axiosInstance
  }
}