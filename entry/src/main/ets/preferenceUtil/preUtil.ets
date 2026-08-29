import preferences from '@ohos.data.preferences';
import { ValueType } from '@kit.ArkData';
import { courses } from '../rcpModles/rcpUtil';

export class preUtil {
  premap: Map<string, preferences.Preferences> = new Map();

  //用于创建存储登陆状态实例
  async loginState(context: Context, name: string) {
    if (this.premap.has(name)) {
      console.log('hai 已有该状态存储实例！')
      return
    }
    try {
      let pre = await preferences.getPreferences(context, name); //创建实例
      this.premap.set(name, pre) //将创建的实例封装进premap
      console.log('hai 存储登陆状态实例实例创建成功')
    } catch (e) {
      console.log('hai 存储登陆状态实例实例创建失败' + e)
    }
  }

  //创建存储课表数据实例
  async loadCoursesData(context: Context, name: string) {
    //考虑到课表数据会更新，所以不进行实例重名判断，如果重名直接覆盖
    try {
      let pre = await preferences.getPreferences(context, name); //创建实例
      this.premap.set(name, pre) //将创建的实例封装进premap
      console.log('hai 存储课表数据实例实例创建成功')
    } catch (e) {
      console.log('hai 存储课表数据实例实例创建失败' + e)
    }
  }

  async writeInputCourseData(name: string, key: string, value: courses[]) {
    try {
      let pre = this.premap.get(name);
      await pre?.put(key, value);
      await pre?.flush();
      console.log("hai", `${name}实例成功写入数据！`)
    } catch (e) {
      console.log("hai", `${name}实例写入数据失败！`)
    }
  }

  //用于写入登陆状态
  async flushLoginState(name: string, key: string, value: boolean) {
    if (!this.premap.has(name)) {
      console.log('hai flushLoginState存储实例不存在！')
      return
    }
    try {
      let pre = this.premap.get(name);
      await pre?.put(key, value);
      await pre?.flush();
      console.log("hai", `${name}flushLoginState实例成功写入数据！`)
    } catch (e) {
      console.log("hai", `${name}flushLoginState实例写入数据失败！`)
    }
  }

  async getData(name: string, key: string, deflvalue: ValueType) {
    //name：实例名称
    //key:键值
    //deflvale：默认的value值
    if (!this.premap.has(name)) {
      console.log("hai", `${name}实例不存在！`)
      return;
    }
    try {
      let pre = this.premap.get(name);
      let v = await pre?.get(key, deflvalue);
      console.log("hai", `${name}实例读取数据成功！`)
      return v;
    } catch (e) {
      console.log("hai", `${name}实例读取数据失败！`)
      return deflvalue;
    }
  }

  // 存当前用户名(固定实例名 'appState',app 重启后可读取)
  async saveCurrentUser(context: Context, username: string): Promise<void> {
    try {
      let pre = await preferences.getPreferences(context, 'appState');
      await pre.put('username', username);
      await pre.flush();
    } catch (e) {
      console.log('hai saveCurrentUser失败' + e);
    }
  }

  // 读当前用户名
  async getCurrentUser(context: Context): Promise<string> {
    try {
      let pre = await preferences.getPreferences(context, 'appState');
      return (await pre.get('username', '')) as string;
    } catch (e) {
      console.log('hai getCurrentUser失败' + e);
      return '';
    }
  }
}

export default new preUtil();