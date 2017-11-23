# KNHook

性能损耗


| 状态            | 平均耗时       | 次数    |
| -------------  |:-------------:| -----:|
| 不加之前        | 0.000213s     | 20000次 |
| 函数副本方法     | 0.000579s      | 20000次 |
| 存IMP指针方法    | 0.000587s     | 20000次 |

不同设备之间会存在差异

函数副本方法：

所有方法都加上 KNHook_前缀
副本方法IMP指针使用原方法的

存IMP指针方法

将IMP指针转成long 存入字典中

```objc
        //缓存
        _IMP imp = method_getImplementation(method);
        
        NSNumber *pNumber = [NSNumber numberWithLong:(long)imp];
        
        [impDict setObject:pNumber forKey:NSStringFromSelector(methodSel)];
        
        //使用
        NSNumber *pNumber = [impDict objectForKey:NSStringFromSelector(invocation.selector)];
        
        long *p = (long *)[pNumber longValue];
        
        _IMP imp = (_IMP)p;
        
        [invocation invokeUsingIMP:imp];
```


勾某个类的所有方法的，查看所有方法的执行顺序

使用方法

[KNHook hookClass:@"TenpayPasswordCtrl"];

常规使用：

放在只执行一次的函数里，防止多次勾一个函数
如

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions

hook：

__attribute__((constructor)) static void entry()

放这里面

打日志的printf 改成 nslog

在终端那个应用里面就能看到日志

Nov  2 15:08:36 iPhone WeChat[2499] <Warning>: KNHooklog :-(void)appendPsw:(have 1 value)
return:(null)
value1:__NSCFString-->7
object:<TenpayPasswordCtrl: 0x1750a620; baseClass = UITextField; frame = (0 0; 246 42); text = ''; clipsToBounds = YES; opaque = NO; gestureRecognizers = <NSArray: 0x17635150>; layer = <CALayer: 0x175218b0>>
##########################################
Nov  2 15:08:36 iPhone WeChat[2499] <Notice>: [RedRobert] Tweak.xm:350 DEBUG: -[<TenpayPasswordCtrl: 0x1750a620> appendPsw:7]
Nov  2 15:08:36 iPhone WeChat[2499] <Warning>: KNHooklog :-(void)onChange(have 0 value)
return:(null)
object:<TenpayPasswordCtrl: 0x1750a620; baseClass = UITextField; frame = (0 0; 246 42); text = ''; clipsToBounds = YES; opaque = NO; gestureRecognizers = <NSArray: 0x17635150>; layer = <CALayer: 0x175218b0>>
##########################################
Nov  2 15:08:36 iPhone WeChat[2499] <Notice>: [RedRobert] Tweak.xm:356 DEBUG: -[<TenpayPasswordCtrl: 0x1750a620> onChange]
Nov  2 15:08:36 iPhone WeChat[2499] <Warning>: KNHooklog :-(id)ctrlDelegate(have 0 value)
return:(null)
object:<TenpayPasswordCtrl: 0x1750a620; baseClass = UITextField; frame = (0 0; 246 42); text = ''; clipsToBounds = YES; opaque = NO; gestureRecognizers = <NSArray: 0x17635150>; layer = <CALayer: 0x175218b0>>
##########################################




微信

[KNHook hookClass:@"WCPayLogicMgr"];

[KNHook hookClass:@"WCRedEnvelopesLogicMgr"];

[KNHook hookClass:@"ContactUpdateHelper"];

[KNHook hookClass:@"WCRedEnvelopesNetworkHelper"];

[KNHook hookClass:@"WCRedEnvelopesReceiveHomeView"]


#ANYMethodLog

《追踪方法调用顺序：》

[ANYMethodLog logMethodWithClass:@"ViewController"];


ov 23 10:27:46 iPhone WeChat[7309] <Warning>: 《before》方法调用deep:
[target:<TenpayPasswordCtrl: 0x17d3da20; baseClass = UITextField; frame = (0 0; 0 0); transform = [0, 0, 0, 0, 0, 0]; alpha = 0; opaque = NO; layer = (null)>
《selector》: initWithFrame:{{0, 0}, {246, 42}} AndImage:<UIImage: 0x17d3d810> ]
Nov 23 10:27:46 iPhone WeChat[7309] <Warning>: 《before》方法调用deep:-
[target:<TenpayPasswordCtrl: 0x17d3da20; baseClass = UITextField; frame = (0 0; 246 42); text = ''; clipsToBounds = YES; opaque = NO; layer = <CALayer: 0x17d3eb30>>
《selector》: setSaltVal:unknown ]
Nov 23 10:27:46 iPhone WeChat[7309] <Warning>: 《after》方法调用deep:-
[target:<TenpayPasswordCtrl: 0x17d3da20; baseClass = UITextField; frame = (0 0; 246 42); text = ''; clipsToBounds = YES; opaque = NO; layer = <CALayer: 0x17d3eb30>>
《selector》: setSaltVal:unknown ]
返回值:void
interval:0.000018
Nov 23 10:27:46 iPhone WeChat[7309] <Warning>: 《after》方法调用deep:
[target:<TenpayPasswordCtrl: 0x17d3da20; baseClass = UITextField; frame = (0 0; 246 42); text = ''; clipsToBounds = YES; opaque = NO; layer = <CALayer: 0x17d3eb30>>
《selector》: initWithFrame:{{0, 0}, {246, 42}} AndImage:<UIImage: 0x17d3d810> ]
返回值:<TenpayPasswordCtrl: 0x17d3da20; baseClass = UITextField; frame = (0 0; 246 42); text = ''; clipsToBounds = YES; opaque = NO; layer = <CALayer: 0x17d3eb30>>
interval:0.005786


#Meow
































