# Android FCM 背景推播音效 - 後端設定說明

## 問題說明

Android 8+ 的音效由 **Notification Channel** 決定。若後端只傳 `sound="got_a_driver"` 但未指定 `channel_id`，系統會使用預設 channel（ding_dong），導致背景推播音效錯誤。

## App 端已完成的設定

- `default_notification_channel`：音效 = ding_dong（其他通知）
- `got_a_driver_channel`：音效 = got_a_driver（司機已接單、司機抵達）

## 後端需修改

在 `sendCustomerNotification` 中，當 `sound` 為自訂音效時，需加上 `channel_id`：

```python
def sendCustomerNotification(customer, title, body, data=None, sound="default"):
    """
    推播给一键叫车 app 的客户
    
    Args:
        customer: Customer 对象
        title: 推播标题
        body: 推播内容
        data: 额外数据（字典）
        sound: 音效名称 ("got_a_driver" | "ding_dong" | "default")
    """
    from apps.oneBtnCallCarApi.models import CustomerFCMDeviceLink
    
    # Android: 自訂音效需指定 channel_id，否則會用預設 channel (ding_dong)
    android_channel_id = None
    if sound == "got_a_driver":
        android_channel_id = "got_a_driver_channel"
    elif sound == "ding_dong":
        android_channel_id = "default_notification_channel"
    # sound == "default" 時不指定，使用 manifest 預設
    
    android_notification = AndroidNotification(
        sound=sound,
        default_sound=(sound == "default"),
        channel_id=android_channel_id,  # 關鍵：指定 channel
    )
    
    message = Message(
        notification=Notification(title=title, body=body),
        data=data or {},
        android=AndroidConfig(
            notification=android_notification,
            priority="high"
        ),
        apns=APNSConfig(
            payload=APNSPayload(
                aps=Aps(
                    sound=f"{sound}.caf" if sound != "default" else "default",
                    content_available=True,
                )
            ),
            headers={"apns-priority": "10"}
        ),
    )
    
    # ... 其餘程式碼不變
```

## Channel 對照表

| sound 參數   | Android channel_id           | 音效     |
|-------------|------------------------------|----------|
| `got_a_driver` | `got_a_driver_channel`        | got_a_driver |
| `ding_dong` | `default_notification_channel` | ding_dong   |
| `default`   | 不指定（用 manifest 預設）   | 系統預設 |

## 司機抵達推播

若司機抵達目前使用 `sound="default"` 或 `sound="ding_dong"`，要改成 got_a_driver 時：

```python
# 司機抵達
sendCustomerNotification(
    case.customer,
    title="司機已到達",
    body="您的司機已到達上車地點",
    data={'case_id': str(case.id), 'type': 'driver_arrived', ...},
    sound="got_a_driver"  # 加上此參數
)
```

後端加上 `channel_id` 後，背景推播音效就會正確。
