<%--
  Created by IntelliJ IDEA.
  User: tanxinyang
  Date: 2017/12/22
  Time: 下午2:34
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.util.*" %>
<%!
    String getpreSignString(Map<String, String> params, String signKey) {
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
                content.append((i == 0 ? "" : "&") + key + "=" + value);
            } else {
                content.append((i == 0 ? "" : "&") + key + "=");
            }
        }
        return content.toString() + signKey;
    }

    String getMD5(String message) {
        String md5str = "";
        try {
            // 1 创建一个提供信息摘要算法的对象，初始化为md5算法对象
            MessageDigest md = MessageDigest.getInstance("MD5");

            // 2 将消息变成byte数组
            byte[] input = message.getBytes();

            // 3 计算后获得字节数组,这就是那128位了
            byte[] buff = md.digest(input);

            // 4 把数组每一字节（一个字节占八位）换成16进制连成md5字符串
            md5str = bytesToHex(buff);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return md5str;
    }

    String bytesToHex(byte[] bytes) {
        StringBuffer md5str = new StringBuffer();
        // 把数组每一字节换成16进制连成md5字符串
        int digital;
        for (int i = 0; i < bytes.length; i++) {
            digital = bytes[i];

            if (digital < 0) {
                digital += 256;
            }
            if (digital < 16) {
                md5str.append("0");
            }
            md5str.append(Integer.toHexString(digital));
        }
        return md5str.toString().toLowerCase();
    }
%>
<%
    String payKey = "nUkOcetjztocgxSaOJUmnTDgfzAKynYX";
    //获取POST参数
    Map<String,String> params = new HashMap<>();
    Map requestParams = request.getParameterMap();
    for (Iterator iter = requestParams.keySet().iterator(); iter.hasNext();) {
        String name = (String) iter.next();
        String[] values = (String[]) requestParams.get(name);
        String valueStr = "";
        for (int i = 0; i < values.length; i++) {
            valueStr = (i == values.length - 1) ? valueStr + values[i]
                    : valueStr + values[i] + ",";
        }
        params.put(name, valueStr);
    }

    String preSignString  = getpreSignString(params, payKey);
    String targetSign = getMD5(preSignString);

    try {
        String sign = params.get("sign");
        System.out.println(sign);
        System.out.println(targetSign);
        if (targetSign.equals(sign)) {
            System.out.println("验证签名成功");
            System.out.println(params.get("state"));
            if (params.get("state").equals("SUCCESS")) {
                System.out.println("支付成功");
            } else {
                System.out.println("支付不成功");
            }
            out.clear();
            out.print("success");
        } else {
            System.out.println("验证签名失败");
            out.print("fail");
        }

    }
    catch (Exception e) {
        e.printStackTrace();
    }

%>