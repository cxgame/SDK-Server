畅想互动服务端接入文档
=================

请求说明
-------------
* 本文档所提及所有post请求均为表单提交
* "content-type": "application/x-www-form-urlencoded"


参数说明
-------------

参数名 | 类型 | 说明   
:------- |:------- | :-----------
game_key | string | 我方提供，后台分配的每个游戏的唯一标识串
pay_key | string | 我方提供，用于支付相关操作的签名(请放在服务端，勿放在客户端代码里)
game_account | string | 玩家游戏账号，<font color=red>即客户端的user_id</font>

支付回调接口
-------------

* 当产生交易时，会根据后台填入的异步通知地址，通过POST请求的形式将支付结果通知到系统
* 支付回调接口必须返回字符串“success”（不包含引号）以表示CP正确收到了通知。如果返回的字符不是success这7个字符，服务器会按照一定的策略在之后的时间再进行几次通知直到收到正确返回。若在策略通知内全未收到正确返回服务器将不再通知，此时可调用查询接口主动查询。目前再通知失败后会在一定时间内再通知3次
* **CP必须要有处理重复通知的逻辑**
* 异步通知参数
* **<font color=red>CP必需判断支付结果state是SUCCESS才发能货</font>**

参数名 | 类型 | 说明   
:------- |:------- | :-----------
order_id | String | 畅想订单号
out_order_id | String | cp订单号
game_account | String | 订单发起的游戏账号（可能为空）<font color=red>即客户端的user_id</font>
**<font color=red>state</font>** | String | **<font color=red>支付结果 SUCCESS和FAIL</font>**
cost_amount | Integer | 订单金额（单位：分）
finish_ts | Long | 订单完成时间，格式：yyyy-MM-dd HH:mm:ss
extends_par1 | String | 额外参数1 与请求支付时的额外参数1一致
extends_par2 | String | 额外参数2 与请求支付时的额外参数2一致
sign | String | 签名（具体请参考[签名说明](#签名说明)）

body 示例
	
	cost_amount=1&finish_ts=2021-03-09 14:53:30&out_order_id=210480&sign=3b6bc3ff5294bb995640c82c4a624767&game_account=cx030315437&extends_par2=额外参数2&state=SUCCESS&extends_par1=额外参数1&order_id=x210309144147192HT

返利回调接口
-------------

* 当通过一定策略产生返利订单并生效后，会根据后台填入的异步通知地址，通过POST请求的形式将返利信息通知到系统
* 返利回调接口必须返回字符串“success”（不包含引号）以表示CP正确收到了通知。如果返回的字符不是success这7个字符，服务器会按照一定的策略在之后的时间再进行几次通知直到收到正确返回。若在策略通知内全未收到正确返回服务器将不再通知。
* **CP必须要有处理重复通知的逻辑**
* 异步通知参数

参数名 | 类型 | 说明   
:------- |:------- | :-----------
rebate_order_id | string | 返利订单号
* | * | 同支付回调参数


订单查询
-------------
* 当CP未收到回调或其他原因导致支付结果信息丢失时可以主动调用查询接口进行查询
* 请求地址

```
	POST: https://api.cxgame.net/app/sdk/v1/pay/query-result
```
* 查询参数

参数名 | 类型 | 说明   
:------- |:------- | :-----------
game_key | string | 后台分配的每个游戏的唯一标识串
order_id | String | 畅想订单号
sign | String | 签名（具体请参考[签名说明](#签名说明)）

* 订单查询的返回参数

参数名 | 类型 | 说明   
:------- |:------- | :-----------
code | Integer | 错误代码，200表示查询业务成功
message | String | 出错信息
*当code为业务成功代码时将加上与支付回调接口一致的参数

**这里先验证code和message，并且code和message不参与签名**
	
请求示例

	curl -X POST \
	  https://api.cxgame.net/YrjhK/query-result \
	  -H 'Content-Type: application/x-www-form-urlencoded' \
	  -d 'game_key=xx&order_id=xx&sign=xx'

返回示例
	
	{
		"code": 200,
		"cost_amount": "1",
		"finish_ts": "1970-01-01 08:00:00",
		"out_order_id": "xx",
		"sign": "xx",
		"game_account": "xx",
		"extends_par2": null,
		"state": "FAIL",
		"extends_par1": null,
		"message": "成功",
		"order_id": "xx"
	}

签名说明
-------------
* 签名的生成规则

1. 在通知返回参数列表中，除去sign参数外，无特殊说明外凡是通知返回回来的参数皆是待验签的参数。
2. **注意** 将剩下参数进行url_decode, 然后进行字典排序，然后按key=value，用&连接组成字符串，得到待签名字符串。
3. 在步骤2中得到的待签名字符串后直接加上pay_key得到签名字符串。
4. 对签名字符串md5加密后转成小写得到签名。

* 签名示例

1. 拼接除去sign外的请求参数（注意值为空的参数也需要拼接）得到待签名字符串如下

	```
	cost_amount=1&extends_par1=cx000000018&extends_par2=&finish_ts=2017-12-29 10:38:15&game_account=cx000000018&order_id=x1712291038021591&out_order_id=6504915732842283009&state=SUCCESS
	```

2. 在1中字符串最后直接拼接pay_key，得到待md5字符串

	```
	以pay_key为cNlKbUUSYshjGBYUGiZvRCkgiPArIemD为例得到如下字符串
	cost_amount=1&extends_par1=cx000000018&extends_par2=&finish_ts=2017-12-29 10:38:15&game_account=cx000000018&order_id=x1712291038021591&out_order_id=6504915732842283009&state=SUCCESScNlKbUUSYshjGBYUGiZvRCkgiPArIemD
	```

3. 将2中字符串md5加密后转成小写得到签名

	```
	MD5 ("cost_amount=1&extends_par1=cx000000018&extends_par2=&finish_ts=2017-12-29 10:38:15&game_account=cx000000018&order_id=x1712291038021591&out_order_id=6504915732842283009&state=SUCCESScNlKbUUSYshjGBYUGiZvRCkgiPArIemD") 
	= 4f74fb3ab14255dd93bfb096079f645f
	4f74fb3ab14255dd93bfb096079f645f即为签名
	```

* 参考代码：

	php

```php
	//接收POST参数
	$order_id            = $_POST['order_id'];          //SDK订单号
	$out_order_id        = $_POST['out_order_id'];      //游戏订单号
	$game_account        = $_POST['game_account'];      //订单发起的游戏账号（可能为空）
	$state               = $_POST['state'];             //支付结果 SUCCESS和FAIL
	$cost_amount         = $_POST['cost_amount'];       //订单金额（单位：分）
	$finish_ts           = $_POST['finish_ts'];         //订单完成的unix时间戳
	$extends_par1        = $_POST['extends_par1'];      //额外参数1 与请求支付时的额外参数1一致
	$extends_par2        = $_POST['extends_par2'];      //额外参数2 与请求支付时的额外参数2一致
	$sign                = $_POST['sign'];              //签名
	//字典排序
	$param = array(
	    'order_id'       => $order_id,
	    'out_order_id'   => $out_order_id,
	    'game_account'   => $game_account,
	    'state'          => $state,
	    'cost_amount'    => $cost_amount,
	    'finish_ts'      => $finish_ts,
	    'extends_par1'   => $extends_par1,
	    'extends_par2'   => $extends_par2,
	);
	ksort($param);
	//拼接&签名
	$pay_key = '******';//这里是约定好的pay_key
	$query = urldecode(http_build_query($param));
	$sign_check = md5($query.$pay_key);
```

	java

```java
	public static String getpreSignString(Map<String, String> params, String signKey) {
	    StringBuffer content = new StringBuffer();
	
	    // 按照key做排序
	    List<String> keys = new ArrayList<String>(params.keySet());
	    Collections.sort(keys);
	
	    for (int i = 0; i < keys.size(); i++) {
	        String key = keys.get(i);
	        if ("sign".equals(key)) {
	            continue;
	        }
	        String value = params.get(key);
	        if (value != null) {
	            content.append((content.length() == 0 ? "" : "&") + key + "=" + value);
	        } else {
	            content.append((content.length() == 0 ? "" : "&") + key + "=");
	        }
	
	    }
	    return content.toString() + signKey;
	}
	public static String generatePaySign(Map<String, String> params, String payKey) {
	    String preSignString  = getpreSignString(params, payKey);
	    return Util.md5(preSignString);
	}
```

登录验证
-------------
* 在登录后sdk会提供一个唯一token给CP，CP可以使用此token请求验证是否是有效用户
* 请求地址

```
	POST: https://api.cxgame.net/app/sdk/v1/verify-token
```
* 查询参数

参数名 | 类型 | 说明   
:------- |:------- | :-----------
token | String | 登录返回的token

* 返回参数

参数名 | 类型 | 说明   
:------- |:------- | :-----------
code | Integer | 错误代码，200表示查询业务成功
message | String | 出错信息
uid | String | 用户唯一标识

请求示例

	curl -X POST \
	  https://api.cxgame.net/app/sdk/v1/verify-token \
	  -H 'Content-Type: application/x-www-form-urlencoded' \
	  -d token=abc

返回示例
	
	{
	    "code": 1005,
	    "message": "无效token"
	}