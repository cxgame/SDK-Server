<?php
/*
 * 畅想SDK-充值回调发货DEMO
*/

//接收POST参数
$order_id				= $_POST['order_id'];			//SDK订单号
$out_order_id		= $_POST['out_order_id'];		//游戏订单号
$game_account		= $_POST['game_account'];	//订单发起的游戏账号（可能为空）
$state					= $_POST['state'];					//支付结果 SUCCESS和FAIL
$cost_amount		= $_POST['cost_amount'];		//订单金额（单位：分）
$finish_ts				= $_POST['finish_ts'];			//订单完成的unix时间戳
$extends_par1		= $_POST['extends_par1'];	//额外参数1 与请求支付时的额外参数1一致
$extends_par2		= $_POST['extends_par2'];	//额外参数2 与请求支付时的额外参数2一致
$sign					= $_POST['sign'];					//额外参数2 与请求支付时的额外参数2一致

//字典排序
$param = array(
	'order_id'			=> $order_id,
	'out_order_id'	=> $out_order_id,
	'game_account'	=> $game_account,
	'state'				=> $state,
	'cost_amount'	=> $cost_amount,
	'finish_ts'			=> $finish_ts,
	'extends_par1'	=> $extends_par1,
	'extends_par2'	=> $extends_par2,
);
ksort($param);

//拼接&签名
$pay_key = '******';//这里是约定好的pay_key
$query = urldecode(http_build_query($param));
$sign_check = md5($query.$pay_key);
if($sign == $sign_check)
{
	//验签通过
	
	//********//
	//
	//   此处是发货流程... ... 
	//   下方的方法paycoin()是处理己方发货，最后返回结果（请自行替换为自己的发货流程）
	//
	//********//
	$payorderstatus = paycoin();
	
	if($payorderstatus)
	{
		//发货成功
		echo 'success';
	}
	else
	{
		//发货失败
		echo 'failure';
	}
}
else
{
	//验证失败
	echo 'failure';
}

