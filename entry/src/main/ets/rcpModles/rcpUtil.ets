import { rcp } from '@kit.RemoteCommunicationKit';
import util from '@ohos.util';
import { JSON } from '@kit.ArkTS';

//后续改为服务器地址
//模拟器访问电脑本机服务用 10.0.2.2，真机用电脑局域网IP
const baseUrl = 'http://10.0.2.2:3000'
const loginUrl = '/api/login'
const scheduleUrl = '/api/schedule?';

export interface bodyOne {
  username: string,
  password: string,
}

//多次失败后需要验证码时使用
interface bodyTwo {
  studentId: string,
  password: string,
  ticket: string, //"上一步的ticket"
  captcha: string //"验证码"
}

//登录成功后返回的json
export class loGinJson {
  success: boolean = false
  token?: string = ''
  username?: string = ''
  message: string = '' //登录成功
  code?: string = ''
  ticket?: string = ''
  captchaImage?: string = ''
}

//课表数据结构
export interface courses {
  courseName: string
  weeks: string
  teacher: string
  periods: string
  classroom: string
  examMethod: string
  dayOfWeek: string,
  dayName: string,
  dates?: string[]
}

export async function loGin(studentId: string, password: string): Promise<loGinJson> {
  const body1: bodyOne = {
    username: studentId,
    password: password
  }
  let loginData: loGinJson = {
    success: false,
    message: '请求失败'
  };
  try {
    let textCoder = util.TextDecoder.create('utf-8');
    const session = rcp.createSession();
    let request = new rcp.Request(baseUrl + loginUrl, "POST");
    request.content = body1;
    let response = await session.fetch(request);
    console.log("hai 请求发送成功");
    session.close();
    let jsonStr = textCoder.decodeToString(new Uint8Array(response.body));
    loginData = JSON.parse(jsonStr) as loGinJson;
    console.log("hai loginData: " + JSON.stringify(loginData));
  } catch (e) {
    console.log('hai 请求失败' + e)
  }
  return loginData;
}

export async function getSchedule(token: string): Promise<courses[]> {
  let courseData: courses[] = []
  let textCoder = util.TextDecoder.create('utf-8');
  const query: string = `token=${encodeURIComponent(token)}&termStart=2026-08-31`;
  try {
    const session = rcp.createSession();
    let request = new rcp.Request(baseUrl + scheduleUrl + query, 'GET');
    let response = await session.fetch(request);
    session.close();
    let jsonStr = textCoder.decodeToString(new Uint8Array(response.body));
    console.log('hai 课表请求成功1: ' + jsonStr);
    let data = JSON.parse(jsonStr) as Record<string, object>;
    courseData = data['courses'] as courses[]
    console.log('hai 课表请求成功3: ' + JSON.stringify(courseData));

  } catch (e) {
    console.log('hai 课表请求失败' + e)
  }
  return courseData
}
