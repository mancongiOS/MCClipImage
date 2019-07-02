# MCClipImage

[github地址](https://github.com/mancongiOS/MCClipImage)

#支持功能说明

 * 裁切矩形图片 
 * 裁切圆形图片 
 * 裁切相册图片 
 * 裁切拍照图片 
 * 调整图片缩放 
 * 调整裁切框大小
 * 图片旋转操作 



#示例图

![功能说明](https://github.com/mancongiOS/MCClipImage/blob/master/Resources/1.png)

![裁切圆形图片](https://github.com/mancongiOS/MCClipImage/blob/master/Resources/2.png)

![裁切拍照/相册图片](https://github.com/mancongiOS/MCClipImage/blob/master/Resources/3.png)

![裁切框](https://github.com/mancongiOS/MCClipImage/blob/master/Resources/4.png)

![调整裁切框比例](https://github.com/mancongiOS/MCClipImage/blob/master/Resources/5.png)

![调整裁切框比例](https://github.com/mancongiOS/MCClipImage/blob/master/Resources/6.png)


# 如何使用？
`pod 'MCClipImage'`

# 使用说明
* 引用`import MCClipImage`

* 打开编辑页面
 
```
let config = MCClipImageConfig()
config.clipImage = image
let vc = MCClipImageViewController()
vc.delegate = self
vc.initClipFunctionWithConfig(config)
self.present(vc, animated: true, completion: nil)
```

* 获取编辑的图片
实现MCClipImageViewControllerDelegate的代理方法

```
//点击了取消按钮
@objc optional func clipImageViewControllerDidCancel(_ viewController: MCClipImageViewController)
    
// 裁切完成
func clipImageViewController(_ viewController: MCClipImageViewController, didFinishClipingImage image:UIImage)
```

# 对配置类MCClipImageConfig的说明

```
public class MCClipImageConfig: NSObject {
    
    /// 待裁切的图片
    public var clipImage: UIImage?
    /// 想要的裁切比例
    public var clipScale: CGFloat = 2
    /// 是否裁切圆形
    public var isClipRound: Bool = false
    /// 覆盖层的背景颜色
    public var overlayBackgroundColor =  UIColor.black
    /// 裁切框的颜色
    public var clipBoxColor =  UIColor.green
    /// 裁切框的宽度
    public var clipBoxWidth: CGFloat =  1

    /// 重设裁切比例的数组 （数组为空，隐私该按钮）
    public var clipScaleType: [MCClipImageScaleType] = []
}
```

# 裁切相册/拍照图片

* 初始化

```
    lazy var helper: MCPickerImageHelper = {
        let helper = MCPickerImageHelper()
        return helper
    }()
```

**MCPickerImageHelper，如果声明为局部对象的话，走完就被销毁了。但是MCPickerImageHelper对象又作为n内部pickerViewController的代理执行者，执行者没了，所以就不响应pickerViewController的代理方法。 所以一定不能让MCPickerImageHelper对象被销毁，要么懒加载该对象要么成为全局的。**
* 开启

```
 // 开启相册
 helper.openPhotoLibrary(self)
 // 开启拍照
 helper.openCamera(self)
```

* 实现代理方法

```
@objc optional func pickerImageHelperDidCancel(_ picker: MCPickerImageHelper)
    
func pickerImageHelper(_ picker: MCPickerImageHelper, didFinishPickImage image:UIImage)
```

# 更详细的使用请看demo
[github地址](https://github.com/mancongiOS/MCClipImage)