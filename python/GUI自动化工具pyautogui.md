##  GUI自动化工具pyautogui
> https://mp.weixin.qq.com/s/GS5VYhCSOu_qJ8VYAoJk1Q
```shell
pip3 install pyautogui
```

```python
# 移动鼠标
import pyautogui

pyautogui.moveTo(200, 400, duration=2)
pyautogui.moveRel(200, 500, duration=2)

# 获取当前鼠标位置
print(pyautogui.position())

# 鼠标点击，默认左键
pyautogui.click(100, 100)
# 单击左键
pyautogui.click(100, 100, button='left')
# 单击右键
pyautogui.click(100, 300, button='right')
# 单击中间
pyautogui.click(100, 300, button='middle')

# 双击左键
pyautogui.doubleClick(10,10)
# 双击右键
pyautogui.rightClick(10,10)
# 双击中键
pyautogui.middleClick(10,10)

# 鼠标按下
pyautogui.mouseDown()
# 鼠标释放
pyautogui.mouseUp()

# 鼠标拖动到指定坐标位置，并且设置操作时间
pyautogui.dragTo(100,300,duration=1)

# 按照方向拖动鼠标
pyautogui.dragRel(100,300,duration=4)

# 滚动鼠标到达向上或者向下的位置
pyautogui.scroll(300)

```


## web开发

```shell
flask
Django
fastapi
```