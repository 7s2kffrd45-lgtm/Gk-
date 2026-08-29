// import picker from '@ohos.file.picker';
// import { fileIo } from '@kit.CoreFileKit';
// import rcp from '@hms.collaboration.rcp';
// import { JSON, util } from '@kit.ArkTS';
// import common from '@ohos.app.ability.common';
// import { CourseItem, WeekSchedule } from './dataBody';
//
// const JOB_URL = 'https://paddleocr.aistudio-app.com/api/v2/ocr/jobs';
// const TOKEN = '1c38fa9ada2f53f21226ee2f904724b75eb3aa2b';
// const MODEL = 'PaddleOCR-VL-1.6';
// const context = getContext(this) as common.UIAbilityContext;
//
// export class getDataForRcppdf {
//   static async selectFile(): Promise<string> {
//     const option: picker.DocumentSelectOptions = new picker.DocumentSelectOptions();
//     option.maxSelectNumber = 1;
//     option.fileSuffixFilters = ['.pdf'];
//     const documentviewpicker: picker.DocumentViewPicker = new picker.DocumentViewPicker();
//     const uri = await documentviewpicker.select(option);
//     return uri[0];
//   }
//
//   static async copyFilesToSanbox(uri: string, context: Context): Promise<string> {
//     const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
//     const filename = `pdf_${Date.now()}.pdf`;
//     const sandBoxpath = `${context.cacheDir}/${filename}`;
//     fileIo.copyFileSync(file.fd, sandBoxpath);
//     fileIo.closeSync(file.fd);
//     return sandBoxpath;
//   }
//
//   static async upFiles(sandBoxpath: string): Promise<string> {
//     let session = rcp.createSession();
//     let form = new rcp.MultipartForm({
//       'model': 'PaddleOCR-VL-1.6',
//       'optionalPayload': JSON.stringify({
//         useDocOrientationClassify: false,
//         useDocUnwarping: false,
//         useChartRecognition: false,
//       }),
//       'file': {
//         contentType: 'application/pdf',
//         remoteFileName: 'file.pdf',
//         contentOrPath: sandBoxpath,
//       } as rcp.FormFieldFileValue,
//     });
//
//     console.log("hai 请求开始！")
//     try {
//       let request = new rcp.Request(JOB_URL, 'POST');
//       request.content = form;
//       request.headers = { 'Authorization': `bearer ${TOKEN}` };
//       let respones = await session.fetch(request);
//       session.close();
//       const textdecoder = util.TextDecoder.create('utf-8');
//       let json = textdecoder.decodeToString(new Uint8Array(respones.body as ArrayBuffer));
//       let result: Record<string, Object> = JSON.parse(json) as Record<string, Object>;
//       let data = result['data'] as Record<string, Object>;
//       let jobid = data['jobId'] as string;
//       return jobid;
//     } catch (e) {
//       console.log("hai 请求失败！" + e);
//       return '';
//     }
//   }
//
//   static async checkPdfState(jobId: string): Promise<string> {
//     let session = rcp.createSession();
//     let textDecoder = util.TextDecoder.create('utf-8');
//
//     while (true) {
//       let request = new rcp.Request(`${JOB_URL}/${jobId}`, 'GET');
//       request.headers = { 'Authorization': `bearer ${TOKEN}` };
//       let respones = await session.fetch(request);
//       let json = textDecoder.decodeToString(new Uint8Array(respones.body));
//       let result: Record<string, Object> = JSON.parse(json) as Record<string, Object>;
//       let data = result['data'] as Record<string, Object>;
//       let state = data['state'] as string;
//       if (state === 'done') {
//         let resultUrl = data['resultUrl'] as Record<string, Object>;
//         let jsonUrl = resultUrl['jsonUrl'] as string;
//         session.close();
//         return jsonUrl;
//       } else if (state === 'failed') {
//         let errorMsg = data['errorMsg'] as string;
//         session.close();
//         throw new Error('任务失败：' + errorMsg);
//       }
//       await new Promise<void>(resolve => {
//         setTimeout(resolve, 5000)
//       })
//     }
//   }
//
//   static async fetchResult(jsonUrl: string): Promise<string> {
//     let session = rcp.createSession();
//     let textDecoder = util.TextDecoder.create('utf-8');
//     let request = new rcp.Request(jsonUrl, 'GET');
//     let respones = await session.fetch(request);
//     let bodystr = textDecoder.decodeToString(new Uint8Array(respones.body) as Uint8Array);
//     session.close();
//     let lines = bodystr.trim().split('\n');
//     let text = '';
//     for (const line of lines) {
//       let trimmed = line.trim();
//       if (!trimmed) {
//         continue;
//       }
//       let parsed: Record<string, Object> = JSON.parse(trimmed) as Record<string, Object>;
//       let result = parsed['result'] as Record<string, Object>;
//       let layoutResults = result['layoutParsingResults'] as Object[];
//       for (const item of layoutResults) {
//         let res = item as Record<string, Object>;
//         let markdown = res['markdown'] as Record<string, Object>;
//         text += markdown['text'] as string;
//       }
//     }
//     return text;
//   }
//
//   static extractCoursesWithDay(html: string): Record<string, string>[] {
//     const dayNames: string[] = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
//     let courses: Record<string, string>[] = [];
//     let courseName = '';
//
//     console.log('hai html前200字符：' + html.substring(0, 200));
//
//     let rowRegex = /<tr[^>]*>([\s\S]*?)<\/tr>/g;
//     let rowMatch: RegExpExecArray | null;
//     let rows: string[] = [];
//     while ((rowMatch = rowRegex.exec(html)) !== null) {
//       rows.push(rowMatch[1]);
//     }
//     console.log('hai 解析出行数：' + rows.length);
//
//     let occupied: boolean[][] = [];
//
//     for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
//       if (!occupied[rowIdx]) {
//         occupied[rowIdx] = [];
//       }
//
//       let cellRegex = /<td[^>]*>([\s\S]*?)<\/td>/g;
//       let cellMatch: RegExpExecArray | null;
//       let colIdx = 0;
//
//       while ((cellMatch = cellRegex.exec(rows[rowIdx])) !== null) {
//         while (occupied[rowIdx][colIdx]) {
//           colIdx++;
//         }
//
//         let fullCell = cellMatch[0];
//         let cellText = cellMatch[1]
//           .replace(/<[^>]+>/g, '')
//           .replace(/&nbsp;/g, '')
//           .trim();
//
//         let rsMatch = fullCell.match(/rowspan="(\d+)"/);
//         let rowspan = rsMatch ? parseInt(rsMatch[1]) : 1;
//
//         for (let r = 1; r < rowspan; r++) {
//           if (!occupied[rowIdx + r]) {
//             occupied[rowIdx + r] = [];
//           }
//           occupied[rowIdx + r][colIdx] = true;
//         }
//
//         console.log('hai 行' + rowIdx + ' 列' + colIdx + ' 内容：' + cellText.substring(0, 30));
//
//         if (rowIdx > 0 && colIdx >= 2 && colIdx <= 8) {
//           let day = dayNames[colIdx - 2];
//
//           if (cellText.includes('$') && !cellText.includes('/')) {
//             courseName = cellText.replace('$', '').trim();
//           }
//
//           if (cellText.includes('/') && cellText.includes(':')) {
//             let course = getDataForRcppdf.dealWithData(cellText);
//             course['day'] = day;
//             if (!course['courseName']) {
//               course['courseName'] = courseName;
//             }
//             if (course['场地']) {
//               courses.push(course);
//             }
//           }
//         }
//
//         colIdx++;
//       }
//     }
//
//     console.log('hai 解析出课程数：' + courses.length);
//     return courses;
//   }
//
//   static dealWithData(cellText: string): Record<string, string> {
//     let course: Record<string, string> = {};
//
//     let parts = cellText.split('/');
//     for (const part of parts) {
//       let trimmed = part.trim();
//       if (trimmed.includes(':')) {
//         let keyValue = trimmed.split(':');
//         course[keyValue[0].trim()] = keyValue[1].trim();
//       }
//     }
//
//     let dollarIndex = cellText.indexOf('$');
//     if (dollarIndex > 0) {
//       course['courseName'] = cellText.substring(0, dollarIndex).trim();
//     }
//
//     if (!course['courseName']) {
//       let nameMatch = cellText.match(/^([\u4e00-\u9fa5a-zA-Z0-9]+)\(/);
//       if (nameMatch) {
//         course['courseName'] = nameMatch[1].trim();
//       }
//     }
//
//     let match = cellText.match(/\((\d+-\d+节)\)(\d+-\d+周)/);
//     if (match) {
//       course['periods'] = match[1];
//       course['weeks'] = match[2];
//     }
//
//     return course;
//   }
//
//   static buildWeekSchedule(courses: Record<string, string>[]): WeekSchedule {
//     let schedule = new WeekSchedule();
//     const dayMap: Record<string, number> = {
//       '星期一': 0,
//       '星期二': 1,
//       '星期三': 2,
//       '星期四': 3,
//       '星期五': 4,
//       '星期六': 5,
//       '星期日': 6
//     };
//
//     for (const course of courses) {
//       let dayStr = course['day'] as string;
//       let dayIndex = dayMap[dayStr];
//       if (dayIndex === undefined) {
//         console.log('hai 未知星期：' + dayStr);
//         continue;
//       }
//
//       let periodsStr = course['periods'] as string;
//       if (!periodsStr) {
//         console.log('hai 无节次：' + course['courseName']);
//         continue;
//       }
//       let periodMatch = periodsStr.match(/(\d+)-(\d+)节/);
//       if (!periodMatch) {
//         console.log('hai 节次解析失败：' + periodsStr);
//         continue;
//       }
//
//       let start = parseInt(periodMatch[1]) - 1;
//       let end = parseInt(periodMatch[2]) - 1;
//
//       let item = new CourseItem();
//       item.courseName = course['courseName'] as string;
//       item.day = dayIndex;
//       item.startPeriod = start;
//       item.endPeriod = end;
//       item.teacher = course['教师'] as string;
//       item.location = course['场地'] as string;
//       item.weeks = course['weeks'] as string;
//
//       for (let p = start; p <= end; p++) {
//         schedule.grid[dayIndex][p] = item;
//       }
//     }
//
//     return schedule;
//   }
//
//   static async theResult() {
//     const sandBoxPath = await getDataForRcppdf.copyFilesToSanbox(await getDataForRcppdf.selectFile(), context);
//     console.log("hai 拿到沙箱路径")
//     const jobId = await getDataForRcppdf.upFiles(sandBoxPath);
//     console.log("hai jobId：" + jobId)
//     const jsonUrl = await getDataForRcppdf.checkPdfState(jobId);
//     console.log("hai jsonUrl：" + jsonUrl);
//     const html = await getDataForRcppdf.fetchResult(jsonUrl);
//     console.log("hai html长度：" + html.length);
//     const parts = getDataForRcppdf.extractCoursesWithDay(html);
//     console.log("hai 课程数量：" + parts.length);
//     const weekSchedule = getDataForRcppdf.buildWeekSchedule(parts);
//     console.log('hai weekschedule' + JSON.stringify(weekSchedule))
//     return weekSchedule;
//   }
// }
