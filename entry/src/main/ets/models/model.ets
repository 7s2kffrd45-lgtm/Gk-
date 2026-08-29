import { uiMaterial } from '@kit.ArkUI';
import { Available } from '@kit.BasicServicesKit';

@ObservedV2
export class SafeAreaInfo {
  @Trace topHeight?: number = 0;
  @Trace bottomHeight?: number = 0;
}

export class classTimeNum {
  theNum: string = '';
  theTime: string = '';
}

export interface q1 {
  image: ResourceStr
  name: string

}

export const iconData: q1[] = [
  { image: $r("app.media.xiguazhi"), name: '其他' },
]

//判断设备是否算力支持开启沉浸光感（带缓存优化）
let materialSupportCache: boolean | null = null; // 静态缓存变量

export function checkMaterailSupport(): boolean {
  // 如果已经检测过，直接返回缓存结果
  if (materialSupportCache !== null) {
    return materialSupportCache;
  }

  // 首次检测
  let canOpen: boolean = false;
  try {
    const info: uiMaterial.MaterialInfo = uiMaterial.getMaterialInfo();
    if (info.state != uiMaterial.MaterialState.DISABLE) {
      canOpen = true;
    }
  } catch (err) {
    console.log("hai 该设备不支持沉浸光感")
    canOpen = false;
  }

  // 缓存结果
  materialSupportCache = canOpen;
  return canOpen;
}

export class theUimaterail {
  //沉浸光感ui材质
  @Available({ minApiVersion: 'HarmonyOS 26.0.0' }) public readonly immersivemat: uiMaterial.Material =
    new uiMaterial.ImmersiveMaterial({
      style: uiMaterial.ImmersiveStyle.ULTRA_THIN,
      interactive: true,
      lightEffect: { color: Color.White },
      materialColor: '#40FFFFFF', // 带透明度的赋色，避免遮挡滤镜
      applyShadow: true,

    })
  //低算力设备沉浸光感ui材质替代
  public readonly fallbackBgColor: ResourceColor = '#CCF0F0F0';
  public readonly fallbackBorderColor: ResourceColor = '#33000000';
  public readonly fallbackBorderWidth: number = 0.5;
  public readonly fallbackBorderRadius: number = 24;
  public readonly fallbackShadow: ShadowOptions = {
    radius: 8,
    color: '#1A000000',
    offsetX: 0,
    offsetY: 2,
  }
}

export interface GreetingInfo {
  month: number;
  day: number;
  week: string;
  greeting?: string;
}

export function getGreetingInfo(): GreetingInfo {
  const now = new Date();
  const hour = now.getHours();
  const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

  let greeting: string;
  if (hour < 6) {
    greeting = '凌晨好';
  } else if (hour < 9) {
    greeting = '早上好';
  } else if (hour < 12) {
    greeting =
      '上午好';
  } else if (hour < 14) {
    greeting = '中午好';
  } else if (hour < 18) {
    greeting = '下午好';
  } else if (hour <
    22) {
    greeting = '晚上好';
  } else {
    greeting = '夜深了';
  }

  return {
    month: now.getMonth() + 1,
    day: now.getDate(),
    week: weekdays[now.getDay()],
    greeting: greeting
  };
}
